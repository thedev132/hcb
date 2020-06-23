module DonationsHelper
  def donation_payment_processor_fee(humanized = true, donation = @donation)
    fee = donation.amount - donation.payout.amount

    return fee unless humanized

    render_money fee
  end

  def donation_payout_type(humanized = true, donation = @donation)
    return humanized ? '–' : nil unless donation.payout

    donation.payout&.type
  end

  def donation_paid_at(donation = @donation)
    timestamp = donation&.payout&.created_at
    timestamp ? format_datetime(timestamp) : '–'
  end

  def donation_payout_datetime(donation = @donation)
    payout = donation&.payout
    payout_t = payout&.t_transaction

    refund = donation&.fee_reimbursement
    refund_t = refund&.t_transaction

    if payout_t && refund_t
      title = 'Funds available since'
      datetime = [payout_t.created_at, refund_t.created_at].max
    elsif payout_t && !refund
      title = 'Funds available since'
      datetime = payout_t.created_at
    elsif donation.payout_creation_queued_at && donation.payout.nil?
      title = 'Transfer scheduled'
      datetime = donation.payout_creation_queued_for
    elsif donation.payout_creation_queued_at && donation.payout.present?
      title = 'Funds should be available'
      datetime = donation.payout.arrival_date
    else
      return
    end

    strong_tag = content_tag :strong, title
    date_tag = format_datetime datetime

    content_tag(:p) { strong_tag + date_tag }
  end

  def donation_payment_method_mention(donation = @donation, options = {})
    payout = donation&.payout
    payout_t = donation&.payout&.t_transaction
    

    return '–' unless donation&.payment_method_type

    if donation&.payment_method_card_brand
      brand = donation&.payment_method_card_brand
      last4 = donation&.payment_method_card_last4

      icon_name = {
        'amex' => 'card-amex',
        'mastercard' => 'card-mastercard',
        'visa' => 'card-visa'
      }[brand] || 'card-other'
      tooltip = {
        'amex' => 'American Express',
        'mastercard' => 'Mastercard',
        'visa' => 'Visa',
        'discover' => 'Discover'
      }[brand] || 'Card'
      tooltip += " ending in #{last4}" if last4 && organizer_signed_in?
      description_text = organizer_signed_in? ? "••••#{last4}" : "••••"
      icon = inline_icon icon_name, width: 32, height: 20, class: 'slate'
    else
      icon_name = 'bank-account'
      size = 20
      description_text = donation.payment_method_type.humanize
    end

    description = content_tag :span, description_text, class: 'ml1'
    icon ||= inline_icon icon_name, width: size, height: size, class: 'slate'
    content_tag(:span, class: "inline-flex items-center #{options[:class]}") { icon + description }
  end
end
