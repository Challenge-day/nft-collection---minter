import "@stdlib/deploy";
import "@stdlib/ownable";
import "./messages/atc";

contract ChallengeATC with Deployable, Ownable {
  owner: Address;
  nft_collection_address: Address?;
  tons_per_nft: Int as coins;

  MIN_GAS_PER_NFT_MINTED: Int as coins = ton("0.05");

  init(nft_collection_address: Address?, tons_per_nft: Int) {
    self.owner = sender();
    self.nft_collection_address = nft_collection_address;
    self.tons_per_nft = tons_per_nft;
  }

  receive(msg: SetCollectionAddress) {
    let builder: StringBuilder = beginString();
    builder.append("Query ID: ");
    builder.append(msg.query_id.toString());

    dump(builder.toString());

    self.requireOwner();
    self.nft_collection_address = msg.new_collection_address;
  }

  receive(msg: RelinquishOwnership) {
        self.requireOwner();
        self.owner = msg.new_owner;
        msg.timestamp = now();
        emit(msg.toCell());
    }

  receive(msg: SetTONsPerNFT) {
    self.requireOwner();
    self.tons_per_nft = msg.amount;
  }

  receive(msg: BuyNFT) {
    self.check_collection_address();
    self.check_fee(msg.quantity);
    let total_gas: Int = self.min_gas_per_nft_minted() * msg.quantity;

    send(SendParameters{
      to: self.nft_collection_address!!,
      mode: SendBounceIfActionFail + SendPayGasSeparately,
      value: total_gas,
      bounce: false,
      body: beginCell()
      .storeUint(0x400, 32)
      .storeUint(0x0, 64)
      .storeAddress(msg.receiver)
      .storeUint(msg.quantity, 256)
      .endCell()
    });
  }

  receive("reap") {
    self.requireOwner();
    let builder: StringBuilder = beginString();

    builder.append("ATC was reaped on timestamp: ");
    builder.append(now().toString());

    let value: Int = myBalance() - context().value;

    send(SendParameters{
      to: self.owner,
      mode: SendBounceIfActionFail + SendRemainingValue,
      value,
      bounce: false,
      body: builder.toString().asComment()
    });
  }

  get fun min_gas_per_nft_minted(): Int {
    return self.MIN_GAS_PER_NFT_MINTED;
  }

  get fun calculate_total_fee(quantity: Int): Int {
    let total_protocol_fee: Int = self.tons_per_nft * quantity;
    let total_required_gas: Int = self.min_gas_per_nft_minted() * quantity;
    return total_protocol_fee + total_required_gas;
  }

  inline fun check_fee(quantity: Int) {
    let ctx: Context = context();
    let total_protocol_fee: Int = self.tons_per_nft * quantity;
    let total_required_gas: Int = self.min_gas_per_nft_minted() * quantity;
    require(ctx.value >= total_protocol_fee + total_required_gas, "protocol_fee_and_gas"); 
  }

  inline fun check_collection_address() {
    require(self.nft_collection_address != null, "nft_collection_is_null");
  }
}