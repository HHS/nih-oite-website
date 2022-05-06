import "./mocks";
import { TwoColumns } from ".";

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
        type: "columns-2",
        left: "\nHere is the left column content\nIt is spread across multiple lines.\n",
        right: "Here is the right column content",
      });
    });
  });
  describe("#toBlock", () => {
    it("can serialize a two-column layout", () => {
      const data = {
        type: "columns-2",
        left: "\nHere is the left column content\nIt is spread across multiple lines.\n",
        right: "Here is the right column content",
      };
      const actual = TwoColumns.toBlock(data);
      expect(actual).toStrictEqual(
        `
{::columns type="columns-2"}
{::column}
Here is the left column content
It is spread across multiple lines.
{:/column}
{::column}Here is the right column content{:/column}
{:/columns}
`.trim()
      );
    });
  });
});
