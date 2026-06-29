// my-node-package — library + CLI entry
// `personalize.py` will rename the exported symbols + package metadata.

export const hello = (name: string): string => `hello, ${name}!`;

if (import.meta.url === `file://${process.argv[1]}`) {
  const target = process.argv[2] ?? 'world';
  console.log(hello(target));
}
