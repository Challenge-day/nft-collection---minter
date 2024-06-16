import { toNano } from '@ton/core';
import { ChallengeNFTCollection } from '../wrappers/ChallengeNFTCollection';
import { NetworkProvider } from '@ton/blueprint';

export async function run(provider: NetworkProvider) {
    const challengeNFTCollection = provider.open(await ChallengeNFTCollection.fromInit());

    await challengeNFTCollection.send(
        provider.sender(),
        {
            value: toNano('0.05'),
        },
        {
            $$type: 'Deploy',
            queryId: 0n,
        }
    );

    await provider.waitForDeploy(challengeNFTCollection.address);

    // run methods on `challengeNFTCollection`
}
