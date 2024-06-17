import { beginCell, toNano } from '@ton/core';
import { ChallengeNFTCollection } from '../wrappers/ChallengeNFTCollection';
import { NetworkProvider } from '@ton/blueprint';

const OFFCHAIN_TAG = 0x01;
const BASE_URL = 'https://s.getgems.io/nft/c/665d3d0288f45e66efa10d57/';

export async function run(provider: NetworkProvider) {
    const collectionContent = beginCell().storeInt(OFFCHAIN_TAG, 8).storeStringRefTail(BASE_URL).endCell();
    const challengeNFTCollection = provider.open(await ChallengeNFTCollection.fromInit(collectionContent));

    await challengeNFTCollection.send(
        provider.sender(),
        {
            value: toNano('0.05'),
        },
        {
            $$type: 'Deploy',
            queryId: 0n,
        },
    );

    await provider.waitForDeploy(challengeNFTCollection.address);
    console.log('Collection deployed to address ', challengeNFTCollection.address.toString());

    // run methods on `challengeNFTCollection`
}
