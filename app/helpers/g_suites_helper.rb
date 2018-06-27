module GSuitesHelper
  def g_suite_summary_color(status)
    case status
    when :start then :primary
    when :under_review then :accent
    when :app_accepted then :info
    when :app_rejected then :error
    when :verify_setup then :primary
    when :done then :success
    end
  end
end
