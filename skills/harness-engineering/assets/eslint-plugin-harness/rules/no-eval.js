"use strict";

module.exports = {
  meta: {
    type: "problem",
    docs: {
      description:
        "Disallow eval() and new Function() to prevent code injection and improve agent safety.",
    },
    schema: [],
    messages: {
      noEval:
        "Do not use `eval()`. It enables code injection and makes the program opaque to static analysis. Refactor to use a safe alternative. See docs/golden-principles.md.",
      noNewFunction:
        "Do not use `new Function()`. It is equivalent to eval and enables code injection. Use a regular function or a lookup table instead. See docs/golden-principles.md.",
    },
  },

  create(context) {
    return {
      CallExpression(node) {
        if (
          node.callee.type === "Identifier" &&
          node.callee.name === "eval"
        ) {
          context.report({ node, messageId: "noEval" });
        }
      },

      NewExpression(node) {
        if (
          node.callee.type === "Identifier" &&
          node.callee.name === "Function"
        ) {
          context.report({ node, messageId: "noNewFunction" });
        }
      },
    };
  },
};
