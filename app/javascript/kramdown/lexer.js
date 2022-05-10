export const TokenTypes = {
  TEXT: "text",
  START_OPEN_TAG: "start_open_tag",
  END_OPEN_TAG: "end_open_tag",
  CLOSE_TAG: "close_tag",
  ATTR_NAME: "attr_name",
  ATTR_VALUE: "attr_value",
};

export const START_ELEMENT = "[a-z]";
export const ELEMENT_NAME = "[a-z0-9_]";
export const START_ATTR_NAME = START_ELEMENT;
export const ATTR_NAME = ELEMENT_NAME;

export const START_ELEMENT_NAME_RX = new RegExp(START_ELEMENT);
export const ELEMENT_NAME_RX = new RegExp(ELEMENT_NAME);
export const START_ATTR_NAME_RX = new RegExp(START_ATTR_NAME);
export const ATTR_NAME_RX = new RegExp(ATTR_NAME);

const States = {
  NORMAL: "NORMAL",
  CURLY: "CURLY",
  CURLY_COLON: "CURLY_COLON",
  CURLY_COLON_COLON: "CURLY_COLON_COLON",
  OPEN_TAG_NAME: "OPEN_TAG_NAME",
  OPEN_TAG: "OPEN_TAG",
  ATTR_NAME: "ATTR_NAME",
  ATTR_START_VALUE: "ATTR_START_VALUE",
  ATTR_VALUE: "ATTR_VALUE",
  ATTR_VALUE_ESCAPE: "ATTR_VALUE_ESCAPE",
  OPEN_TAG_SLASH: "OPEN_TAG_SLASH",
  CURLY_COLON_SLASH: "CURLY_COLON_SLASH",
  CLOSE_TAG_NAME: "CLOSE_TAG_NAME",
};

/**
 * @typedef {Object} LexerToken
 * @property {keyof typeof TokenTypes} type
 * @property {string|undefined} value
 * @property {string|undefined} raw
 */

/**
 * Lexes raw input into a stream of tokens
 * @param {string} input
 * @returns {LexerToken[]}
 */
