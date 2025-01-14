# InfraFi and SVB Sweep account

Column is our main bank account, however, it has a low interest rate (APY). As a
result, we sweep 🧹 excess money to InfraFi to earn a higher interest rate.

Our InfraFi account is managed through SVB. Every day, SVB will push/pull money
between SVB FS Main and InfraFi such that SVB FS Main's balance is $250k.

## Bank Transactions (from SVB's perspective)

The memos of these transactions look like:

- `TF TO ICS SWP`: Transfer to InfraFi (withdrawal on SVB; deposit on InfraFi)
- `TF FRM ICS SWP`: Transfer from InfraFi (deposit on SVB; withdrawal on
  InfraFi)

## Bank Transactions (from InfraFi's perspective)

InfraFi's ICS (InfraFi Cash Sweep) dashboard, provides a 45-day transaction
history. Types of transactions include:

- `Deposit`: Money came in from SVB
- `Withdrawal`: Money went out to SVB
- `Interest Capitalization`: oooh, free money! 🤑

What's "Interest Capitalization" you ask? well, read on 📖

## Interest Accrual & Capitalization

InfraFi's interest rate fluctuates. As of time of writing (2025-01-14), our APY
is 3.35%; down from 3.55% in 2024-12-18. Interest is accrued based on our
**InfraFi Principal Balance**. This is amount of money that's currently in our
InfraFi account; which excludes any interest that's been accrued but not yet
paid out.

On the last day of each month, InfraFi pays out the accrued interest via an
**Interest Capitalization** transaction. This transaction takes our accrued
interest from that month and adds it to our **InfraFi Principal Balance**.

## Transaction Syncing to HCB

Usually, we sync all of Hack Club's active bank account into HCB. However,
InfraFi is the one exception. InfraFi unfortunately does play well with Plaid.

At the moment, we do not sync InfraFi's transactions into this HCB. This means
that the `HCB Sweeps` organization on HCB has a negative balance. That negative
balance reflects the sum of all deposits and withdrawals to/from InfraFi. It
excludes all interest capitalization transactions.

In other words:

- `HCB Sweep's balance` == `Sum of InfraFi's Deposits + Withdrawals`
- and `HCB Sweep's balance` + `Interest Capitalization transactions` ==
  `InfraFi's Principle Balance`
- and `HCB Sweep's balance` + `Interest Capitalization transactions` +
  `InfraFi's Accrued interest` ==
  `InfraFi's Principle Balance` + `InfraFi's Accrued interest`

We have a goal to important all of InfraFi's
transactions: https://github.com/hackclub/hcb/issues/9209

When that happens, HCB Sweep's balance should reflect the sum of all interest
capitalization transactions. That balance should increase at the end of each
month when the Interest Capitalization transaction hits our account.

\- [@garyhtou](https://garytou.com)
