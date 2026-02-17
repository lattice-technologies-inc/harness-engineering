"use strict";

/**
 * Enforce a maximum number of lines per file.
 *
 * Unlike ESLint's built-in max-lines, this rule:
 * - Has an agent-readable message pointing to golden-principles.md
 * - Defaults to 500 lines (the harness standard)
 * - Suggests splitting strategies in the error message
 */

module.exports = {
  meta: {
    type: "suggestion",
    docs: {
      description:
        "Enforce maximum file length to keep code legible for agents and humans.",
    },
    schema: [
      {
        type: "object",
        properties: {
          max: { type: "integer", minimum: 1 },
          skipBlankLines: { type: "boolean" },
          skipComments: { type: "boolean" },
        },
        additionalProperties: false,
      },
    ],
    messages: {
      tooLong:
        "File has {{actual}} lines (max {{max}}). Split into smaller modules — extract helpers, separate types, or break along domain boundaries. See docs/golden-principles.md.",
    },
  },

  create(context) {
    const options = context.options[0] || {};
    const max = options.max || 500;
    const skipBlankLines = options.skipBlankLines !== false;
    const skipComments = options.skipComments !== false;

    return {
      "Program:exit"(program) {
        const sourceCode = context.getSourceCode();
        const lines = sourceCode.lines;

        let count = 0;
        const comments = skipComments
          ? new Set(
              sourceCode
                .getAllComments()
                .flatMap((c) => {
                  const result = [];
                  for (let i = c.loc.start.line; i <= c.loc.end.line; i++) {
                    result.push(i);
                  }
                  return result;
                })
            )
          : new Set();

        for (let i = 0; i < lines.length; i++) {
          const lineNumber = i + 1;

          if (skipBlankLines && lines[i].trim() === "") continue;
          if (skipComments && comments.has(lineNumber)) continue;

          count++;
        }

        if (count > max) {
          context.report({
            node: program,
            messageId: "tooLong",
            data: {
              actual: String(count),
              max: String(max),
            },
          });
        }
      },
    };
  },
};
