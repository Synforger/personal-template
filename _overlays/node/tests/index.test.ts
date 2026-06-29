import { describe, expect, it } from 'vitest';
import { hello } from '../src/index.js';

describe('hello', () => {
  it('greets the named target', () => {
    expect(hello('world')).toBe('hello, world!');
  });
});
