module GSuitesHelper
  def g_suite_summary_color(status)
    case status
    when :start then :primary
    when :under_review then :info
    when :app_accepted then :warning
    when :verify_setup then :primary
    when :done then :success
    end
  end
end
