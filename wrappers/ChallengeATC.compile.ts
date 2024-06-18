import { CompilerConfig } from '@ton/blueprint';

export const compile: CompilerConfig = {
    lang: 'tact',
    target: 'contracts/challenge_atc.tact',
    options: {
        debug: true,
    },
};