export function lex(input) {
  const result = [];

  /**
   * @type {keyof typeof States}
   */
  let state = States.NORMAL;

  let current;

  /**
   *
   * @param {keyof typeof TokenTypes} type
   * @param {string} value
   * @param {string|undefined} raw
   */
  function start(type, value, raw = undefined) {
    current = {
      type,
      value,
      raw: raw == null ? value : raw,
    };

    if (current.value == null) {
      delete current.value;
    }

    result.push(current);
  }

  function consume(c) {
    function appendText(textToAppend) {
      if (!current || current.type !== TokenTypes.TEXT) {
        current = {
          type: TokenTypes.TEXT,
          value: "",
        };
        result.push(current);
      }

      current.value += textToAppend;
    }

    function resetToNormal(text) {
      appendText(text);
      state = States.NORMAL;
    }

    function resetAfterInvalidChar(textToAppend) {
      if (current != null) {
        current.type = TokenTypes.TEXT;
        current.value = current.raw;
        delete current.raw;
      }
      resetToNormal(textToAppend == null ? c : textToAppend);
    }

    const handlersByCurrentState = {
      [States.NORMAL]: {
        "{": States.CURLY,
        "": () => appendText(c),
      },
      [States.CURLY]: {
        ":": States.CURLY_COLON,
        "": () => resetToNormal(`{${c}`),
      },
      [States.CURLY_COLON]: {
        ":": States.CURLY_COLON_COLON,
        "/": States.CURLY_COLON_SLASH,
        "": () => resetToNormal(`{:${c}`),
      },
      [States.CURLY_COLON_COLON]: () => {
        const raw = `{::${c}`;
        if (START_ELEMENT_NAME_RX.test(c)) {
          // It looks like we're starting a tag
          state = States.OPEN_TAG_NAME;
          start(TokenTypes.START_OPEN_TAG, c, raw);
        } else {
          // Not starting a tag after all
          resetToNormal(raw);
        }
      },
      [States.OPEN_TAG_NAME]: () => {
        // We are assembling the tag name
        if (ELEMENT_NAME_RX.test(c)) {
          current.value += c;
          current.raw += c;
        } else if (/\s/.test(c)) {
          // We're now inside the open tag
          current.raw += c;
          state = States.OPEN_TAG;
        } else if (c === "}") {
          // We've now closed the tag
          start(TokenTypes.END_OPEN_TAG, undefined, c);
          current = undefined;
          state = States.NORMAL;
        } else {
          resetAfterInvalidChar();
        }
      },
      [States.OPEN_TAG]: () => {
        // We're in an open tag, looking for attribute name or '}'
        if (/\s/.test(c)) {
          // You can have spaces between tag name and attribute
          current.raw += c;
        } else if (START_ATTR_NAME_RX.test(c)) {
          // End the open tag, start an attribute name
          start(TokenTypes.ATTR_NAME, c, c);
          state = States.ATTR_NAME;
        } else if (c === "}") {
          start(TokenTypes.END_OPEN_TAG, undefined, c);
          state = States.NORMAL;
        } else if (c === "/") {
          // This _might_ be a self-closing tag
          state = States.OPEN_TAG_SLASH;
        } else {
          resetAfterInvalidChar();
        }
      },
      [States.ATTR_NAME]: () => {
        // We're in an attribute name
        if (ATTR_NAME_RX.test(c)) {
          current.value += c;
          current.raw += c;
        } else if (/\s/.test(c)) {
          current.raw += c;
        } else if (c === "=") {
          current.raw += c;
          state = States.ATTR_START_VALUE;
        } else {
          resetAfterInvalidChar();
        }
      },
      [States.ATTR_START_VALUE]: () => {
        // We're looking for the start of an attribute value
        if (/\s/.test(c)) {
          current.raw += c;
        } else if (c === '"') {
          start(TokenTypes.ATTR_VALUE, "", c);
          state = States.ATTR_VALUE;
        } else {
          resetAfterInvalidChar();
        }
      },
      [States.ATTR_VALUE]: () => {
        // We are reading the value of an attribute
        if (c === '"') {
          current.raw += c;
          state = States.OPEN_TAG;
        } else if (c === "\\") {
          // We are escaping
          current.raw += c;
          state = States.ATTR_VALUE_ESCAPE;
        } else if (c === "}") {
          // Invalid, must be escaped
          resetAfterInvalidChar();
        } else {
          current.value += c;
          current.raw += c;
        }
      },
      [States.ATTR_VALUE_ESCAPE]: () => {
        current.raw += c;
        if (c === '"' || c === "}") {
          current.value += c;
        } else {
          current.value += `\\${c}`;
        }
        state = States.ATTR_VALUE;
      },
      [States.OPEN_TAG_SLASH]: () => {
        if (c === "}") {
          // It _was_ a self-closing tag!
          start(TokenTypes.END_OPEN_TAG, undefined, "");
          start(TokenTypes.CLOSE_TAG, undefined, "/}");
          state = States.NORMAL;
        } else {
          resetAfterInvalidChar(`/${c}`);
        }
      },
      [States.CURLY_COLON_SLASH]: () => {
        // We _might_ be rendering an end tag
        const raw = `{:/${c}`;
        if (START_ELEMENT_NAME_RX.test(c)) {
          start(TokenTypes.CLOSE_TAG, c, raw);
          state = States.CLOSE_TAG_NAME;
        } else {
          resetToNormal(raw);
        }
      },
      [States.CLOSE_TAG_NAME]: () => {
        if (ELEMENT_NAME_RX.test(c)) {
          current.raw += c;
          current.value += c;
        } else if (c === "}") {
          current.raw += c;
          current = undefined;
          state = States.NORMAL;
        } else {
          resetAfterInvalidChar();
        }
      },
    };

    const handler = handlersByCurrentState[state];

    if (typeof handler === "function") {
      handler();
    } else if (typeof handler[c] === "string") {
      // this is a state transition
      state = handler[c];
    } else {
      handler[""](c);
    }
  }

  for (let i = 0; i < input.length; i += 1) {
    consume(input[i]);
  }

  return result;
}
