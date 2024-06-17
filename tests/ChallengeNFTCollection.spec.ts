import { Blockchain, SandboxContract, TreasuryContract } from '@ton/sandbox';
import { toNano } from '@ton/core';
import { ChallengeNFTCollection } from '../wrappers/ChallengeNFTCollection';
import '@ton/test-utils';

describe('ChallengeNFTCollection', () => {
    let blockchain: Blockchain;
    let deployer: SandboxContract<TreasuryContract>;
    let challengeNFTCollection: SandboxContract<ChallengeNFTCollection>;

    beforeEach(async () => {
        blockchain = await Blockchain.create();

        challengeNFTCollection = blockchain.openContract(await ChallengeNFTCollection.fromInit());

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

    it('should deploy', async () => {
        // the check is done inside beforeEach
        // blockchain and challengeNFTCollection are ready to use
    });
});
