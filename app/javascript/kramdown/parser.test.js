import { parseKramdownExtensions, KramdownExtensionRegex } from "./parser";

describe("Kramdown parser", () => {
  it("can parse a hierarchy", () => {
    const input = `
{::outer name="Outer element"}
{::inner name="inner element 1" /}
some text
{::inner name="inner element 2" /}
{:/outer}

  `.trim();

    const parsed = parseKramdownExtensions(input);

    expect(parsed).toStrictEqual([
      {
        name: "outer",
        attributes: [{ name: "name", value: "Outer element" }],
        children: [
          "\n",
          {
            name: "inner",
            attributes: [{ name: "name", value: "inner element 1" }],
            children: [],
          },
          "\nsome text\n",
          {
            name: "inner",
            attributes: [{ name: "name", value: "inner element 2" }],
            children: [],
          },
          "\n",
        ],
      },
    ]);
  });

  it("supports children that use their own close tags", () => {
    const input = `
Here is some preamble text

{::columns type="two-columns"}
  {::column}
    Here is the left column content
  {:/column}
  {::column}
    Here is the right column content
  {:/column}
{:/columns}

`;

    const parsed = parseKramdownExtensions(input);

    expect(parsed).toStrictEqual([
      "\nHere is some preamble text\n\n",
      {
        name: "columns",
        attributes: [{ name: "type", value: "two-columns" }],
        children: [
          "\n  ",
          {
            name: "column",
            attributes: [],
            children: ["\n    Here is the left column content\n  "],
          },
          "\n  ",
          {
            name: "column",
            attributes: [],
            children: ["\n    Here is the right column content\n  "],
          },
          "\n",
        ],
      },
      "\n\n",
    ]);
  });

  it("supports escaped quotes in attributes", () => {
    const input = `
    {::my_tag attr="\\"some value\\"" /}
    `.trim();
    const parsed = parseKramdownExtensions(input);
    expect(parsed).toStrictEqual([
      {
        name: "my_tag",
        attributes: [{ name: "attr", value: '"some value"' }],
        children: [],
      },
    ]);
  });

  it("supports escaped right braces in attributes", () => {
    const input = `
    {::my_tag attr="some \\} value" /}
    `.trim();
    const parsed = parseKramdownExtensions(input);
    expect(parsed).toStrictEqual([
      {
        name: "my_tag",
        attributes: [{ name: "attr", value: "some } value" }],
        children: [],
      },
    ]);
  });

  it("handles incomplete tags gracefully", () => {
    const input = `
{:foo
{:/_bar
    `.trim();

    const parsed = parseKramdownExtensions(input);

    expect(parsed).toStrictEqual(["{:foo\n{:/_bar"]);
  });

  it("handles mismatched end tags gracefully", () => {
    const input = `

      {::outer}{::inner}test{:/outer}{:/inner}

    `.trim();

    const parsed = parseKramdownExtensions(input);

    expect(parsed).toStrictEqual(["{::outer}{::inner}test{:/outer}{:/inner}"]);
  });

  it("does not support unescaped right braces in attributes", () => {
    const input = `
    {::my_tag attr="some } value" /}
    `.trim();
    const parsed = parseKramdownExtensions(input);
    expect(parsed).toStrictEqual(['{::my_tag attr="some } value" /}']);
  });

  it("doesn't support unquoted attributes", () => {
    const input = `
    {::my_tag attr=some_value /}
    `.trim();
    const parsed = parseKramdownExtensions(input);
    expect(parsed).toStrictEqual(["{::my_tag attr=some_value /}"]);
  });

  it("doesn't support short close tags", () => {
    const input = `

This is a {::test}test of short close tags{/}. It should not work.

    `.trim();

    const parsed = parseKramdownExtensions(input);

    expect(parsed).toStrictEqual([
      "This is a {::test}test of short close tags{/}. It should not work.",
    ]);
  });

  it("doesn't support invalid attribute names", () => {
    const input = '{::tag attr-name="foo" /}';
    const parsed = parseKramdownExtensions(input);
    expect(parsed).toStrictEqual([input]);
  });

  it("handles invalid attribute value escape sequences gracefully", () => {
    const input = '{::some_tag attr="value\\?" /}';
    const parsed = parseKramdownExtensions(input);
    expect(parsed).toStrictEqual([
      {
        name: "some_tag",
        attributes: [
          {
            name: "attr",
            value: "value\\?",
          },
        ],
        children: [],
      },
    ]);
  });
});

describe("Kramdown regex parsing", () => {
  it("can match a self-closing tag", () => {
    const input = `this is a self-closing tag: {::some_tag attr="value" /} and here is some text after`;
    const m = KramdownExtensionRegex.exec(input);
    expect([...m]).toStrictEqual([
      '{::some_tag attr="value" /}',
      undefined,
      undefined,
      undefined,
      undefined,
      "some_tag",
      "attr",
      "value",
    ]);
  });

  it("can match a tag with text in the body", () => {
    const input = `
Here is a tag:

{::some_tag attr="value" attr2="value"}
    there is some text in the body.
    it can't be fooled by the wrong closing tag: {:/wrong_tag}
{:/some_tag}

    `.trim();

    const m = KramdownExtensionRegex.exec(input);
    expect(m).toBeTruthy();

    expect([...m]).toStrictEqual([
      '{::some_tag attr="value" attr2="value"}\n' +
        "    there is some text in the body.\n" +
        "    it can't be fooled by the wrong closing tag: {:/wrong_tag}\n" +
        "{:/some_tag}",
      "some_tag",
      "attr2",
      "value",
      "\n" +
        "    there is some text in the body.\n" +
        "    it can't be fooled by the wrong closing tag: {:/wrong_tag}\n",
      undefined,
      undefined,
      undefined,
    ]);
  });

  it.todo("can match a tag with children");
});
