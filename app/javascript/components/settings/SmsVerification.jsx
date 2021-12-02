import React, { useState } from 'react';
import HttpClient from '../../common/http';


const SmsToggleButton = ({ smsAuthEnabled, smsSent, phoneNumber, handleDisable, handleEnable }) => {
  const validPhoneNumber = phoneNumber && phoneNumber.startsWith("+")
  return (
    <div className="field">
      <div hidden={!smsAuthEnabled}>
        <button
          className="btn bg-muted"
          onClick={handleDisable}>
          Disable SMS Login
        </button>
      </div>
      <div hidden={smsAuthEnabled}>
        <div hidden={validPhoneNumber}>
            <span>
              We've changed the way our phone number system works. Please use the new phone number input above to
              update existing number with the correct country code.
            </span>
          <br/>
          <br/>
        </div>
        <button
          disabled={!validPhoneNumber || smsSent}
          className={"btn" + (!validPhoneNumber || smsSent ? " bg-muted" : "")}
          onClick={handleEnable}>
          Enable SMS Login
        </button>
      </div>
    </div>
  );
}

const SmsValidationForm = ({ hidden, onSubmit, onInputChange }) => {
  return <div hidden={hidden}>
    <form onSubmit={onSubmit}>
      <div className="field">
        <label>
          A text message has just been sent to your phone number provided above.
          <br/>
          Please enter the 6 digit code to validate your phone number.
        </label>
        <input
          type="text"
          placeholder="Verification Code"
          onChange={onInputChange}
        />
      </div>

      <button className="btn" type="submit">Submit</button>
    </form>
  </div>
}

const SmsVerification = ({ useSmsAuth, phoneNumberVerified, phoneNumber }) => {
  const [smsSent, setSmsSent] = useState(false);
  const [loginCode, setLoginCode] = useState("");
  const [error, setError] = useState(null);
  const [smsAuthEnabled, setSmsAuthEnabled] = useState(useSmsAuth);
  const [showSuccessMessage, setShowSuccessMessage] = useState(false);

  const toggleSmsAuth = async () => {
    const resp = await HttpClient.post('/users/toggle_sms_auth')

    if (resp.status === 200) {
      setSmsAuthEnabled(resp.data.useSmsAuth)
    } else {
      setError("something went wrong!")
    }
  }
  const handleEnable = async () => {
    if (!phoneNumberVerified) {
      await startPhoneNumberVerification();
    } else {
      await toggleSmsAuth();
      setSmsAuthEnabled(true);
      setShowSuccessMessage(true);
    }

  }

  const completePhoneNumberVerification = async () => {
    let resp;
    try {
      resp = await HttpClient.post(
        '/users/complete_sms_auth_verification',
        { code: loginCode },
      );
    } catch (e) {
      setError("Something went wrong! Could not complete phone number verification")
      return
    }

    if (resp.status === 200) {
      setSmsAuthEnabled(true);
      setShowSuccessMessage(true);
      setError("");
    } else {
      if (resp.error === 'invalid login code') {
        setError('invalid login code, please try again')
      } else {
        setError("Something went wrong! Could not complete phone number verification")
      }
    }
  }

  const startPhoneNumberVerification = async () => {
    const resp = await HttpClient.post('/users/start_sms_auth_verification');

    if (resp.status === 200) {
      setSmsSent(true);
    } else {
      setError("something went wrong!")
    }
  }

  const handleDisable = async () => {
    await toggleSmsAuth()
    setSmsAuthEnabled(false);
    setShowSuccessMessage(false);
  }

  return (
    <div>
      <SmsToggleButton
        smsSent={smsSent}
        smsAuthEnabled={smsAuthEnabled}
        phoneNumber={phoneNumber}
        handleDisable={() => handleDisable()}
        handleEnable={() => handleEnable()}
      />
      <SmsValidationForm
        hidden={!(smsSent && !smsAuthEnabled)}
        onSubmit={(e) => {
          e.preventDefault()
          completePhoneNumberVerification()
        }}
        onInputChange={(e) => setLoginCode(e.target.value)}
      />
      <span hidden={!showSuccessMessage}>You've successfully enabled SMS login!</span>
      <span hidden={!error}>{error}</span>
    </div>
  )
}


export default SmsVerification;
