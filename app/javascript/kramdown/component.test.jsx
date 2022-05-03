import createKramdownExtensionEditorComponent from "./component";

describe("#createKramdownExtensionEditorComponent", () => {
  /**
   * @type {ReturnType<createKramdownExtensionEditorComponent>}
   */
  let component;

  beforeEach(() => {
    component = createKramdownExtensionEditorComponent({
      id: "some_tag",
      fields: [
        {
          name: "attr",
          label: "Attribute",
          widget: "string",
        },
        {
          name: "otherAttr",
          label: "Other attribute",
          widget: "string",
        },
      ],
    });
  });

  it("returns a component", () => {
    expect(component).toBeTruthy();
  });

  describe("#fromBlock", () => {
    const tests = [
      {
        input: `{::some_tag attr="value" otherAttr="other value" /}`,
        expected: { attr: "value", otherAttr: "other value" },
      },
      {
        input: `{::some_tag otherAttr="other value" attr="value" /}`,
        expected: { attr: "value", otherAttr: "other value" },
      },
      {
        input: `{::some_tag attr="value"/}`,
        expected: { attr: "value", otherAttr: "" },
      },
      {
        input: `{::some_tag attr="value" otherAttr="other value" invalidAttr="invalid value" /}`,
        expected: { attr: "value", otherAttr: "other value" },
      },
      {
        input: `{::some_tag attr="value" otherAttr="other \\"value\\"" /}`,
        expected: { attr: "value", otherAttr: 'other "value"' },
      },
    ];

    tests.forEach(({ input, expected }) =>
      it(`parses '${input}'`, () => {
        const match = component.pattern.exec(input);
        const actual = component.fromBlock(match);
        expect(actual).toEqual(expected);
      })
    );
  });

  describe("#toBlock", () => {
    it("writes Kramdown extension tags", () => {
      const data = {
        otherAttr: "bar",
        attr: "foo",
      };
      const actual = component.toBlock(data);
      expect(actual).toBe('{::some_tag attr="foo" otherAttr="bar" /}');
    });

    it("escapes double quotes", () => {
      const data = {
        otherAttr: 'another "value"',
        attr: "foo",
      };
      const actual = component.toBlock(data);
      expect(actual).toBe(
        '{::some_tag attr="foo" otherAttr="another \\"value\\"" /}'
      );
    });
  });
});
