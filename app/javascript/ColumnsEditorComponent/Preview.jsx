import React from "react";
import PropTypes from "prop-types";
import NetlifyCmsApp from "netlify-cms-app";
import NetlifyCmsWidgetMarkdown from "netlify-cms-widget-markdown";

// XXX: Netlify's Markdown renderer depends on `window.process.cwd` being
//      defined. Here we monkey patch that in. Typically this monkey
//      patching would be handled by webpack (via `resolve.fallback`). I'm
//      opting to keep the complexity in this file since this file is the one
//      that's causing the "problem" by importing NetlifyCmsWidgetMarkdown and
//      using its previewComponent.

if (typeof window.process?.cwd !== "function") {
  window.process = window.process ?? {};
  window.process.cwd = () => "";
}

/**
 * @typedef {Object} PreviewProps
 * @property {string[]} columnNames
 * @property {string[]} columnContents
 * @property {() => any} getAsset
 */

/**
 * Renders a preview of a column component.
 * @param {PreviewProps} props
 */
export default function Preview({ columnNames, columnContents, getAsset }) {
  const MarkdownPreviewComponent = NetlifyCmsWidgetMarkdown.previewComponent;

  return (
    <div className="grid-row">
      {columnNames.map((name, index) => (
        <div key={name} className={`grid-col grid-col--${name}`}>
          <MarkdownPreviewComponent
            value={columnContents[index] ?? ""}
            getAsset={getAsset}
            resolveWidget={NetlifyCmsApp.resolveWidget}
          />
        </div>
      ))}
    </div>
  );
}

Preview.propTypes = {
  columnNames: PropTypes.arrayOf(PropTypes.string).isRequired,
  columnContents: PropTypes.arrayOf(PropTypes.string).isRequired,
  getAsset: PropTypes.func.isRequired,
};
