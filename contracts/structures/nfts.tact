struct Minters {
  minters: map<Int as uint256, Address>;
  length: Int = 0;
}

struct NFTData {
  init: Bool = false;
  index: Int as uint256;
  collection_address: Address;
  owner_address: Address;
  individual_content: Cell;
}

struct NFTCollectionData {
  next_item_index: Int as uint256 = 0;
  collection_content: Cell;
  owner_address: Address;
}

extends mutates fun pushMinter(self: Minters, minter: Address): Int {
  let length: Int = self.length;
  let minters: map<Int as uint256, Address> = self.minters;
  
  foreach(key, value in minters) {
    require(value != minter, "already_minter");
  }

  self.minters.set(length, minter);
  self.length = length + 1;
  return self.length;
}

extends mutates fun removeMinter(self: Minters, minter: Address): Int {
  let minters: map<Int as uint256, Address> = self.minters;
  let mapIndex: Int? = null;

  foreach(key, value in minters) {
    if (value == minter) {
      mapIndex = key;
    }
  }

  require(mapIndex != null, "not_a_minter");
  self.minters.del(mapIndex!!);
  self.length -= 1;
  return self.length;
}