"use strict";

const path = require("path");

function normalizeName(s) {
  return String(s)
    .replace(/\.[^.]+$/, "")
    .replace(/[^a-zA-Z0-9]+/g, " ")
    .trim()
    .toLowerCase()
    .replace(/\s+/g, "");
}

function getFileBaseName(filename) {
  const base = path.basename(filename);
  return base.replace(/\.(js|cjs|mjs|ts|tsx)$/, "");
}

function getExportName(node) {
  // export function Foo() {}
  // export class Foo {}
  // export const Foo = ...
  if (!node || node.type !== "ExportNamedDeclaration") return null;
  const decl = node.declaration;
  if (!decl) return null;

  if (decl.type === "FunctionDeclaration" || decl.type === "ClassDeclaration") {
    return decl.id && decl.id.name ? decl.id.name : null;
  }

  if (decl.type === "VariableDeclaration") {
    if (!decl.declarations || decl.declarations.length !== 1) return null;
    const d0 = decl.declarations[0];
    if (!d0 || !d0.id || d0.id.type !== "Identifier") return null;
    return d0.id.name;
  }

  return null;
}

module.exports = {
  meta: {
    type: "suggestion",
    docs: {
      description:
        "When a file has exactly one named export, enforce that filename matches the export name (legibility for agents).",
    },
    schema: [],
    messages: {
      mismatch:
        "Filename '{{file}}' should match exported symbol '{{exportName}}' (or rename the export). This keeps code mechanically discoverable for agents.",
    },
  },

  create(context) {
    const filename = context.getFilename();
    if (!filename || filename === "<input>") return {};

    const base = getFileBaseName(filename);
    if (base === "index") return {};

    return {
      "Program:exit"(program) {
        const body = program.body || [];
        const exportNodes = body.filter(
          (n) => n && (n.type === "ExportNamedDeclaration" || n.type === "ExportDefaultDeclaration")
        );

        // Only enforce the simple, high-signal case: exactly one named export declaration.
        const namedExports = exportNodes.filter((n) => n.type === "ExportNamedDeclaration");
        if (namedExports.length !== 1) return;

        const exportName = getExportName(namedExports[0]);
        if (!exportName) return;

        if (normalizeName(base) === normalizeName(exportName)) return;

        context.report({
          node: namedExports[0],
          messageId: "mismatch",
          data: { file: base, exportName },
        });
      },
    };
  },
};

