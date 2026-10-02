import { describe, test } from '@e2e-dev/mobile';
import { expect } from 'e2e';
import { launchFreshApp } from './support/launch.ts';

describe('home lookup', { platforms: ['ios'], tags: ['home'] }, () => {
  launchFreshApp();

  test('a suggested word opens its Kannada card', async ({ screen }) => {
    await screen.getByRole('button', 'Elephant').tap();

    await expect(screen.getByText('ಆನೆ')).toBeVisible();
    await expect(screen.getByText('aane')).toBeVisible();
    await expect(screen.getByText('Elephant')).toBeVisible();
    await expect(screen.getByRole('button', 'Listen')).toBeEnabled();
    await expect(screen.getByRole('button', 'Save favorite')).toBeEnabled();
    await expect(screen.getByRole('button', 'Try another word')).toBeVisible();
  });

  test('a spoken-style phrase resolves to the curated word', async ({ screen }) => {
    const field = screen.getByRole('textbox', 'Type a word');
    await field.fill('this is a mango');
    await screen.getByRole('button', 'Look up word').tap();

    await expect(screen.getByText('ಮಾವಿನಹಣ್ಣು')).toBeVisible();
    await expect(screen.getByText('maavinahannu')).toBeVisible();
    await expect(screen.getByText('Mango')).toBeVisible();
    await expect(screen.getByRole('button', 'Listen')).toBeEnabled();
  });

  test('the simulator microphone uses the typed word', async ({ screen }) => {
    await screen.getByRole('button', 'Start listening').tap();
    await expect(
      screen.getByText('Simulator voice input is limited. Type a word below, then tap the mic.'),
    ).toBeVisible();

    await screen.getByRole('textbox', 'Type a word').fill('dog');
    await screen.getByRole('button', 'Start listening').tap();

    await expect(screen.getByText('ನಾಯಿ')).toBeVisible();
    await expect(screen.getByText('naayi')).toBeVisible();
    await expect(screen.getByText('Dog')).toBeVisible();
  });

  test('an unknown word stays in the library fallback', async ({ screen }) => {
    const field = screen.getByRole('textbox', 'Type a word');
    await field.fill('spaceship');
    await screen.getByRole('button', 'Look up word').tap();

    await expect(screen.getByText('Not in library yet')).toBeVisible();
    await expect(screen.getByText('Try a family word, animal, or fruit from the Library.')).toBeVisible();
    await expect(screen.getByRole('button', 'Listen')).toBeDisabled();
    await expect(screen.getByRole('button', 'Save favorite')).toBeDisabled();
  });

  test('try another returns to the home choices', async ({ screen }) => {
    await screen.getByRole('button', 'Elephant').tap();
    await expect(screen.getByText('ಆನೆ')).toBeVisible();

    await screen.getByRole('button', 'Try another word').tap();

    await expect(screen.getByText('ಆನೆ')).toBeHidden();
    await expect(screen.getByText('Ask without recording')).toBeVisible();
    await expect(screen.getByRole('button', 'Elephant')).toBeVisible();
  });

  test('what is that answers with the selected picture', async ({ screen }) => {
    await screen.getByRole('button', 'Answer what is that in Kannada').tap();

    await expect(screen.getByText('ಅಮ್ಮ')).toBeVisible();
    await expect(screen.getByText('amma')).toBeVisible();
    await expect(screen.getByRole('button', 'Listen')).toBeEnabled();
    await expect(screen.getByRole('button', 'Save favorite')).toBeEnabled();
  });
});
