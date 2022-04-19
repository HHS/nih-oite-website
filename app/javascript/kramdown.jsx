import React from "react";

const attrNameRegex = "[a-z0-9_]+";
const attrValueRegex = '(\\\\"|[^"])*';
const attrRegex = `(${attrNameRegex})\\s*=\\s*"(${attrValueRegex})"`;

/**
 * Escapes user input for storage in a Kramdown extension attribute.
 * Note that this _does not_ do sanitization--that'll be the job of
 * whatever's rendering the Markdown to HTML.
 * @param {any} input
 * @returns {string}
 */
function escapeForExtensionAttribute(input) {
  return String(input ?? "").replace(/"/g, '\\"');
}

/**
 * @param {any} value
 * @returns {string}
 */
function unescapeExtensionAttribute(value) {
  return String(value ?? "").replace(/\\"/g, '"');
}

/**
 * Generates a regular expression that will match a Kramdown extension, e.g.:
 *
 * ```
 * {::some_tag attr="value" otherAttr="value" /}
 * ```
 *
 * @param {name} {string}
 * @returns {RegExp} A regular expression that will match a kramdown extension tag.
 */
function makeExtensionRegex(name) {
  return new RegExp(`{::${name}\\s+((${attrRegex}\\s*)*)\\s*/}`, "gi");
}

/**
 * Creates a Netlify Markdown editor component that is represented in Markdown
 * using Kramdown's extension syntax.
 * @param options {Object}
 * @param options.id {string}
 * @param options.label {string}
 * @param options.fields {{name: string, label: string, widget: string, [key: string]: any}[]} Fields supported by the component. (Order matters here)
 * @param options.toPreview {(data: any) => React.ReactElement}
 * @returns {{
 *  id: string,
 *  label: string,
 *  fields: {name: string, label: string, widget: string; [key: string]: any}[],
 *  pattern: RegExp,
 *  fromBlock: (match: string[]) => Record<string,any>,
 *  toBlock: (data: Record<string,any>) => string,
 *  toPreview: (data: Record<string,any>) => React.ReactNode
 * }}
 */
export default function createKramdownExtensionEditorComponent(options) {
  const fields = options.fields ?? [];

  const pattern = makeExtensionRegex(
    options.id,
    fields.map((f) => f.name)
  );

  // Convert a regex match back to an object whose keys are the field names and values are the field values
  const fromBlock = (match) => {
    const attrs = match[1];
    const rx = new RegExp(attrRegex, "gi");

    const parsed = {};

    for (let m = rx.exec(attrs); m; m = rx.exec(attrs)) {
      const attrName = m[1];
      const attrValue = m[2];
      parsed[attrName] = unescapeExtensionAttribute(attrValue);
    }

    return fields.reduce((result, field) => {
      // eslint-disable-next-line no-param-reassign
      result[field.name] = parsed[field.name] ?? "";
      return result;
    }, {});
  };

  // Convert attribute values into the Markdown representation
  const toBlock = (data) =>
    [
      `{::${options.id}`,
      ...fields.map(
        (f) => `${f.name}="${escapeForExtensionAttribute(data[f.name] ?? "")}"`
      ),
      `/}`,
    ]
      .filter((x) => x.length > 0)
      .join(" ");

  const toPreview =
    options.toPreview ??
    ((data) => (
      <div>
        <strong>{options.id}</strong>
        {fields.length && (
          <ul>
            {fields.map((f) => (
              <li key={f.name}>
                {f.label} = {data[f.name]}
              </li>
            ))}
          </ul>
        )}
      </div>
    ));

  return {
    ...options,
    fields,
    pattern,
    fromBlock,
    toBlock,
    toPreview,
  };
}
