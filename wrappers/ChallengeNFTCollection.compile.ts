import { CompilerConfig } from '@ton/blueprint';

export const compile: CompilerConfig = {
    lang: 'tact',
    target: 'contracts/challenge_nfts.tact',
    options: {
        debug: true,
    },
};
