import React from 'react'
import PropTypes  from 'prop-types'

class PreviewLink extends React.Component {
  constructor(props) {
    super(props)

    this.state = {
      amount: null,
      copy: null
    }

    this.handleChange = this.handleChange.bind(this)
    this.handleCopy = this.handleCopy.bind(this)
  }

  handleCopy(e) {
    e.preventDefault()
    let copyText = this.inputField

    copyText.select()
    copyText.setSelectionRange(0, copyText.value.length)
    navigator.clipboard.writeText(copyText.value)
    this.setState({copy: true})
    // after 3 seconds, go back to default
    setTimeout(() => {
      this.setState({copy: null})
    }, 3 * 1000)
  }

  handleChange(e) {
    if (e.target.value == '') {
      this.setState({amount: null})
    } else {
      let amount = parseFloat(e.target.value) * 100
      if (Number.isFinite(amount) && amount > 0) {
        this.setState({amount})
      }
    }
  }

  render() {
    const {path } = this.props
    let humanizedAmount = null
    let url = new URL(path)
    if (this.state.amount) {
      url.searchParams.set('amount', this.state.amount)

      humanizedAmount = (this.state.amount/100).toLocaleString('en-US', {
        style: 'currency',
        currency: 'USD',
      })
    }

    return (
      <>
        <label htmlFor="prefill-amount">Amount to prefill in USD</label>
        <div className="field">
          <div className="flex items-center">
            <span className="bold muted" style={{width: "1rem"}}>$</span>
            <input placeholder="500.00"
                    step="0.01"
                    min="0.01"
                    type="number"
                    name="prefill-amount"
                    onChange={this.handleChange}
                     />
          </div>
        </div>
        <hr />
        <label htmlFor="prefill-url">
          {this.state.amount == null ?
          'Donation link' :
          'Prefilled donation link'
          }
        </label>
        <div className="field">
          <div className="flex items-center">
            <input  value={url} 
                    readOnly={true}
                    name="prefill-url"
                    type="text"
                    ref={(c) => this.inputField = c}
                     />
            <span className="ml1 tooltipped tooltipped--w cursor-pointer"
                  aria-label={this.state.copy ? '✅ Copied to clipboard!' : 'Copy link'}
                  style={{width: "1rem"}}
                  onClick={this.handleCopy}>
            ⧉
            </span>
          </div>
        {this.state.amount && (
          <>
            <span className="muted">This will be prefilled as a <strong>{humanizedAmount}</strong> donation</span>
          </>
        )}
        </div>
      </>
    )
  }
}

PreviewLink.propTypes = {
  path: PropTypes.string
}

export default PreviewLink