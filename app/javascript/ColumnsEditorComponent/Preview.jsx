import React from "react";
import PropTypes from "prop-types";

/**
 * @typedef {Object} PreviewProps
 * @property {{name: string, span: number}[]} columns
 * @property {string[]} columnContents
 * @property {() => any} getAsset
 * @property {() => any)} resolveWidget
 * @property {ReactComponentLike} NetlifyMarkdownPreview The Netlify markdown preview to use.
 */

/**
 * Renders a preview of a column component.
 * @param {PreviewProps} props
 */
export default function Preview({
  columns,
  columnContents,
  getAsset,
  resolveWidget,
  NetlifyMarkdownPreview,
}) {
  return (
    <div className="grid-row grid-gap grid-row--cms-columns">
      {columns.map(({ name, span }, index) => {
        const classes = [
          `grid-col--${name}`,
          span == null ? "tablet:grid-col" : `tablet:grid-col-${span}`,
        ].join(" ");
        return (
          <div key={name} className={classes}>
            <NetlifyMarkdownPreview
              value={columnContents[index] ?? ""}
              getAsset={getAsset}
              resolveWidget={resolveWidget}
            />
          </div>
        );
      })}
    </div>
  );
}

Preview.propTypes = {
  columns: PropTypes.arrayOf(
    PropTypes.shape({
      name: PropTypes.string,
      span: PropTypes.number,
    })
  ).isRequired,
  columnContents: PropTypes.arrayOf(PropTypes.string).isRequired,
  getAsset: PropTypes.func.isRequired,
  // eslint-disable-next-line react/forbid-prop-types
  NetlifyMarkdownPreview: PropTypes.any.isRequired,
  resolveWidget: PropTypes.func.isRequired,
};
