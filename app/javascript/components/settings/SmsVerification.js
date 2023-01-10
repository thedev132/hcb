import HttpClient from "../../common/http";
import React, { useState } from 'react';
import PropTypes from "prop-types"

const SmsVerification = ({ phoneNumber }) => {
  const [errors, setErrors] = useState([])
  const [validationSent, setValidationSent] = useState(false)
  const [validationSuccess, setValidationSuccess] = useState(false)
  const [loading, setLoading] = useState(false)
  const [code, setCode] = useState('')

  const handleClick = async (e) => {
    e.preventDefault()
    if (loading) { return }
    setLoading(true)
    try {
      const resp = await HttpClient.post('/users/start_sms_auth_verification');

      if (resp.status === 200) {
        setErrors([])
        setValidationSent(true)
      } else {
        setErrors(["something went wrong!"])
      }
    } finally {
      document.getElementById('verification-code').focus()
      setLoading(false)
    }
  }

  const handleSubmit = async (e) => {
    console.log('submitting...')
    if (e) {
      e.preventDefault()
    }
    setLoading(true)
    await HttpClient.post(
      '/users/complete_sms_auth_verification',
      { code },
    ).then(() => {
      setErrors([])
      setValidationSuccess(true)
    }).catch(() => {
      setErrors(["⚠️ Invalid code. Did you type it in correctly?"])
    })
    setLoading(false)
  }

  const handleInput = (e) => {
    setCode(e.target.value)
    if (e.key === 'Enter' || e.keyCode === 13) {
      handleSubmit(e)
    }
  }

  const refresh = () => {
    window.location.reload()
  }

  return (
    <>
      {(errors.length > 0) && (
        <ul className="list-reset bg-error p1 rounded" style={{ color: 'white' }}>
          {errors.map((e, i) => (
            <li key={i}>{e}</li>
          ))}
        </ul>
      )}
      {(validationSuccess) && (
        <>
          <p>✅ Verified! Next time you sign in your login code will go to {phoneNumber}.</p>
          <button className="btn btn-success" onClick={refresh}>Refresh to continue</button>
        </>
      )}
      {(!validationSuccess) && (
        <>
          {(validationSent) && (
            <>
              <p>We&apos;ve just sent a code to {phoneNumber}. It should arrive in the next 5 to 30 seconds depending on your connection.</p>
              <div className="flex">
                <form onSubmit={handleSubmit}>
                  <input type="tel" id="verification-code" autoComplete="off" onSubmit={handleSubmit} onInput={handleInput} placeholder="XXX-XXX" value={code} className="mb1" required />
                  <input className={loading ? 'muted wait disabled' : 'pointer'} onSubmit={handleSubmit} type="submit" value="Verify" />
                </form>
              </div>
            </>
          )}
          <p>
            <a href="#" onClick={handleClick} className={loading ? 'muted wait' : 'pointer'}>{validationSent ? 'Resend code' : 'Send verification code'}</a>
            {' '}
            to {phoneNumber}.
          </p>
        </>
      )}
    </>
  )
}

SmsVerification.propTypes = {
  phoneNumber: PropTypes.string.isRequired,
};

export default SmsVerification;