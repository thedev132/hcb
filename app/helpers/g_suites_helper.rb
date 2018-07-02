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

  def example_email_username
    current_user.full_name.to_s.length > 3 ? current_user.full_name.downcase.split(' ').first : 'yourname'
  end

  def example_email_domain(event = @event)
    "#{event.name.to_s.downcase.gsub(' ', '')}.com"
  end

  def example_email(event = @event)
    "#{example_email_username}@#{example_email_domain(event)}"
  end
end
