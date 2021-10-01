# frozen_string_literal: true

require "cgi"

module HcbCodeHelper
  def report_transaction_airtable_form_url(embed: false, hcb_code: nil, user: nil)
    # The airtable form is located within the Bank Promotions base
    form_id = "shrf05pqZMlRs3gYJ"
    embed_url = "https://airtable.com/embed/#{form_id}"
    url = "https://airtable.com/#{form_id}"

    prefill = []
    prefill << "prefill_Your+Name=#{CGI.escape(user.full_name)}" if user
    prefill << "prefill_Login+Email=#{CGI.escape(user.email)}" if user
    prefill << "prefill_Transaction+Url=#{CGI.escape(url_for([hcb_code, { :only_path => false }]))}" if hcb_code

    (embed ? embed_url : url) + "?" + prefill.join("&")
  end
end