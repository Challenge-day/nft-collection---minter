import { Address, toNano } from '@ton/core';
import { atc } from '../wrappers/all';
import { NetworkProvider } from '@ton/blueprint';

const ADDR = 'EQDCx2eN6ilaknRrdNNhMkg85AEcPYAQYKN7NSdS-uebVau7';

export async function run(provider: NetworkProvider) {
  const challengeATC = provider.open(atc.ChallengeATC.fromAddress(Address.parse(ADDR)));

  await challengeATC.send(
      provider.sender(),
      { value: toNano('0.05') },
      "reap",
  );

  // run methods on `challengeNFTCollection`
}