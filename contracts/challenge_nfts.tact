import "@stdlib/deploy";
import "@stdlib/ownable";
import "@stdlib/stoppable";
import "./traits/nft_collection_standard";
import "./traits/nft_item_standard";
import "./structures/nfts";
import "./messages/nfts";


contract ChallengeNFTCollection with Deployable, Ownable, Resumable, NFTCollectionStandard {
    owner: Address;
    stopped: Bool = false;
    next_item_index: Int as uint256 = 0;
    count_of_nfts_minted: Int as uint256 = 0;
    collection_content: Cell;

    minters: Minters;

    minTonForStorage: Int = ton("0.03");
    gasConsumption: Int = ton("0.03");

    MAX_MINTABLE_NFTS: Int? as uint256;

    init(collection_content: Cell, max_mintable_nfts: Int?) {
        self.owner = sender();
        self.collection_content = collection_content;
        self.minters = Minters{ minters: emptyMap(), length: 0 };
        self.MAX_MINTABLE_NFTS = max_mintable_nfts;

        self.minters.pushMinter(sender());
    }

    receive(msg: Mint) {
        self._check_minter();
        self.requireNotStopped();
        self._mint(msg.new_owner, msg.quantity, msg.query_id);
    }

    receive(msg: SetMaxMintable) {
        self.requireOwner();
        self.MAX_MINTABLE_NFTS = msg.max;
    }

    receive("nullify_limit") {
        self.requireOwner();
        require(self.MAX_MINTABLE_NFTS != null, "already_null");
        self.MAX_MINTABLE_NFTS = null;
    }

    receive(msg: RelinquishOwnership) {
        self.requireOwner();
        self.minters.removeMinter(self.owner);
        self.owner = msg.new_owner;
        self.minters.pushMinter(msg.new_owner);
        msg.timestamp = now();
        emit(msg.toCell());
    }

    receive("mint_one_for_self") {
        self.requireOwner();
        self.requireNotStopped();
        self._mint(self.owner, 1, random(0, pow(2, 64)));
    }

    receive(msg: Minter) {
        self.requireOwner();

        let is_minter: Bool = self.minters.isMinter(msg.minter);

        if (!is_minter) {
            self._add_minter(msg.minter);
        } else {
            self._remove_minter(msg.minter);
        }
    }

    receive("reap") {
        self.requireOwner();
        let builder: StringBuilder = beginString();

        builder.append("Collection contract was reaped on timestamp: ");
        builder.append(now().toString());

        let value: Int = myBalance() - context().value;

        send(SendParameters{
            to: self.owner,
            mode: SendIgnoreErrors + SendRemainingValue,
            value,
            bounce: false,
            body: builder.toString().asComment()
        });
    }

    inline fun _add_minter(address: Address) {
        self.minters.pushMinter(address);
    }

    inline fun _remove_minter(address: Address) {
        self.minters.removeMinter(address);
    }

    fun _check_minter() {
        let ctx: Context = context();
        require(self.minters.isMinter(ctx.sender), "only_minter");
    }

    inline fun _mint(to: Address, quantity: Int, query_id: Int) {
        require(quantity > 0, "quantity_must_be_greater_than_0");

        if (self.MAX_MINTABLE_NFTS != null) {
            self.check_does_not_exceed_max(quantity);
        }
        
        let _quantity: Int = quantity;
        let ctx: Context = context();
        let value: Int = self.msgValue(ctx.value);

        while(_quantity > 0) {
            let nftInit: StateInit = self._get_nft_item_state_init(self.next_item_index);
            let nftAddress: Address = contractAddress(nftInit);
            send(SendParameters{
                to: nftAddress,
                mode: SendIgnoreErrors,
                code: nftInit.code,
                data: nftInit.data,
                value: value / quantity,
                bounce: false,
                body: Transfer{
                    query_id,
                    new_owner: to,
                    response_destination: context().sender,
                    custom_payload: self.collection_content,
                    forward_amount: 0,
                    forward_payload: emptyCell()
                }.toCell()
            });

            self.next_item_index += 1;
            _quantity = _quantity - 1;
            self.count_of_nfts_minted +=1;
        }
    }

    inline fun check_does_not_exceed_max(quantity: Int) {
        require(self.count_of_nfts_minted + quantity <= self.MAX_MINTABLE_NFTS!!, "cannot_exceed_max_mintable");
    }

    override inline fun _get_nft_item_state_init(index: Int): StateInit {
        return initOf ChallengeNFTItem(myAddress(), index, self.owner, self.collection_content);
    }

    fun msgValue(val: Int): Int {
        let currentTonBalance: Int = myBalance() - val;
        let storageFee: Int = self.minTonForStorage - min(currentTonBalance, self.minTonForStorage);
        return val - (storageFee + self.gasConsumption);
    }

    fun get_max_mintable_nfts(): Int? {
        return self.MAX_MINTABLE_NFTS;
    }
}

contract ChallengeNFTItem with Ownable, NFTItemStandard {
    initialized: Bool;
    owner: Address;
    index: Int;
    collection_address: Address;
    individual_content: Cell;

    minTonForStorage: Int = ton("0.03");
    gasConsumption: Int = ton("0.03");

    init(collection_address: Address, index: Int, owner: Address, individual_content: Cell) {
        self.collection_address = collection_address;
        self.owner = owner;
        self.index = index;
        self.individual_content = individual_content;
        self.initialized = false;
    }

    receive(msg: Transfer) {
        let ctx: Context = context();
        let _msgVal: Int = self.msgValue(ctx.value);

        if (!self.initialized) {
            require(ctx.sender == self.collection_address, "collection_must_initialize_nft");
            self.initialized = true;
            self.owner = msg.new_owner;
            self.individual_content = msg.custom_payload!!;
            send(SendParameters{
                to: msg.response_destination!!,
                value: 0,
                mode: SendIgnoreErrors + SendRemainingValue,
                body: Excesses{ query_id: msg.query_id }.toCell()
            });
        } else {
            self.requireOwner();
            self.owner = msg.new_owner;

            if (msg.forward_amount > 0) {
                send(SendParameters{
                    to: msg.new_owner,
                    value: msg.forward_amount,
                    mode: SendIgnoreErrors,
                    bounce: false,
                    body: OwnershipAssigned{
                        query_id: msg.query_id,
                        prev_owner: ctx.sender,
                        forward_payload: msg.forward_payload!!.asSlice()
                    }.toCell()
                });
            }

            _msgVal = _msgVal - ctx.readForwardFee();

            if (msg.response_destination != null && _msgVal > msg.forward_amount) {
                send(SendParameters{
                    to: msg.response_destination!!,
                    value: _msgVal - msg.forward_amount,
                    mode: SendPayGasSeparately,
                    bounce: true,
                    body: Excesses{ query_id: msg.query_id }.toCell()
                });
            }
        }
    }

    fun msgValue(val: Int): Int {
        let currentTonBalance: Int = myBalance() - val;
        let storageFee: Int = self.minTonForStorage - min(currentTonBalance, self.minTonForStorage);
        return val - (storageFee + self.gasConsumption);
    }
}
