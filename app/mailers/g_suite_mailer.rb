class GSuiteMailer < ApplicationMailer
  def notify_of_creation(params)
    @g_suite = params[:g_suite]
    @domain = @g_suite.domain
    @recipient = params[:recipient]

     mail to: @recipient,
      subject: '[Action Requested] Your G Suite is configured'
  end
end
