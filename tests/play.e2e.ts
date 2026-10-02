import { describe, test } from '@e2e-dev/mobile';
import { expect } from 'e2e';
import { launchFreshApp } from './support/launch.ts';

describe('play practice', { platforms: ['ios'], tags: ['play'] }, () => {
  launchFreshApp();

  test('flashcards reveal Kannada for the first word', async ({ screen }) => {
    await screen.getByRole('tab', 'Play').tap();

    await expect(screen.getByText('See the picture, then reveal Kannada')).toBeVisible();
    await expect(screen.getByTestId('practice-count')).toHaveAccessibleName('0 of 18 words practiced');
    await expect(screen.getByTestId('flashcard')).toHaveAccessibleName('Mother');

    await screen.getByRole('button', 'Show').tap();

    await expect(screen.getByTestId('flashcard')).toHaveAccessibleName('Mother, ಅಮ್ಮ, amma');
    await expect(screen.getByRole('button', 'Hide')).toBeVisible();
    await expect(screen.getByTestId('practice-count')).toHaveAccessibleName('1 of 18 words practiced');
  });

  test('the quiz shows a picture and a way to skip it', async ({ screen }) => {
    await screen.getByRole('tab', 'Play').tap();
    await screen.getByRole('tab', 'Quiz').tap();

    await expect(screen.getByTestId('quiz-prompt')).toHaveAccessibleName('Quiz picture for a Family word');
    await expect(screen.getByRole('button', 'Skip')).toBeVisible();

    await screen.getByRole('button', 'Skip').tap();
    await expect(screen.getByTestId('quiz-prompt')).toHaveAccessibleName('Quiz picture for a Family word');
    await expect(screen.getByRole('button', 'Skip')).toBeVisible();
  });

  test('object walk looks, hears, says, and matches the picture', async ({ screen }) => {
    await screen.getByRole('tab', 'Play').tap();
    await screen.getByRole('tab', 'Walk').tap();

    await expect(screen.getByText('Find: Mother')).toBeVisible();
    const foundIt = screen.getByRole('button', 'I found it');
    await screen.scrollUntilVisible(foundIt);
    await foundIt.tap();

    const hear = screen.getByRole('button', /Hear/);
    await screen.scrollUntilVisible(hear);
    await hear.tap();
    await expect(screen.getByText('ಅಮ್ಮ')).toBeVisible();
    await expect(screen.getByText('amma')).toBeVisible();

    const saidIt = screen.getByRole('button', 'I said it');
    await screen.scrollUntilVisible(saidIt);
    await saidIt.tap();

    const mother = screen.getByRole('button', 'Mother');
    await screen.scrollUntilVisible(mother);
    await mother.tap();

    await expect(screen.getByText('You found ಅಮ್ಮ')).toBeVisible();
    await expect(screen.getByRole('button', 'Next object')).toBeVisible();
    await expect(screen.getByTestId('practice-count')).toHaveAccessibleName('1 of 18 words practiced');
  });
});
