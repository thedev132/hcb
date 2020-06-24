module CardsHelper
  def card_mention(card)
    icon = inline_icon 'card', size: 24, class: 'purple'
    if organizer_signed_in?
      text = content_tag :span, card.last_four
      return link_to(card, class: 'mention') { icon + text }
    else
      text = content_tag :span, 'XXXX'
      return link_to(root_path, class: 'mention') { icon + text }
    end
  end

  def one_isnt_completed?(emburse_transactions)
    emburse_transactions.collect { |a| !a.completed? }.include?(true)
  end
end
