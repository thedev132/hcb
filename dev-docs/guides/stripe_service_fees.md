# Stripe service fees: why do we have them and how do they work?

Stripe charges us all sorts of fees to use their platform, especially when it comes to issuing. Foreign exchange fees and card printing fees are an example. For the longest time, we weren’t paying these fees so we were slowly leaking money and had no idea where it was going.

Now, we run [`StripeServiceFeeJob`](https://github.com/hackclub/hcb/blob/main/app/jobs/stripe_service_fee_job.rb) every week to list out those fees we’re charged (they are all negative balance transactions on our Stripe account) and top up our Stripe account to cover that fee.

These top ups are auto-mapped to the “Hack Club Bank” organisation on HCB and they're associated with a HCB code via a short code.

\- [@sampoder](https://github.com/sampoder)
