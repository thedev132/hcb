# frozen_string_literal: true

class ColumnService
  def initialize
    @conn = Faraday.new url: "https://api.column.com" do |f|
      f.request :basic_auth, "", Rails.application.credentials.column.dig(environment, :api_key)
      f.request :url_encoded
      f.response :json
      f.response :raise_error
    end
  end

  def get(url, params = {})
    @conn.get(url, params).body
  end

  def post(url, params = {})
    @conn.post(url, params).body
  end

  def transactions(from_date: 1.week.ago, to_date: Date.today, bank_account: Rails.application.credentials.column.dig(environment, :fs_main_account_id))
    # 1: fetch daily reports from Column
    reports = get(
      "/reporting",
      type: "bank_account_transaction",
      limit: 100,
      from_date: from_date.to_date.iso8601,
      to_date: to_date.to_date.iso8601,
    )["reports"].select { |r| r["from_date"] == r["to_date"] && r["row_count"]&.>(0) }

    document_ids = reports.pluck "json_document_id"

    reports.to_h do |report|
      url = get("/documents/#{report["json_document_id"]}")["url"]
      transactions = JSON.parse(Faraday.get(url).body).select { |t| t["bank_account_id"] == bank_account && t["available_amount"] != 0 }

      [report["id"], transactions]
    end

  rescue => e
    puts e.response_body
  end

  def environment
    Rails.env.production? ? :production : :sandbox
  end

end
