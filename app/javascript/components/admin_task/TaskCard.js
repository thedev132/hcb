import React from "react"
import PropTypes from "prop-types"
class TaskCard extends React.Component {
  render () {
    return (
      <React.Fragment>
        Task Name: {this.props.taskName}
        Human Name: {this.props.humanName}
        Task Url: {this.props.taskUrl}
      </React.Fragment>
    );
  }
}

TaskCard.propTypes = {
  taskName: PropTypes.string,
  humanName: PropTypes.string,
  taskUrl: PropTypes.string
};
export default TaskCard
