import { CompilerConfig } from '@ton/blueprint';

export const compile: CompilerConfig = {
    lang: 'tact',
    target: 'contracts/challenge_n_f_t_collection.tact',
    options: {
        debug: true,
    },
};