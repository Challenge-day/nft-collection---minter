import { Address, toNano } from '@ton/core';
import { ChallengeNFTCollection } from '../wrappers/ChallengeNFTCollection';
import { NetworkProvider } from '@ton/blueprint';

const ADDR = 'EQBQKQseSL8mXW3isPicq2QqMCJp1v0_E_3EfXtTlyGnz92I';

export async function run(provider: NetworkProvider) {
    const challengeNFTCollection = provider.open(ChallengeNFTCollection.fromAddress(Address.parse(ADDR)));

    // await challengeNFTCollection.send(
    //     provider.sender(),
    //     {
    //         value: toNano('0.05'),
    //     },
    //     'mint_one_for_self',
    // );

    await challengeNFTCollection.send(
        provider.sender(),
        { value: toNano('0.5') },
        {
            $$type: 'Mint',
            query_id: 0n,
            quantity: 3n,
            new_owner: Address.parse('0QDOekWhG6_fn14DU51jnA7hniRfWFn_JZt-hFN4JrZuB-ea'),
        },
    );

    // run methods on `challengeNFTCollection`
}
