module StaticPagesHelper
  def card_to(name, path, options = {})
    badge = options[:badge].to_i > 0 ? badge_for(options[:badge]) : ''
    link_to content_tag(:li,
                        [content_tag(:strong, name), badge].join.html_safe,
                        class: 'card card--item card--hover relative overflow-visible line-height-3'),
                        path, method: options[:method]
  end

  def random_nickname()
    if Rails.env.development?
      'Development Mode'
    else
      [
        'The hivemind known as Bank',
        'A cloud full of money',
        "Hack Club's pot of gold",
        'A sentient stack of dollars',
        'The Hack Club Federal Reserve',
        'money money money money money',
        'A money-crazed virus 🤑',
        'A cloud raining money',
        "A pile of money in the cloud",
        'Hack Club Smoothmunny',
        'Hack Club ezBUCKS',
        'Hack Club Money Bucket',
        'A mattress stuffed with 100 dollar bills', # this is the max length allowed for this header
        'Hack Club Dollaringos',
        'The Hack Foundation dba The Dolla Store',
        'Hack on.',
      ].sample
    end
  end
end
