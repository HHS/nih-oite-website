import React from "react";
import PropTypes from "prop-types";

// eslint-disable-next-line react/prefer-stateless-function
export default class ReadOnlyControl extends React.Component {
  render() {
    const { value } = this.props;
    return <p>{value.toString()}</p>;
  }
}

ReadOnlyControl.propTypes = {
  value: PropTypes.oneOfType([PropTypes.string, PropTypes.instanceOf(Date)]),
};

ReadOnlyControl.defaultProps = {
  value: "",
};
