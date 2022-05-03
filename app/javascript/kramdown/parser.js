// This file defines a basic state-machine parser for Kramdown extensions.
// Extensions look a little like HTML tags, like this:
//
//    {::some_tag attr="value" attr="value"}body{:/some_tag}
//
// The full syntax is described here: https://kramdown.gettalong.org/syntax.html#extensions
//
// This file _also_ provides a regex pattern that will _mostly_ match. The
// idea is you can use the regex as the `pattern` for a Netlify editor component,
// then do a more sophisticated parsing of whatever that matches.

const START_ELEMENT = "[a-z]";
const ELEMENT_NAME = "[a-z0-9_]";
const START_ATTR_NAME = START_ELEMENT;
const ATTR_NAME = ELEMENT_NAME;

const FULL_ELEMENT_NAME = `${START_ELEMENT}${ELEMENT_NAME}*`;
const FULL_ATTR_NAME = `${START_ATTR_NAME}${ATTR_NAME}*`;

const ATTR_VALUE = '(?:[^"}]|\\\\["}])*';
const ATTR_NAME_AND_VALUE = `(${FULL_ATTR_NAME})\\s*=\\s*"(${ATTR_VALUE})"`;

const SELF_CLOSING_ELEMENT = [
  "{::",
  `(${FULL_ELEMENT_NAME})`,
  `(?:\\s+${ATTR_NAME_AND_VALUE})*`,
  `\\s*/}`,
].join("");

const ELEMENT = [
  "{::",
  `(${FULL_ELEMENT_NAME})`,
  `(?:\\s+${ATTR_NAME_AND_VALUE})*`,
  `\\s*}`,
  "([\\s\\S]*)",
  "{:/\\1}",
].join("");

const START_ELEMENT_NAME_RX = new RegExp(START_ELEMENT);
const ELEMENT_NAME_RX = new RegExp(ELEMENT_NAME);
const START_ATTR_NAME_RX = new RegExp(START_ATTR_NAME);
const ATTR_NAME_RX = new RegExp(ATTR_NAME);

export const KramdownExtensionRegex = new RegExp(
  ["(?:", ELEMENT, "|", SELF_CLOSING_ELEMENT, ")"].join(""),
  "m"
);

// Parser states
const STATE_NORMAL = "NORMAL";
const STATE_CURLY = "CURLY";
const STATE_CURLY_COLON = "CURLY_COLON";
const STATE_CURLY_COLON_COLON = "CURLY_COLON_COLON";
const STATE_OPEN_TAG_NAME = "OPEN_TAG_NAME";
const STATE_OPEN_TAG = "OPEN_TAG";
const STATE_ATTR_NAME = "ATTR_NAME";
const STATE_ATTR_START_VALUE = "ATTR_START_VALUE";
const STATE_ATTR_VALUE = "ATTR_VALUE";
const STATE_ATTR_VALUE_ESCAPE = "ATTR_VALUE_ESCAPE";
const STATE_OPEN_TAG_SLASH = "OPEN_TAG_SLASH";
const STATE_CURLY_COLON_SLASH = "CURLY_COLON_SLASH";
const STATE_CLOSE_TAG_NAME = "CLOSE_TAG_NAME";

/**
 * @typedef {object} KramdownExtensionAttribute
 * @property {string} name
 * @property {string} value
 */

/**
 * @typedef {object} KramdownExtensionNode
 * @property {string} name
 * @property {KramdownExtensionAttribute[]} attributes
 * @property {(KramdownExtensionNode|string)[]} children
 */

/**
 * Parses arbitrary text into a hierarchy of Kramdown extension "nodes" and
 * raw text.
 * @param {string} input
 * @returns {(KramdownExtensionNode|string)[]}
 */
