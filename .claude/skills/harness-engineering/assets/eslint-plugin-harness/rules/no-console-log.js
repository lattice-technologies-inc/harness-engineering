"use strict";

const DISALLOWED = new Set(["log", "debug", "info"]);

module.exports = {
  meta: {
    type: "problem",
    docs: {
      description: "Disallow committed console.log/debug/info in favor of structured logging.",
    },
    schema: [],
    messages: {
      noConsoleLog:
        "Do not commit console.{{method}}. Use the project's structured logger instead (see docs/golden-principles.md).",
    },
  },

  create(context) {
    return {
      CallExpression(node) {
        const callee = node.callee;
        if (!callee || callee.type !== "MemberExpression") return;
        if (callee.computed) return;

        const obj = callee.object;
        const prop = callee.property;

        if (!obj || obj.type !== "Identifier" || obj.name !== "console") return;
        if (!prop || prop.type !== "Identifier") return;

        if (!DISALLOWED.has(prop.name)) return;

        context.report({
          node,
          messageId: "noConsoleLog",
          data: { method: prop.name },
        });
      },
    };
  },
};

