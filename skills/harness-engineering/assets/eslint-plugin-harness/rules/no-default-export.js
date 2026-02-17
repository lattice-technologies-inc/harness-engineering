"use strict";

module.exports = {
  meta: {
    type: "suggestion",
    docs: {
      description:
        "Disallow default exports. Named exports are grep-able and make code mechanically discoverable for agents.",
    },
    schema: [],
    messages: {
      noDefault:
        "Use a named export instead of `export default`. Named exports let agents (and humans) find definitions with `ripgrep` and reason about imports deterministically. See docs/golden-principles.md.",
    },
  },

  create(context) {
    return {
      ExportDefaultDeclaration(node) {
        context.report({ node, messageId: "noDefault" });
      },
    };
  },
};
