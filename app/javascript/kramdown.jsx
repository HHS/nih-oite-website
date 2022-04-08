import React from "react";

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
 * @param {attrNames} {string[]} Names of attributes expected (in order)
 * @returns {RegExp} A regular expression that will match a kramdown extension tag.
 */
function makeExtensionRegex(name, attrNames) {
  // NOTE: This pattern is quite fragile and depends on exact ordering of attributes.
  const attrPatterns = attrNames
    .map((attrName) => `${attrName}="(.*)"`)
    .join(" ");
  return new RegExp(`{::${name}${attrPatterns ? ` ${attrPatterns}` : ""} \\/}`);
}

/**
 * Creates a Netlify Markdown editor component that is represented in markdown
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
  const fromBlock = (match) =>
    fields.reduce(
      (result, field, index) => ({
        ...result,
        [field.name]: unescapeExtensionAttribute(match[index + 1]),
      }),
      {}
    );

  // Convert attribute values into the Markdown representation
  const toBlock = (data) =>
    [
      `{::${options.id}`,
      ...fields.map(
        (f) => `${f.name}="${escapeForExtensionAttribute(data[f.name] ?? "")}"`
      ),
      `/}`,
    ].join(" ");

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
