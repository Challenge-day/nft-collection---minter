import { Address, toNano } from '@ton/core';
import { collection } from '../wrappers/all';
import { NetworkProvider } from '@ton/blueprint';

const ADDR = 'EQDcR3t9euaiZT1k9429nwWPoeEGOAJBAPIVr3DQhcK0j49_';

export async function run(provider: NetworkProvider) {
    const challengeNFTCollection = provider.open(collection.ChallengeNFTCollection.fromAddress(Address.parse(ADDR)));

    // await challengeNFTCollection.send(
    //     provider.sender(),
    //     {
    //         value: toNano('0.05'),
    //     },
    //     'mint_one_for_self',
    // );

    await challengeNFTCollection.send(
        provider.sender(),
        { value: toNano('0.05') },
        "reap",
    );

    // run methods on `challengeNFTCollection`
}
