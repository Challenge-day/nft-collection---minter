import { Address, toNano } from '@ton/core';
import { ChallengeNFTCollection } from '../wrappers/ChallengeNFTCollection';
import { NetworkProvider } from '@ton/blueprint';

const ADDR = 'EQBqtS-X3-B-FR6Xsj9vwxzbVJJu2ogS_jJbETB0kV5q4POL';

export async function run(provider: NetworkProvider) {
    const challengeNFTCollection = provider.open(await ChallengeNFTCollection.fromAddress(Address.parse(ADDR)));

    // await challengeNFTCollection.send(
    //     provider.sender(),
    //     {
    //         value: toNano('0.05'),
    //     },
    //     'mint_one_for_self',
    // );

    await challengeNFTCollection.send(
        provider.sender(),
        { value: toNano('0.03') },
        {
            $$type: 'Mint',
            query_id: 0n,
            quantity: 1n,
            new_owner: Address.parse('0:0de6e7b03cf924ce1fed8f58ec04b1fd21b943326f8beede67f09d96372fc43c'),
        },
    );

    // run methods on `challengeNFTCollection`
}
