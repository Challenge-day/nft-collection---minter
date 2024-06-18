import { beginCell, toNano } from '@ton/core';
import { collection, atc } from '../wrappers/all';
import { NetworkProvider } from '@ton/blueprint';

const OFFCHAIN_TAG = 0x01;
const BASE_URL = 'https://s.getgems.io/nft/c/665d3d0288f45e66efa10d57/';

export async function run(provider: NetworkProvider) {
    const collectionContent = beginCell().storeInt(OFFCHAIN_TAG, 8).storeStringRefTail(BASE_URL).endCell();
    const challengeNFTCollection = provider.open(await collection.ChallengeNFTCollection.fromInit(collectionContent, null));

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

    const challengeATC = provider.open(await atc.ChallengeATC.fromInit(challengeNFTCollection.address, toNano('0.02')));

    await challengeATC.send(provider.sender(), { value: toNano('0.05') }, { $$type: 'Deploy', queryId: 0n });
    await provider.waitForDeploy(challengeATC.address);
    console.log('ATC deployed to address ', challengeATC.address.toString());
    // run methods on `challengeNFTCollection`
}
