import React from "react";
import PropTypes from "prop-types";

// eslint-disable-next-line react/prefer-stateless-function
export default class ReadOnlyPreview extends React.Component {
  render() {
    const { field, value } = this.props;
    if (field.get("hide_preview")) return null;
    return (
      <p>
        <strong>{field.get("label")}:</strong> {value.toString()}
      </p>
    );
  }
}

ReadOnlyPreview.propTypes = {
  field: PropTypes.shape({ get: PropTypes.func.isRequired }).isRequired,
  value: PropTypes.oneOfType([PropTypes.string, PropTypes.instanceOf(Date)])
    .isRequired,
};
