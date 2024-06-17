message(0x5fcc3d14) Transfer {
  query_id: Int as uint64;
  new_owner: Address;
  response_destination: Address?;
  custom_payload: Cell?;
  forward_amount: Int as coins;
  forward_payload: Cell?;
}

message(0x400) Mint {
  query_id: Int as uint64;
  new_owner: Address;
  quantity: Int as uint256;
}

message(0x7e8) RelinquishOwnership {
  query_id: Int as uint64;
  new_owner: Address;
  timestamp: Int as uint256;
}

message(0x05138d91) OwnershipAssigned {
    query_id: Int as uint64;
    prev_owner: Address;
    forward_payload: Slice as remaining;
}

message(0xd53276db) Excesses {
    query_id: Int as uint64;
}

message(0x2fcb26a2) GetStaticData {
    query_id: Int as uint64;
}

message(0x8b771735) ReportStaticData {
    query_id: Int as uint64;
    index: Int as uint256;
    collection: Address;
}