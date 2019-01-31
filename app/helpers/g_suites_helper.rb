module GSuitesHelper
  def example_email_username
    name = current_user.full_name.downcase.split(' ').first
    name.blank? ? 'max' : name
  end

  def example_email_domain(event = @event)
    "#{event.name.to_s.downcase.gsub(/[^a-z0-9]/i, '')}.com"
  end

  def example_email(event = @event)
    "#{example_email_username}@#{example_email_domain(event)}"
  end
end
