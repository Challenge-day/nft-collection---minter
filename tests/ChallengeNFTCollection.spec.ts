import { Blockchain, SandboxContract, TreasuryContract } from '@ton/sandbox';
import { beginCell, toNano } from '@ton/core';
import { ChallengeNFTCollection } from '../wrappers/all';
import '@ton/test-utils';

describe('ChallengeNFTCollection', () => {
    let blockchain: Blockchain;
    let deployer: SandboxContract<TreasuryContract>;
    let challengeNFTCollection: SandboxContract<ChallengeNFTCollection>;

    beforeAll(async () => {
        blockchain = await Blockchain.create();

        const OFFCHAIN_TAG = 0x01;
        const BASE_URL = 'https://s.getgems.io/nft/c/665d3d0288f45e66efa10d57/';
        const collectionContent = beginCell().storeInt(OFFCHAIN_TAG, 8).storeStringRefTail(BASE_URL).endCell();

        challengeNFTCollection = blockchain.openContract(await ChallengeNFTCollection.fromInit(collectionContent));

        deployer = await blockchain.treasury('deployer');

        const deployResult = await challengeNFTCollection.send(
            deployer.getSender(),
            {
                value: toNano('0.05'),
            },
            {
                $$type: 'Deploy',
                queryId: 0n,
            },
        );

        expect(deployResult.transactions).toHaveTransaction({
            from: deployer.address,
            to: challengeNFTCollection.address,
            deploy: true,
            success: true,
        });
    });

    it('should dump', async () => {
        const mint = await challengeNFTCollection.send(deployer.getSender(), { value: toNano('0.1') }, "mint_one_for_self");
        console.log(mint.transactions);
    });
});
