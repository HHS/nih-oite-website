// XXX: This "mocks" include is required to monkey-patch some browser APIs not
//      available in Node.
import "./mocks";
import createColumnsComponent from ".";

describe("TwoColumns", () => {
  const TwoColumns = createColumnsComponent({
    label: "Two Columns",
    columns: [
      { name: "left", span: 6 },
      { name: "right", span: 6 },
    ],
  });

  const example = `
Here is some preamble text

{::columns span="6,6"}
{::column}
Here is the left column content
{::video url="https://www.youtube.com/watch?v=SAK117AmzSE" /}
(That was a video)
{:/column}
{::column}
Here is the right column content
{:/column}
{:/columns}

`;
  describe("#fromBlock", () => {
    it("can read a two-column layout", () => {
      const m = example.match(TwoColumns.pattern);
      expect(m).toBeTruthy();
      const data = TwoColumns.fromBlock(m);
      expect(data).toStrictEqual({
        left: '\nHere is the left column content\n{::video url="https://www.youtube.com/watch?v=SAK117AmzSE"/}\n(That was a video)\n',
        right: "\nHere is the right column content\n",
      });
    });
  });
  describe("#toBlock", () => {
    it("can serialize a two-column layout", () => {
      const data = {
        left: "Here is the left column content\nIt is spread across multiple lines.",
        right: "Here is the right column content",
      };
      const actual = TwoColumns.toBlock(data);
      expect(actual).toStrictEqual(
        `
{::columns span="6,6"}
{::column}
Here is the left column content
It is spread across multiple lines.
{:/column}
{::column}
Here is the right column content
{:/column}
{:/columns}
`.trim()
      );
    });
  });
});
