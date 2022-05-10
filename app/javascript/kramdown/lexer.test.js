import { lex } from "./lexer";

describe("Kramdown extension lexer", () => {
  const tests = [
    {
      input: "foo bar baz",
      expected: [
        {
          type: "text",
          value: "foo bar baz",
        },
      ],
    },
    {
      input: "foo {::test}bar{:/test} baz",
      expected: [
        { type: "text", value: "foo " },
        { type: "start_open_tag", value: "test", raw: "{::test" },
        { type: "end_open_tag", raw: "}" },
        { type: "text", value: "bar" },
        { type: "close_tag", value: "test", raw: "{:/test}" },
        { type: "text", value: " baz" },
      ],
    },
    {
      input: "foo {::test /} bar baz",
      expected: [
        { type: "text", value: "foo " },
        { type: "start_open_tag", value: "test", raw: "{::test " },
        { type: "end_open_tag", raw: "" },
        { type: "close_tag", raw: "/}" },
        { type: "text", value: " bar baz" },
      ],
    },
    {
      input: "foo {::test} bar baz",
      expected: [
        { type: "text", value: "foo " },
        { type: "start_open_tag", value: "test", raw: "{::test" },
        { type: "end_open_tag", raw: "}" },
        { type: "text", value: " bar baz" },
      ],
    },
    {
      input: "foo {::test  ",
      expected: [
        { type: "text", value: "foo " },
        { type: "start_open_tag", value: "test", raw: "{::test  " },
      ],
    },
    {
      input: 'foo {::test attr="value 1" attr2 = "value 2"}bar{:/test} baz',
      expected: [
        { type: "text", value: "foo " },
        { type: "start_open_tag", value: "test", raw: "{::test " },
        { type: "attr_name", value: "attr", raw: "attr=" },
        { type: "attr_value", value: "value 1", raw: '"value 1" ' },
        { type: "attr_name", value: "attr2", raw: "attr2 = " },
        { type: "attr_value", value: "value 2", raw: '"value 2"' },
        { type: "end_open_tag", raw: "}" },
        { type: "text", value: "bar" },
        { type: "close_tag", value: "test", raw: "{:/test}" },
        { type: "text", value: " baz" },
      ],
    },
    {
      input: '{::test attr="value \\b"}{:/test}',
      expected: [
        { type: "start_open_tag", value: "test", raw: "{::test " },
        { type: "attr_name", value: "attr", raw: "attr=" },
        { type: "attr_value", value: "value \\b", raw: '"value \\b"' },
        { type: "end_open_tag", raw: "}" },
        { type: "close_tag", value: "test", raw: "{:/test}" },
      ],
    },

    {
      input: '{::test attr="value}"}{:/test}',
      expected: [
        { type: "start_open_tag", value: "test", raw: "{::test " },
        { type: "attr_name", value: "attr", raw: "attr=" },
        { type: "text", value: '"value}"}' },
        { type: "close_tag", value: "test", raw: "{:/test}" },
      ],
    },
    {
      input: 'foo {::test attr="value \\"1\\""}bar{:/test} baz',
      expected: [
        { type: "text", value: "foo " },
        { type: "start_open_tag", value: "test", raw: "{::test " },
        { type: "attr_name", value: "attr", raw: "attr=" },
        { type: "attr_value", value: 'value "1"', raw: '"value \\"1\\""' },
        { type: "end_open_tag", raw: "}" },
        { type: "text", value: "bar" },
        { type: "close_tag", value: "test", raw: "{:/test}" },
        { type: "text", value: " baz" },
      ],
    },
    {
      input: "{::outer}{::inner}{:/outer}{:/inner}",
      expected: [
        { type: "start_open_tag", value: "outer", raw: "{::outer" },
        { type: "end_open_tag", raw: "}" },
        { type: "start_open_tag", value: "inner", raw: "{::inner" },
        { type: "end_open_tag", raw: "}" },
        { type: "close_tag", value: "outer", raw: "{:/outer}" },
        { type: "close_tag", value: "inner", raw: "{:/inner}" },
      ],
    },
    {
      input: '{::test a="foo"}',
      expected: [
        { type: "start_open_tag", value: "test", raw: "{::test " },
        { type: "attr_name", value: "a", raw: "a=" },
        { type: "attr_value", value: "foo", raw: '"foo"' },
        { type: "end_open_tag", raw: "}" },
      ],
    },

    {
      input: '{::test a.="foo"}',
      expected: [
        { type: "start_open_tag", value: "test", raw: "{::test " },
        { type: "text", value: 'a.="foo"}' },
      ],
    },
    {
      input: '{::test attr.="foo"}',
      expected: [
        { type: "start_open_tag", value: "test", raw: "{::test " },
        { type: "text", value: 'attr.="foo"}' },
      ],
    },
    {
      input: "{::test}foo{:/?}",
      expected: [
        { type: "start_open_tag", value: "test", raw: "{::test" },
        { type: "end_open_tag", raw: "}" },
        { type: "text", value: "foo{:/?}" },
      ],
    },
    {
      input: "{::test}foo{:/a?}",
      expected: [
        { type: "start_open_tag", value: "test", raw: "{::test" },
        { type: "end_open_tag", raw: "}" },
        { type: "text", value: "foo" },
        { type: "text", value: "{:/a?}" },
      ],
    },
    {
      input: "{::test /FOO",
      expected: [{ type: "text", value: "{::test /FOO" }],
    },
    {
      input: "{::test attr=foo}",
      expected: [
        { type: "start_open_tag", value: "test", raw: "{::test " },
        { type: "text", value: "attr=foo}" },
      ],
    },
    {
      input: "{::foo ?",
      expected: [{ type: "text", value: "{::foo ?" }],
    },
    {
      input: "{::foo?",
      expected: [{ type: "text", value: "{::foo?" }],
    },
    {
      input: "{::_",
      expected: [{ type: "text", value: "{::_" }],
    },
  ];

  tests.forEach(({ input, expected }) => {
    test(`lexing '${input}'`, () => {
      const actual = lex(input);
      expect(actual).toStrictEqual(expected);
    });
  });
});
