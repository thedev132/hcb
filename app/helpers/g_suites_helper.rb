module GSuitesHelper
  def g_suite_summary_color(status)
    case status
    when :start then :blue
    when :under_review then :orange
    when :app_accepted then :yellow
    when :verify_setup then :red
    when :done then :green
    end
  end
end
