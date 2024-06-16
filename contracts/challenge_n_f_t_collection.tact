import "@stdlib/deploy";
import "@stdlib/ownable";
import "@stdlib/stoppable";
import "./traits/nft_collection_standard";

contract ChallengeNFTCollection with Deployable, Ownable, Resumable, NFTCollectionStandard {
    owner: Address;
    stopped: Bool = false;
    next_item_index: Int as uint32 = 0;
    collection_content: Cell;

    init(collection_content: Cell) {
        self.owner = sender();
        self.collection_content = collection_content;
    }
}
