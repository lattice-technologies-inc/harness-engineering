# harness/no-eval

Block `eval()` and `new Function()`.

## Why

Both are code injection vectors and make programs opaque to static analysis. Agents cannot reason about dynamically generated code, and neither can linters, bundlers, or security scanners.

## Examples

### Bad

```js
const result = eval(userInput);
const fn = new Function("a", "b", "return a + b");
```

### Good

```js
const operations = { add: (a, b) => a + b, sub: (a, b) => a - b };
const result = operations[op](a, b);
```

## When to Disable

Template engines or sandboxed environments that genuinely require dynamic code generation. Use inline disable with a justification comment.
