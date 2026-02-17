#!/usr/bin/env bash
set -euo pipefail

# Harness Engineering — ESLint Add-on
#
# Scaffolds a tiny local ESLint plugin + config designed to steer agents via invariant enforcement.
# Usage:
#   bash add-eslint-agent-lints.sh --target <repo-root> [--install] [--pm npm|pnpm|yarn|bun]

TARGET_DIR="."
DO_INSTALL=0
PM=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target) TARGET_DIR="$2"; shift 2 ;;
    --install) DO_INSTALL=1; shift 1 ;;
    --pm) PM="$2"; shift 2 ;;
    -h|--help)
      echo "Usage: add-eslint-agent-lints.sh --target <repo-root> [--install] [--pm npm|pnpm|yarn|bun]"
      exit 0 ;;
    *) echo "Unknown arg: $1" >&2; exit 1 ;;
  esac
done

TARGET_DIR=$(cd "$TARGET_DIR" && pwd)

if [[ ! -f "${TARGET_DIR}/package.json" ]]; then
  echo "ERROR: package.json not found at ${TARGET_DIR}. This add-on is for JS/TS repos." >&2
  exit 1
fi

ASSETS_DIR="$(cd "$(dirname "$0")/../assets/eslint-plugin-harness" && pwd)"
DEST_PLUGIN_DIR="${TARGET_DIR}/tools/eslint-plugin-harness"

mkdir -p "${TARGET_DIR}/tools"

if [[ -d "$DEST_PLUGIN_DIR" ]]; then
  echo "SKIP: ${DEST_PLUGIN_DIR} already exists"
else
  # Copy the plugin skeleton (small, no deps).
  cp -R "$ASSETS_DIR" "$DEST_PLUGIN_DIR"
  echo "CREATE: ${DEST_PLUGIN_DIR}"
fi

ESLINT_CONFIG="${TARGET_DIR}/eslint.config.cjs"
if [[ -f "$ESLINT_CONFIG" ]]; then
  echo "SKIP: eslint.config.cjs already exists"
else
  cat > "$ESLINT_CONFIG" <<'EOF'
/* eslint-env node */
const harness = require("./tools/eslint-plugin-harness");

let tsParser = null;
try {
  tsParser = require("@typescript-eslint/parser");
} catch (_err) {
  // TypeScript linting is enabled only when @typescript-eslint/parser is installed.
}

module.exports = [
  {
    ignores: [
      "**/node_modules/**",
      "**/dist/**",
      "**/build/**",
      "**/.next/**",
      "**/coverage/**",
    ],
  },
  {
    files: ["**/*.{js,cjs,mjs}"],
    languageOptions: { ecmaVersion: "latest", sourceType: "module" },
    plugins: { harness },
    rules: {
      // Agent steering: prefer structured logging; no committed console.log.
      "harness/no-console-log": "error",

      // Grep-ability: named exports only (agents can ripgrep for definitions).
      "harness/no-default-export": "warn",

      // Security: block eval() and new Function().
      "harness/no-eval": "error",

      // Enforce structured logging (static message + metadata object).
      "harness/structured-logging": "error",

      // Keep files small to preserve legibility (see docs/golden-principles.md).
      "harness/max-file-lines": ["warn", { max: 500 }],
    },
  },
  ...(tsParser
    ? [
        {
          files: ["**/*.{ts,tsx}"],
          languageOptions: {
            ecmaVersion: "latest",
            sourceType: "module",
            parser: tsParser,
          },
          plugins: { harness },
          rules: {
            "harness/no-console-log": "error",
            "harness/no-default-export": "warn",
            "harness/no-eval": "error",
            "harness/structured-logging": "error",
            "harness/max-file-lines": ["warn", { max: 500 }],
          },
        },
      ]
    : []),
];
EOF
  echo "CREATE: eslint.config.cjs"
fi

node - <<'EOF' "$TARGET_DIR"
const fs = require("fs");
const path = require("path");

const targetDir = process.argv[2];
const pkgPath = path.join(targetDir, "package.json");
const pkg = JSON.parse(fs.readFileSync(pkgPath, "utf8"));

pkg.scripts ||= {};
pkg.scripts.lint ||= "eslint .";

fs.writeFileSync(pkgPath, JSON.stringify(pkg, null, 2) + "\n");
EOF
echo "UPDATE: package.json scripts.lint (if missing)"

detect_pm() {
  if [[ -n "$PM" ]]; then
    echo "$PM"
    return
  fi
  if [[ -f "${TARGET_DIR}/pnpm-lock.yaml" ]]; then echo "pnpm"; return; fi
  if [[ -f "${TARGET_DIR}/yarn.lock" ]]; then echo "yarn"; return; fi
  if [[ -f "${TARGET_DIR}/bun.lockb" ]]; then echo "bun"; return; fi
  if [[ -f "${TARGET_DIR}/package-lock.json" ]]; then echo "npm"; return; fi
  echo "npm"
}

if [[ "$DO_INSTALL" -eq 1 ]]; then
  pm=$(detect_pm)
  echo "INSTALL: using package manager: ${pm}"

  # Install eslint. Only add TS parser if the repo has TypeScript files.
  HAS_TS=0
  if compgen -G "${TARGET_DIR}/**/*.ts" >/dev/null 2>&1 || compgen -G "${TARGET_DIR}/src/**/*.ts" >/dev/null 2>&1 || compgen -G "${TARGET_DIR}/tsconfig*.json" >/dev/null 2>&1; then
    HAS_TS=1
  fi

  if [[ "$HAS_TS" -eq 1 ]]; then
    DEPS="eslint @typescript-eslint/parser"
    echo "INSTALL: TypeScript detected, including @typescript-eslint/parser"
  else
    DEPS="eslint"
    echo "INSTALL: No TypeScript detected, skipping @typescript-eslint/parser"
  fi

  case "$pm" in
    pnpm) (cd "$TARGET_DIR" && pnpm add -D $DEPS) ;;
    yarn) (cd "$TARGET_DIR" && yarn add -D $DEPS) ;;
    bun)  (cd "$TARGET_DIR" && bun add -d $DEPS) ;;
    npm)  (cd "$TARGET_DIR" && npm install -D $DEPS) ;;
    *) echo "ERROR: unknown package manager: $pm" >&2; exit 1 ;;
  esac
else
  echo "NOTE: dependencies not installed. To enable TS linting, install: eslint @typescript-eslint/parser"
fi

echo ""
echo "Next steps:"
echo "  1. Run: npm run lint (or your package manager equivalent)"
echo "  2. Add or tune rules to match your repo conventions"
echo "  3. Wire lint into CI once it’s stable"

