import { existsSync } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { beforeEach } from '@e2e-dev/mobile';
import { simulatorAppPath } from './simulator-app.ts';

const projectRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../..');
let installed = false;

/** Install the simulator build once per worker, then relaunch with empty local data. */
export function launchFreshApp(): void {
  beforeEach(async ({ app, device }) => {
    if (!installed) {
      const resolved = path.resolve(projectRoot, simulatorAppPath);
      if (!existsSync(resolved)) {
        throw new Error(
          `No simulator build at ${simulatorAppPath}. Build it from the repo root with xcodebuild (see README.md), or set E2E_APP_PATH to a simulator .app bundle.`,
        );
      }
      await device.installApp(simulatorAppPath);
      installed = true;
    }
    await app.clearState();
  });
}
