import { describe, test } from '@e2e-dev/mobile';
import { expect, type Screen } from 'e2e';
import { launchFreshApp } from './support/launch.ts';

async function saveElephant(screen: Screen): Promise<void> {
  await screen.getByRole('button', 'Elephant').tap();
  await screen.getByRole('button', 'Save favorite').tap();
}

describe('parent favorites', { platforms: ['ios'], tags: ['favorites'] }, () => {
  launchFreshApp();

  test('a saved word appears behind the parent hold and can be removed', async ({ screen }) => {
    await saveElephant(screen);
    await expect(screen.getByRole('button', 'Remove favorite')).toBeVisible();

    await screen.getByRole('tab', 'Parent').tap();
    await expect(screen.getByTestId('parent-unlock')).toHaveAccessibleName(
      'Hold for two seconds to open parent space',
    );
    await screen.getByTestId('parent-unlock').longPress({ duration: 3000 });

    await expect(screen.getByText('Saved words')).toBeVisible();
    await expect(screen.getByText('No stored speech')).toBeVisible();
    await expect(screen.getByRole('button', 'Hear elephant')).toBeVisible();
    await expect(screen.getByText('0 practice taps')).toBeVisible();

    await screen.getByRole('button', 'Remove elephant').tap();
    await expect(screen.getByText('No saved words yet')).toBeVisible();
    await expect(screen.getByRole('button', 'Remove elephant')).toBeHidden();
  });

  test('a saved word is still there after the app relaunches', async ({ app, screen }) => {
    await saveElephant(screen);
    await app.restart();

    await screen.getByRole('tab', 'Parent').tap();
    await screen.getByTestId('parent-unlock').longPress({ duration: 3000 });

    await expect(screen.getByText('ಆನೆ')).toBeVisible();
    await expect(screen.getByRole('button', 'Hear elephant')).toBeVisible();
    await expect(screen.getByRole('button', 'Remove elephant')).toBeVisible();
  });
});
