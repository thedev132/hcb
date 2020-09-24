import React from "react"
import PropTypes from "prop-types"
class Card extends React.Component {
  constructor(props) {
    super(props)

    this.state = {
      status: 'loading',
      count: null,
      timeoutID: null
    }

    this.updateCount = this.updateCount.bind(this)
  }

  getColor () {
    if (this.state.status == 'loading') {
      return 'pending'
    }
    if (this.state.status == 'error') {
      return 'bg-warning'
    }
    if (this.state.count == 0)  {
      return 'bg-muted'
    }
    if (this.state.count != 0) {
      return 'bg-accent'
    }
  }

  getCount() {
    if (this.state.status == 'loading') {
      return '⏳'
    }
    if (Number.isInteger(this.state.count)) {
      return this.state.count
    }
    if (!this.state.count && this.state.status == 'error') {
      return '!'
    }
  }

  async updateCount () {
    const start = Date.now()
    await fetch('/admin_task_size?task_name=' + this.props.taskName).then(t => t.json()).then(data => {
      this.setState({
        status: 'success',
        count: data.size
      })
    }).catch(err => {
      console.error(err)
      this.setState({ status: 'error' })
    })
    // const duration = Date.now() - start
    // const minTimeout = 30000
    // const maxTimeout = 120000
    // const timeout = Math.max(Math.min(maxTimeout, duration), minTimeout)
    // // const timeoutID = setTimeout(this.updateCount, timeout)
    // this.setState({ timeoutID })
  }

  componentDidMount () {
    if (this.props.taskName) {
      this.updateCount()
    }
  }

  componentWillUnmount() {
    if (this.state.timeoutID) {
      clearTimeout(this.state.timeoutID)
    }
  }

  render () {
    return (
      <a href={this.props.taskPath} target="_blank">
        <li className="card card--item card--hover relative overflow-visible line-height-3">
          <strong>{this.props.humanName}</strong>
          {this.props.taskName && (
            <span className={`badge ${this.getColor()}`}>{this.getCount()}</span>
          )}
        </li>
      </a>
    );
  }
}

Card.propTypes = {
  taskName: PropTypes.string,
  taskPath: PropTypes.string,
  humanName: PropTypes.string,
};
export default Card
