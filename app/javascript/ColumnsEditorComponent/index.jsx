import React from "react";
import {
  createKramdownExtensionRegex,
  parseKramdownExtensions,
  serializeKramdownExtensionNodes,
} from "../kramdown";
import Preview from "./Preview";

/*
This file provides a set of editor components for common columnar layouts.

In the Markdown, columns are stored like so:

    {::columns type="columns-2"}
    {::column}
    Left column content
    {:/column}
    {::column}
    Right column content
    {:/column}
    {:/columns}

*/

/**
 * @typedef {Object} ColumnSpec
 * @property {string} name
 * @property {number} span
 */

/**
 * @typedef {Object} CreateColumnsComponentOptions
 * @property {string} label Friendly label describing the component.
 * @property {ColumnSpec[]} columns
 * @property {string[]} editorComponents IDs of editor components allowed.
 */

/**
 * @param {CreateColumnsComponentOptions} options
 */
export default function createColumnsComponent({
  label,
  columns,
  editorComponents,
}) {
  // "span" is a comma-delimited string of the individual column spans used.
  // In Markdown it is stored as an attribute on the {::columns} element.
  const span = columns.map((col) => col.span).join(",");

  return {
    id: `columns-${span.replace(/,/g, "-")}`,
    label,
    fields: [
      ...columns.map(({ name }) => ({
        name,
        widget: "markdown",
        editor_components: editorComponents,
      })),
    ],
    pattern: createKramdownExtensionRegex("columns", "span", span),
    toPreview(data, getAsset) {
      const columnContents = columns.map(({ name }) =>
        String(data[name] ?? "")
      );

      return (
        <Preview
          columns={columns}
          columnContents={columnContents}
          getAsset={getAsset}
        />
      );
    },
    fromBlock: (match) => {
      if (match) {
        const parsed = parseKramdownExtensions(match[0]);
        const columnsElement = parsed.find(
          (el) => typeof el !== "string" && el.name === "columns"
        );

        if (columnsElement) {
          const columnElements = columnsElement.children.filter(
            (t) => typeof t === "object" && t.name === "column"
          );

          return columns.reduce(
            (result, { name }, index) => ({
              ...result,
              [name]: serializeKramdownExtensionNodes(
                columnElements[index]?.children ?? []
              ),
            }),
            {}
          );
        }
      }

      return columns.reduce(
        (result, { name }) => ({ ...result, [name]: "" }),
        {}
      );
    },
    toBlock: (data) =>
      `{::columns span="${span}"}
${columns
  .map(({ name }) => `{::column}\n${data[name] ?? ""}\n{:/column}`)
  .join("\n")}
{:/columns}`,
  };
}
