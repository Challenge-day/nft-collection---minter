message(0x3001) SetCollectionAddress {
  query_id: Int as uint64;
  new_collection_address: Address;
}

message(0x3002) BuyNFT {
  query_id: Int as uint64;
  quantity: Int as uint256;
  receiver: Address;
}

message(0x7e8) RelinquishOwnership {
  query_id: Int as uint64;
  new_owner: Address;
  timestamp: Int as uint256;
}

message(0x3004) SetTONsPerNFT {
  query_id: Int as uint64;
  amount: Int as coins;
}