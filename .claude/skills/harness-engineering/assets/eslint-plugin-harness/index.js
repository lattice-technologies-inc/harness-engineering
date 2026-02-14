/**
 * @fileoverview Tiny, repo-local ESLint plugin intended to steer agents with crisp remediation messages.
 *
 * This is intentionally small: copy patterns, then tailor rules to your repo.
 * Each rule has a README.md explaining why it exists and how to fix violations.
 */
"use strict";

module.exports = {
  rules: {
    "no-console-log": require("./rules/no-console-log"),
    "filename-match-export": require("./rules/filename-match-export"),
    "structured-logging": require("./rules/structured-logging"),
    "max-file-lines": require("./rules/max-file-lines"),
  },
  configs: {
    recommended: {
      plugins: ["harness"],
      rules: {
        "harness/no-console-log": "error",
        "harness/structured-logging": "error",
        "harness/max-file-lines": ["warn", { max: 500 }],
      },
    },
    strict: {
      plugins: ["harness"],
      rules: {
        "harness/no-console-log": "error",
        "harness/filename-match-export": "warn",
        "harness/structured-logging": "error",
        "harness/max-file-lines": ["error", { max: 500 }],
      },
    },
  },
};
