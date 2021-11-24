import React, { useState } from 'react';
import HttpClient from '../../common/http';

const SmsVerification = ({ useSmsAuth, phoneNumberVerified }) => {
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
      setError("could not complete phone number verification")
      return
    }

    if (resp.status === 200) {
      setSmsAuthEnabled(true);
      setShowSuccessMessage(true);
    } else {
      setError("could not complete phone number verification")
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
      <div className="field">
        {smsAuthEnabled
          ? <button
            className="btn bg-muted"
            onClick={() => handleDisable()}>
            Disable SMS Login
          </button>
          : null
        }
        {!smsAuthEnabled
          ?
          <button
            disabled={smsSent}
            className={"btn" + (smsSent ? " bg-muted" : "")}
            onClick={() => handleEnable(phoneNumberVerified, setSmsSent)}>
            Enable SMS Login
          </button>
          : null
        }
      </div>
      {smsSent && !smsAuthEnabled ? <div>
        <form onSubmit={(e) => {
          e.preventDefault()
          completePhoneNumberVerification()
        }}>
          <div className="field">
            <label>
              A text message has just been sent to your phone number provided above.
              <br/>
              Please enter the 6 digit code to validate your phone number.
            </label>
            <input
              type="text"
              placeholder="Verification Code"
              onChange={(e) => setLoginCode(e.target.value)}
            />
          </div>

          <button className="btn" type="submit">Submit</button>
        </form>
      </div> : null}
      {showSuccessMessage ? <span>You've successfully enabled SMS login!</span> : null}
      {error ? <span>{error}</span> : null}
    </div>
  )
}


export default SmsVerification;
