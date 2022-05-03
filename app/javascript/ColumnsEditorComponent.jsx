import { KramdownExtensionRegex, parseKramdownExtensions } from "./kramdown";

/*
This file provides a set of editor components for common columnar layouts.

In the Markdown, columns are stored like so:

    {::columns type="two-column"}
      {::column}
        Left column content
      {:/column}
      {::column}
        Right column content
      {:/column}
    {:/columns}


*/

/**
 *
 * @param {{
 *  id: string,
 *  label: string,
 *  columns: string[],
 * }} param0
 * @returns
 */
function createColumnsComponent({ id, label, columns }) {
  return {
    id,
    label,
    fields: [
      ...columns.map((name) => ({
        name,
        widget: "markdown",
      })),
    ],
    pattern: KramdownExtensionRegex,
    toPreview(data) {
      throw new Error();
    },
    fromBlock: (match) => {
      if (match) {
        const parsed = parseKramdownExtensions(match[0]);
        console.log(parsed);
        const ext = parsed.find((el) => typeof el !== "string");
        if (ext) {
        }
      }
      return {
        type: id,
        columns: columns.map((type) => ({
          type,
          content: "",
        })),
      };
    },
    toBlock: () => {
      throw new Error();
    },
  };
}

export const TwoColumns = createColumnsComponent({
  id: "columns-2",
  label: "Two Columns (50/50)",
  columns: ["left", "right"],
});

export const ThreeColumns = createColumnsComponent({
  id: "columns-3",
  label: "Three Columns",
  columns: ["left", "center", "right"],
});
