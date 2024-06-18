import { Address, toNano } from '@ton/core';
import { atc } from '../wrappers/all';
import { NetworkProvider } from '@ton/blueprint';

const ADDR = 'EQDCx2eN6ilaknRrdNNhMkg85AEcPYAQYKN7NSdS-uebVau7';

export async function run(provider: NetworkProvider) {
  const challengeATC = provider.open(atc.ChallengeATC.fromAddress(Address.parse(ADDR)));

  const value = await challengeATC.getCalculateTotalFee(10n);

  await challengeATC.send(
      provider.sender(),
      { value },
      {
        $$type: "BuyNFT",
        quantity: 10n,
        receiver: Address.parse("0QDOekWhG6_fn14DU51jnA7hniRfWFn_JZt-hFN4JrZuB-ea"),
        query_id: 1n
      },
  );

  // run methods on `challengeNFTCollection`
}