import { TwoColumns } from "./ColumnsEditorComponent";

describe("TwoColumns", () => {
  const example = `
Here is some preamble text

{::columns type="two-columns"}
  {::column}
    Here is the left column content
    It is spread across multiple lines.
  {:/column}
  {::column}Here is the right column content{:/column}
{:/columns}

`;
  describe("#fromBlock", () => {
    it("can read a two-column layout", () => {
      const m = example.match(TwoColumns.pattern);
      expect(m).toBeTruthy();
      const data = TwoColumns.fromBlock(m);
      expect(data).toStrictEqual({
        type: "two-columns",
        columns: [
          {
            content:
              "Here is the left column content\n    It is spread across multiple lines.",
          },
          { content: "Here is the right column content" },
        ],
      });
    });
  });
});
