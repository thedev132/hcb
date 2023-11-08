# frozen_string_literal: true

module HcbCodeService
  class AiGenerateMemo
    def initialize(hcb_code:)
      @hcb_code = hcb_code
    end

    def run
      conn = Faraday.new(headers: { "Authorization" => "Bearer #{Rails.application.credentials.openai.api_key}" }) do |f|
        f.request :json
        f.request :retry
        f.response :json
      end

      amount = @hcb_code.amount.abs.to_s
      description = @hcb_code.ct.try(:less_smart_memo) || @hcb_code.pt.try(:friendly_memo)

      res = conn.post(
        "https://api.openai.com/v1/completions",
        model: "davinci:ft-hack-club-2023-01-27-18-45-40",
        prompt: "Amount: $#{amount}\nTransaction Description: #{description}\nHuman-Readable Memo:",
        echo: false,
        stop: "\n",
        temperature: 0,
        top_p: 1
      )

      unless res.success?
        Airbrake.notify("Failed to contact OpenAI. #{res.status}: #{res.reason_phrase}\n#{res.body&.dig("error", "message")}")
        return nil
      end

      res.body["choices"].first["text"].strip
    end

  end
end
