module StaticPagesHelper
  def card_to(name, path, options = {})
    return '' if options[:badge] == 0

    badge = options[:badge].to_i > 0 ? badge_for(options[:badge]) : ''
    link_to content_tag(:li,
                        [content_tag(:strong, name), badge].join.html_safe,
                        class: 'card card--item card--hover relative overflow-visible line-height-3'),
                        path, method: options[:method]
  end

  def pending_hackathon_listings_path
    'https://airtable.com/tblYVTFLwY378YZa4/viwpJOp6ZmMDfcbgb?blocks=hide'
  end

  def pending_grant_listings_path
    'https://airtable.com/tblsYQ54Rg1Pjz1xP/viwjETKo05TouqYev?blocks=hide'
  end

  def random_nickname
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
        'Open on weekends',
        'Open on holidays',
        "please don't hack",
        'HCB– Happily Celebrating Bees',
        'HCB– Hungry Computer Bison',
        'HCB– Huge Cellophane Boats',
        'HCB– Hydrofoils Chartered by Bandits',
        'The best thing since sliced bread',
        'Hack Club Bink',
        'Hack 👏 Club 👏 Bank 👏',
        '💻 ♣ 🏦',
        'aka Hack Bank',
        'aka Hank',
        'Open late',
        'From the makers of Hack Club',
        'Now in color!',
        'Filmed on location',
        'From the makers of Hack Club Bank',
        'Soon to be a major cryptocurrency!',
        'As seen on the internet',
        '👏 KEEP 👏 YOUR 👏 RECEIPTS 👏',
        'Money: collect it all!',
        "Help, I'm trapped in the internet!",
        "Most viewed site on this domain!",
        'Coming to a browser near you',
        'Hand-crafted by our resident byte-smiths',
        'B O N K',
        '80% bug free!',
        '20% less bugs!',
        'Ask your doctor if Hack Club Bank is right for you',
        'Now with "code"',
        'Closed source!',
        'Finally complete!',
        'Internet enabled!',
        "It's finally here!",
        "It's finished!",
        'Holds lots of cents',
        'It just makes cents',
        'By hackers for hackers',
        'Over 100 users!',
        'Over 20 accounts!',
        'Over $1,000,000 served!',
        'One of a kind!',
        'Reticulating splines...',
        'Educational!',
        "Don't use while driving",
        'Support local businesses!',
        'Take frequent breaks!',
        'Technically good!',
        "That's Numberwang!",
        "The bee's knees!",
        'Greater than the sum of its transactions!',
        'Greater than the sum of its donations!',
        'Operating at a loss since 2018!',
        'The sum of its parts!',
        'Wash your hands!',
        'Does anyone actually read this?',
        'Like and subscribe!',
        'Like that smash button!',
        'it protec, and also attac, but most importantly it pay fees back',
        'it secures the bag',
        'Protec but also attac',
        'As seen on bank.hackclub.com',
        'As seen on hackclub.com',
        '2 cool 4 scool',
        'Now running in production!',
        "Don't touch your face!",
        'put money in computer',
        'TODO: get that bread',
        'Coming soon to a screen near your face',
        'Coming soon to a screen year you',
        'As seen on the internet',
        "Operating at a loss so you don't have to",
        'Made by a non-profit for non-profits',
        'By hackers, for hackers',
        'It holds money!',
        'uwu',
        'Red acting kinda sus'
      ].sample
    end
  end
end
