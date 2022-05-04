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

import {
  lex,
  TokenTypes,
  START_ELEMENT,
  ELEMENT_NAME,
  START_ATTR_NAME,
  ATTR_NAME,
} from "./lexer";

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

export const KramdownExtensionRegex = new RegExp(
  ["(?:", ELEMENT, "|", SELF_CLOSING_ELEMENT, ")"].join(""),
  "m"
);

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
  const root = {
    children: [],
  };

  let parent = root;

  const openTags = [];

  let tagBeingBuilt;
  let attributeBeingBuilt;

  /**
   * Consumes a single lexer token.
   */
  function consume(token) {
    function consumeAsText(t = token) {
      consume({
        type: TokenTypes.TEXT,
        value: t.raw ?? t.value ?? "",
      });
    }

    if (tagBeingBuilt == null) {
      // When no tag is being built, we can consume:
      //  - text
      //  - start_open_tag
      //  - close_tag
      if (token.type === TokenTypes.TEXT) {
        const canAppendToPrevious =
          parent.children.length > 0 &&
          typeof parent.children[parent.children.length - 1] === "string";

        if (canAppendToPrevious) {
          parent.children[parent.children.length - 1] += token.value;
        } else {
          parent.children.push(token.value);
        }
      } else if (token.type === TokenTypes.START_OPEN_TAG) {
        tagBeingBuilt = {
          name: token.value,
          attributes: [],
          children: [],
          tokens: [token],
        };
      } else if (token.type === TokenTypes.CLOSE_TAG) {
        // Try and close the last open tag
        if (openTags.length === 0) {
          // We don't have any open tags.
          consumeAsText();
        } else {
          const tagToClose = openTags.pop();

          // We can only actually close the open tag if:
          // - the close_tag token doesn't have a value (for {::self_closing_tags /})
          // - the value of the close_tag token matches the name of the tag
          const okToClose =
            token.value == null || token.value === tagToClose.name;

          if (okToClose) {
            parent = openTags[openTags.length - 1] ?? root;
            parent.children.push(tagToClose);
          } else {
            openTags.push(tagToClose);
            consumeAsText();
          }
        }
      } else {
        consumeAsText();
      }
    } else if (attributeBeingBuilt == null) {
      // When we have a tag open, but no current attribute, we can consume:
      // - ATTR_NAME
      // - END_OPEN_TAG
      if (token.type === TokenTypes.ATTR_NAME) {
        tagBeingBuilt.tokens.push(token);
        attributeBeingBuilt = {
          name: token.value,
        };
      } else if (token.type === TokenTypes.END_OPEN_TAG) {
        tagBeingBuilt.tokens.push(token);
        openTags.push(tagBeingBuilt);

        // This tag becomes the new destination for new things being appended
        parent = tagBeingBuilt;
        tagBeingBuilt = undefined;
      } else {
        const tokensToReprocess = [...tagBeingBuilt.tokens, token];

        attributeBeingBuilt = undefined;
        tagBeingBuilt = undefined;

        tokensToReprocess.forEach(consumeAsText);
      }
    } else if (attributeBeingBuilt != null) {
      // We have an attribute open. The only the we can consume is:
      // - ATTR_VALUE
      if (token.type === TokenTypes.ATTR_VALUE) {
        tagBeingBuilt.tokens.push(token);
        attributeBeingBuilt.value = token.value;
        tagBeingBuilt.attributes.push(attributeBeingBuilt);
        attributeBeingBuilt = undefined;
      } else {
        const tokensToReprocess = [...tagBeingBuilt.tokens, token];

        attributeBeingBuilt = undefined;
        tagBeingBuilt = undefined;

        tokensToReprocess.forEach(consumeAsText);
      }
    }
  }

  lex(input).forEach(consume);

  // any open tags remaining were not properly closed
  openTags.forEach((tag) => {
    tag.tokens.forEach((token) => {
      root.children.push(token.raw ?? token.value ?? "");
    });
    root.children.push(...tag.children);
  });

  function cleaningReducer(result, node) {
    if (typeof node === "string") {
      // Try and combine sequential strings
      const canAppend =
        result.length > 0 && typeof result[result.length - 1] === "string";

      if (canAppend) {
        // eslint-disable-next-line no-param-reassign
        result[result.length - 1] += node;
      } else {
        result.push(node);
      }
      return result;
    }

    const newNode = {
      ...node,
      children: node.children.reduce(cleaningReducer, []),
    };

    delete newNode.tokens;

    result.push(newNode);
    return result;
  }

  return root.children.reduce(cleaningReducer, []);
}
