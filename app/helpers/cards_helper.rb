module CardsHelper
  def card_mention(card)
    icon = inline_icon 'card', size: 24, class: 'accent'
    text = content_tag :span, card.last_four
    link_to(card, class: 'mention') { icon + text }
  end

  def one_isnt_completed?(emburse_transactions) 
    emburse_transactions.collect { |a| !a.completed? }.include?(true)
  end
end
