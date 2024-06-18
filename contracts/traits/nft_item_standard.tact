import "@stdlib/ownable";
import "../structures/nfts";
import "../messages/nfts";

trait NFTItemStandard with Ownable {
  initialized: Bool;
  owner: Address;
  index: Int;
  collection_address: Address;
  individual_content: Cell;


    receive(msg: GetStaticData){
        self._report_static_data(msg);
    }


  virtual inline fun _get_nft_data(): NFTData {
    let builder: StringBuilder = beginString();
        let collectionData: String = self.individual_content.asSlice().asString();
        builder.append(collectionData);
        builder.append(self.index.toString());
        builder.append("/meta.json");

        return NFTData {
            is_initialized: self.initialized, 
            index: self.index, 
            collection_address: self.collection_address, 
            owner_address: self.owner,
            individual_content: builder.toCell()
        };
  }

  virtual inline fun _report_static_data(msg: GetStaticData) {
        let ctx: Context = context();
        send(SendParameters {
            to: ctx.sender,
            value: 0,
            mode: SendRemainingValue,
            bounce: false,
            body: ReportStaticData{
                query_id: msg.query_id,
                index: self.index,
                collection: self.collection_address
            }.toCell()
        });
    }

  get fun get_nft_data(): NFTData {
    return self._get_nft_data();
  }
}