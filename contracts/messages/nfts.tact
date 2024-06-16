message(0x5fcc3d14) Transfer {
  query_id: Int as uint64;
  new_owner: Address;
  response_destination: Address;
  custom_payload: Cell?;
  forward_amount: Int as coins;
  forward_payload: Cell?;
}

message(0x23ddc441d) Mint {
  query_id: Int as uint64;
  new_owner: Address;
  source: Address;
  quantity: Int as uint32;
}