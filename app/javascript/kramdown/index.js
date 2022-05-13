export { default as createKramdownExtensionEditorComponent } from "./component";
export {
  createKramdownExtensionRegex,
  parseKramdownExtensions,
} from "./parser";

/**
 * Escapes raw input to be included in a Kramdown extension attribute.
 * @param {any} str
 * @returns {string}
 */
export function escapeForAttribute(str) {
  return String(str).replace(/("|})/g, "\\\\1");
}

/**
 * @returns {string}
 */
export function serializeKramdownExtensionNodes(nodes) {
  return (Array.isArray(nodes) ? nodes : [nodes])
    .map((node) => {
      if (typeof node === "string") {
        return node;
      }
      const attributes = node.attributes
        .map(({ name, value }) => `${name}="${escapeForAttribute(value)}"`)
        .join(" ");
      const startOpen = `{::${node.name}${
        attributes === "" ? "" : " "
      }${attributes}`;
      const children = node.children
        .map(serializeKramdownExtensionNodes)
        .join("");
      const endOpen = children === "" ? "" : "}";
      const close = children === "" ? "/}" : `{:/${node.name}}`;
      return `${startOpen}${endOpen}${children}${close}`;
    })
    .join("");
}
