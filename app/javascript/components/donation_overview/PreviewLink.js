import React from 'react'
import PropTypes  from 'prop-types'

class PreviewLink extends React.Component {
  constructor(props) {
    super(props)

    this.state = {
      amount: null,
      message: null,
      monthly: false,
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
    let field = e.target.name.replace('prefill-', '')
    if (e.target.value == '') {
      this.setState({[field]: null})
    } else {
      switch (field) {
        case 'amount': {
          let amount = parseFloat(e.target.value) * 100
          if (Number.isFinite(amount) && amount > 0) {
            this.setState({amount})
          }
          break
        }
        case 'message':
          this.setState({message: e.target.value})
          break
        case 'monthly':
          this.setState({monthly: e.target.checked})
          break
      }
    }
  }

  render() {
    const { path } = this.props
    let url = new URL(path)

    let showSubtitle = this.state.amount != null || this.state.message != null || this.state.monthly

    let humanizedMonthly = 'one-time '
    if (this.state.monthly) {
      humanizedMonthly = 'monthly '
      url.searchParams.set('monthly', this.state.monthly)
    }

    let humanizedMessage = null
    if (this.state.message) {
      humanizedMessage = ` with the message "${this.state.message}"`
      url.searchParams.set('message', this.state.message)
    } 

    let humanizedAmount = null
    if (this.state.amount) {
      url.searchParams.set('amount', this.state.amount)

      humanizedAmount = (this.state.amount/100).toLocaleString('en-US', {
        style: 'currency',
        currency: 'USD',
      }) + ' ' || ''
    }

    return (
      <>
        <label htmlFor="prefill-amount">Prefilled amount (USD)</label>
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
        <label htmlFor="prefill-message">Prefilled message</label>
        <div className="field">
          <div className="flex items-center">
            <input placeholder="optional"
                    type="text"
                    name="prefill-message"
                    onChange={this.handleChange}
                     />
          </div>
        </div>
        <label htmlFor="prefill-monthly">Monthly charge</label>
        <div className="field">
          <div className="flex items-center">
            <input placeholder="500.00"
                    type="checkbox"
                    name="prefill-monthly"
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
        {showSubtitle && (
          <>
            <span className="muted">This will be prefilled as a{' '}
            {humanizedMonthly} <strong>{humanizedAmount}</strong>donation{humanizedMessage}.</span>
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