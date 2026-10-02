import type { E2EConfig } from 'e2e';
import { mobile } from '@e2e-dev/mobile';
import { simulatorAppPath } from './tests/support/simulator-app.ts';

export default {
  tests: 'tests/**/*.e2e.ts',
  workers: 1,
  targets: [
    {
      name: 'ios',
      engine: mobile({
        platform: 'ios',
        device: process.env.E2E_DEVICE,
      }),
      app: {
        bundleId: 'app.whatsthiskannada',
        appPath: simulatorAppPath,
      },
    },
  ],
} satisfies E2EConfig;
