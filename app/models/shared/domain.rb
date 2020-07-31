module Shared
  module Domain
    private

    def domain_without_protocol
      bad = ['http', ':', '/'].any? { |s| domain.to_s.include? s }
      errors.add(:domain, 'shouldn’t include http(s):// or ending /') if bad
    end

    def domain_not_email
      errors.add(:domain, 'shouldn’t be an email address') if domain.to_s.include? '@'
    end

    def domain_is_lowercase
      return if domain.to_s.downcase == domain

      errors.add(:domain, 'must be all lowercase')
    end
  end
end
