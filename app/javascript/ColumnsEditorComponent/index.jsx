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
 */
function createColumnsComponent({ id, label, columnNames }) {
  return {
    id,
    label,
    fields: [
      ...columnNames.map((name) => ({
        name,
        widget: "markdown",
      })),
    ],
    pattern: createKramdownExtensionRegex("columns", "type", id),
    toPreview(data, getAsset) {
      const columnContents = columnNames.map((name) =>
        String(data[name] ?? "")
      );

      return (
        <Preview
          columnNames={columnNames}
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

          const result = {
            type: id,
          };
          columnNames.forEach((type, index) => {
            result[type] = serializeKramdownExtensionNodes(
              columnElements[index]?.children ?? []
            );
          });

          return result;
        }
      }

      const defaultResult = {
        type: id,
      };
      columnNames.forEach((type) => {
        defaultResult[type] = "";
      });
      return defaultResult;
    },
    toBlock: (data) =>
      `{::columns type="${data.type}"}
${columnNames
  .map((type) => `{::column}${data[type] ?? ""}{:/column}`)
  .join("\n")}
{:/columns}`,
  };
}

export const TwoColumns = createColumnsComponent({
  id: "columns-2",
  label: "Two Columns (50/50)",
  columnNames: ["left", "right"],
});

export const ThreeColumns = createColumnsComponent({
  id: "columns-3",
  label: "Three Columns",
  columnNames: ["left", "center", "right"],
});

export const FourColumns = createColumnsComponent({
  id: "columns-4",
  label: "Four Columns",
  columnNames: ["Column 1", "Column 2", "Column 3", "Column 4"],
});