export function parseKramdownExtensions(input) {
  const result = [];

  const openTags = [];

  let state = STATE_NORMAL;

  // text tracks the current string of raw text being built
  /**
   * @type {string}
   */
  let text = "";

  /**
   * The current tag being constructed.
   * @type {(KramdownExtensionNode & { raw: string})|undefined}
   */
  let tag;

  /**
   * @type {KramdownExtensionAttribute|undefined}
   */
  let attr;

  /**
   * @type {string|undefined}
   */
  let openTagName;

  /**
   * @type {string|undefined}
   */
  let closeTagName;

  /**
   * @type {string|undefined}
   */
  let attrName;

  /**
   * @type {string|undefined}
   */
  let rawCloseTag = "";

  function consumeText() {
    if (text === "") {
      return;
    }

    const parent = openTags[openTags.length - 1];
    const array = parent ? parent.children : result;

    if (array.length > 0 && typeof array[array.length - 1] === "string") {
      // moosh the text into the previous string
      array[array.length - 1] += text;
    } else {
      array.push(text);
    }

    text = "";
  }

  function openTag(tagName) {}

  function closeTag(tagName = undefined) {
    consumeText();

    const lastTag = openTags.pop();

    if (lastTag == null) {
      return false;
    }

    if (tagName != null && tagName !== lastTag.name) {
      // We're not closing the right tag
      openTags.push(lastTag);
      return false;
    }

    delete lastTag.raw;

    const parent = openTags[openTags.length - 1];
    if (parent) {
      parent.children.push(lastTag);
    } else {
      result.push(lastTag);
    }

    state = STATE_NORMAL;

    return true;
  }

  /**
   * Consumes a single character of the input text.
   * @param {string} c
   */
  function consume(c) {
    function abort(textToAppend) {
      if (textToAppend != null) {
        text += textToAppend;
      }
      state = STATE_NORMAL;
      consume(c);
    }

    if (state === STATE_NORMAL) {
      if (c === "{") {
        state = STATE_CURLY;
      } else {
        text += c;
      }
    } else if (state === STATE_CURLY) {
      if (c === ":") {
        state = STATE_CURLY_COLON;
      } else {
        abort("{");
      }
    } else if (state === STATE_CURLY_COLON) {
      if (c === ":") {
        state = STATE_CURLY_COLON_COLON;
      } else if (c === "/") {
        state = STATE_CURLY_COLON_SLASH;
      } else {
        abort("{:");
      }
    } else if (state === STATE_CURLY_COLON_SLASH) {
      if (START_ELEMENT_NAME_RX.test(c)) {
        // It looks like we're in a {:/close_tag}
        closeTagName = c;
        rawCloseTag = `{:/${c}`;
        state = STATE_CLOSE_TAG_NAME;
        // NOTE: We're not supporting the "short" close tag style ("{:/}").
      } else {
        abort(`{:/`);
      }
    } else if (state === STATE_CLOSE_TAG_NAME) {
      if (ELEMENT_NAME_RX.test(c)) {
        closeTagName += c;
        rawCloseTag += c;
      } else if (/\s/.test(c)) {
        rawCloseTag += c;
      } else if (c === "}") {
        // tag is closing
        if (!closeTag(closeTagName)) {
          abort(rawCloseTag);
        }
      } else {
        abort();
      }
    } else if (state === STATE_CURLY_COLON_COLON) {
      // "{::" looks like the start of an {::open_tag}
      if (START_ELEMENT_NAME_RX.test(c)) {
        state = STATE_OPEN_TAG_NAME;
        openTagName = c;
      } else {
        abort("{::");
      }
    } else if (state === STATE_OPEN_TAG_NAME) {
      if (ELEMENT_NAME_RX.test(c)) {
        // continue the open tag name
        openTagName += c;
      } else if (/\s/.test(c)) {
        tag = {
          name: openTagName,
          attributes: [],
          children: [],
          raw: `{::${openTagName}${c}`,
        };
        state = STATE_OPEN_TAG;
      } else if (c === "}") {
        // Tag has closed w/o any attributes
        consumeText();
        openTags.push({
          name: openTagName,
          attributes: [],
          children: [],
          raw: `{::${openTagName}}`,
        });
        state = STATE_NORMAL;
      } else {
        abort(`{::${openTagName}`);
      }
    } else if (state === STATE_OPEN_TAG) {
      if (/\s/.test(c)) {
        tag.raw += c;
      } else if (START_ATTR_NAME_RX.test(c)) {
        tag.raw += c;
        attrName = c;
        state = STATE_ATTR_NAME;
      } else if (c === "/") {
        tag.raw += c;
        state = STATE_OPEN_TAG_SLASH;
      } else if (c === "}") {
        tag.raw += c;
        consumeText();
        openTags.push(tag);
        state = STATE_NORMAL;
      } else {
        // this was not a valid character for an open tag
        abort(tag.raw);
        tag = undefined;
      }
    } else if (state === STATE_ATTR_NAME) {
      if (ATTR_NAME_RX.test(c)) {
        tag.raw += c;
        attrName += c;
      } else if (c === "=") {
        tag.raw += c;
        state = STATE_ATTR_START_VALUE;
      } else {
        abort(tag.raw);
      }
    } else if (state === STATE_ATTR_START_VALUE) {
      if (c === '"') {
        tag.raw += c;
        attr = { name: attrName, value: "" };
        state = STATE_ATTR_VALUE;
      } else {
        abort(tag.raw);
      }
    } else if (state === STATE_ATTR_VALUE) {
      if (c === "\\") {
        // " and } must be escaped in attribute values
        tag.raw += c;
        state = STATE_ATTR_VALUE_ESCAPE;
      } else if (c === "}") {
        // An unescaped '}' is not permitted in attribute values
        abort(tag.raw);
      } else if (c === '"') {
        tag.raw += c;
        tag.attributes.push(attr);
        state = STATE_OPEN_TAG;
      } else {
        tag.raw += c;
        attr.value += c;
      }
    } else if (state === STATE_ATTR_VALUE_ESCAPE) {
      if (c === '"' || c === "}") {
        tag.raw += c;
        attr.value += c;
        state = STATE_ATTR_VALUE;
      } else {
        attr.value += "\\";
        state = STATE_ATTR_VALUE;
        consume(c);
      }
    } else if (state === STATE_OPEN_TAG_SLASH) {
      if (c === "}") {
        tag.raw += c;
        // this open tag is self-closing
        consumeText();
        openTags.push(tag);
        closeTag();
      } else {
        abort(tag.raw);
      }
    }
    console.log(state, c);
  }

  for (let i = 0; i < input.length; i += 1) {
    consume(input[i]);
  }

  openTags.forEach((t) => {
    text = `${t.raw}${text}`;
  });

  consumeText();

  return result;
}
