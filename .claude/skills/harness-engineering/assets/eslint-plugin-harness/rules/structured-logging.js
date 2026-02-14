"use strict";

/**
 * Enforce structured logging: static message string + metadata object.
 * Disallows template literals and string concatenation in logging calls.
 *
 * Inspired by @factory/structured-logging. Adapted for harness-engineering.
 */

const LOGGING_FUNCTIONS = new Set([
  "log",
  "warn",
  "error",
  "info",
  "debug",
  "trace",
  "fatal",
]);

function isLoggingCall(node) {
  const callee = node.callee;
  if (!callee) return false;

  // logger.info(...), logger.error(...), etc.
  if (
    callee.type === "MemberExpression" &&
    !callee.computed &&
    callee.property.type === "Identifier" &&
    LOGGING_FUNCTIONS.has(callee.property.name)
  ) {
    return true;
  }

  // Direct calls: logError(...), logInfo(...), etc.
  if (callee.type === "Identifier") {
    const name = callee.name.toLowerCase();
    for (const fn of LOGGING_FUNCTIONS) {
      if (name === fn || name === `log${fn}` || name === `log_${fn}`) {
        return true;
      }
    }
  }

  return false;
}

function hasTemplateExpressions(node) {
  return (
    node.type === "TemplateLiteral" &&
    node.expressions &&
    node.expressions.length > 0
  );
}

function isConcatenation(node) {
  return (
    node.type === "BinaryExpression" &&
    node.operator === "+" &&
    (node.left.type === "Literal" ||
      node.left.type === "TemplateLiteral" ||
      node.right.type === "Literal" ||
      node.right.type === "TemplateLiteral" ||
      isConcatenation(node.left) ||
      isConcatenation(node.right))
  );
}

module.exports = {
  meta: {
    type: "problem",
    docs: {
      description:
        "Enforce structured logging with static message strings and metadata objects.",
    },
    schema: [],
    messages: {
      noTemplateLiteral:
        'Do not use template literals in log messages. Use a static string + metadata object instead: logger.error("Failed to process", { userId, orderId }). See docs/golden-principles.md.',
      noConcatenation:
        'Do not concatenate strings in log messages. Use a static string + metadata object instead: logger.info("Request received", { path, method }). See docs/golden-principles.md.',
    },
  },

  create(context) {
    return {
      CallExpression(node) {
        if (!isLoggingCall(node)) return;
        if (!node.arguments || node.arguments.length === 0) return;

        const firstArg = node.arguments[0];

        if (hasTemplateExpressions(firstArg)) {
          context.report({
            node: firstArg,
            messageId: "noTemplateLiteral",
          });
          return;
        }

        if (isConcatenation(firstArg)) {
          context.report({
            node: firstArg,
            messageId: "noConcatenation",
          });
        }
      },
    };
  },
};
