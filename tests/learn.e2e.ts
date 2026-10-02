import { describe, test } from '@e2e-dev/mobile';
import { expect } from 'e2e';
import { launchFreshApp } from './support/launch.ts';

describe('learn library', { platforms: ['ios'], tags: ['learn'] }, () => {
  launchFreshApp();

  test('a home category opens that shelf and then the word', async ({ screen }) => {
    await screen.getByRole('button', 'Open Fruits in Learn').tap();

    await expect(screen.getByText('ಹಣ್ಣುಗಳು')).toBeVisible();
    await expect(screen.getByText('Fruits · tap a card to open it')).toBeVisible();

    await screen.getByTestId('word-maavinahannu').tap();

    await expect(screen.getByText('Also matches')).toBeVisible();
    await expect(screen.getByText('ಮಾವಿನಹಣ್ಣು')).toBeVisible();
    await expect(screen.getByText('maavinahannu')).toBeVisible();
    await expect(screen.getByRole('button', /Listen/)).toBeVisible();
    await expect(screen.getByRole('button', 'Save favorite')).toBeVisible();
  });

  test('search finds one word and an unknown query shows the empty state', async ({ screen }) => {
    await screen.getByRole('tab', 'Learn').tap();

    const search = screen.getByPlaceholder('Search words');
    await search.tap();
    await search.fill('ajji');
    await expect(screen.getByTestId('word-ajji')).toBeVisible();
    await expect(screen.getByTestId('word-aane')).toHaveCount(0);

    await search.fill('elephant');
    await expect(screen.getByTestId('word-aane')).toBeVisible();
    await expect(screen.getByTestId('word-iruve')).toHaveCount(0);

    await search.fill('spaceship');
    await expect(screen.getByText('No words found')).toBeVisible();
    await expect(screen.getByText('Try a family word, animal, or fruit.')).toBeVisible();
  });

  test('browse mode steps to the next word', async ({ screen }) => {
    await screen.getByRole('tab', 'Learn').tap();
    await screen.getByRole('tab', 'Browse').tap();

    await expect(screen.getByText('ಅಮ್ಮ')).toBeVisible();
    await expect(screen.getByText('1 of 59')).toBeVisible();

    await screen.getByRole('button', 'Next word').tap();

    await expect(screen.getByText('ಅಪ್ಪ')).toBeVisible();
    await expect(screen.getByText('2 of 59')).toBeVisible();
  });
});
