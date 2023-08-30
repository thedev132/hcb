# frozen_string_literal: true

module StaticPagesHelper
  extend ActionView::Helpers::NumberHelper

  def card_to(name, path, options = {})
    return "" if options[:badge] == 0

    badge = if options[:badge].to_i > 0
              badge_for(options[:badge], class: !options[:subtle_badge] ? "bg-accent pr2" : "pr2")
            else
              ""
            end
    link_to content_tag(:li,
                        [content_tag(:strong, name), badge].join.html_safe,
                        class: "card card--item card--hover flex justify-between overflow-visible line-height-3"),
            path, method: options[:method]
  end

  def flavor_text
    FlavorTextService.new(user: current_user).generate
  end

  def link_to_airtable_task(task_name)
    airtable_info[task_name][:destination]
  end

  def airtable_info
    {
      hackathons: {
        url: "https://airbridge.hackclub.com/v0.1/hackathons.hackclub.com/applications",
        query: { filterByFormula: "AND(Approved=0,Rejected=0)", fields: [] },
        destination: "https://airtable.com/tblYVTFLwY378YZa4/viwpJOp6ZmMDfcbgb"
      },
      grant: {
        url: "https://airbridge.hackclub.com/v0.1/Bank%20Promotions/Github%20Grant",
        query: { filterByFormula: "Status='Pending'", fields: [] },
        destination: "https://airtable.com/tblsYQ54Rg1Pjz1xP/viwjETKo05TouqYev"
      },
      onboard_id: {
        url: "https://airbridge.hackclub.com/v0.1/OnBoard/Verifications",
        query: { filterByFormula: "Status='Pending'", fields: [] },
        destination: "https://airtable.com/tblVZwB8QMUSDAd41/viwJ15CT6VHCZ0UZ4"
      },
      bank_applications: {
        url: "https://airbridge.hackclub.com/v0.1/Bank%20Applications%20Database/Events",
        query: { filterByFormula: "Pending='Pending'", fields: [] },
        destination: "https://airtable.com/tblctmRFEeluG4do7/viwGhv19cV1ZRj61a"
      },
      stickers: {
        url: "https://airbridge.hackclub.com/v0.1/Bank%20Promotions/Bank%20Stickers",
        query: { filterByFormula: "Status='Pending'", fields: [] },
        destination: "https://airtable.com/tblyhkntth4OyQxiO/viwHcxhOKMZnPXUUU"
      },
      stickermule: {
        url: "https://airbridge.hackclub.com/v0.1/Bank%20Promotions/StickerMule",
        query: { filterByFormula: "Status='Pending'", fields: [] },
        destination: "https://airtable.com/tblwYTdp2fiBv7JqA/viwET9tCYBwaZ3NIq"
      },
      replit: {
        url: "https://airbridge.hackclub.com/v0.1/Bank%20Promotions/Repl.it%20Hacker%20Plan",
        query: { filterByFormula: "Status='Pending'", fields: [] },
        destination: "https://airtable.com/tbl6cbpdId4iA96mD/viw2T8d98ZhhacHCf"
      },
      sendy: {
        url: "https://airbridge.hackclub.com/v0.1/Bank%20Promotions/Sendy",
        query: { filterByFormula: "Status='Pending'", fields: [] },
        destination: "https://airtable.com/tbl1MRaNpF4KphbOd/viwb7ELYyxpuAz6gQ"
      },
      domains: {
        url: "https://airbridge.hackclub.com/v0.1/Bank%20Promotions/Domains",
        query: { filterByFormula: "Status='Pending'", fields: [] },
        destination: "https://airtable.com/tbl22cXd3Bo9uo0wp/viwcnZyoctJTFGVY2"
      },
      onepassword: {
        url: "https://airbridge.hackclub.com/v0.1/Bank%20Promotions/1Password",
        query: { filterByFormula: "Status='Pending'", fields: [] },
        destination: "https://airtable.com/tblcHEZyos3V9DoeI/viwSapKZ8C4ByBuqT"
      },
      pvsa: {
        url: "https://airbridge.hackclub.com/v0.1/Bank%20Promotions/PVSA%20Order",
        query: { filterByFormula: "Status='Pending'", fields: [] },
        destination: "https://airtable.com/tbl4ffIbyaEa2fIYW/viw2OPTziXEqOpaLA"
      },
      theeventhelper: {
        url: "https://airbridge.hackclub.com/v0.1/Bank%20Promotions/Event%20Insurance",
        query: { filterByFormula: "Status='Pending'", fields: [] },
        destination: "https://airtable.com/tblWlQxkf6L7mEjC4/viwzbku7oWsw5GFEa"
      },
      first_grant: {
        url: "https://airbridge.hackclub.com/v0.1/Bank%20Promotions/FIRST%20Grant",
        query: { filterByFormula: "Status='Pending'", fields: [] },
        destination: "https://airtable.com/tblnNB5iMbidfB552/viwjF8iDPU3gAiXJU"
      },
      wire_transfers: {
        url: "https://airbridge.hackclub.com/v0.1/Bank%20Promotions/Wire%20Transfers",
        query: { filterByFormula: "Status='Pending'", fields: [] },
        destination: "https://airtable.com/tbloFbH16HI7t3mfG/viwzgt8VLHOC82m8n"
      },
      paypal_transfers: {
        url: "https://airbridge.hackclub.com/v0.1/Bank%20Promotions/PayPal%20Transfers",
        query: { filterByFormula: "Status='Pending'", fields: [] },
        destination: "https://airtable.com/tbloGiW2jhja8ivtV/viwzhAnWYhpFNhvmC"
      },
      disputed_transactions: {
        url: "https://airbridge.hackclub.com/v0.1/Bank%20Promotions/Disputed%20Transactions",
        query: { filterByFormula: "Status='Pending'", fields: [] },
        destination: "https://airtable.com/appEzv7w2IBMoxxHe/tblTqbwz5AUkzOcVb"
      },
      feedback: {
        url: "https://airbridge.hackclub.com/v0.1/Bank%20Promotions/Feedback",
        query: { filterByFormula: "Status='Pending'", fields: [] },
        destination: "https://airtable.com/tblOmqLjWtJZWXn4O/viwuk2j4xsKJo5EqA"
      },
      wallets: {
        url: "https://airbridge.hackclub.com/v0.1/Bank%20Promotions/Wallets",
        query: { filterByFormula: "Status='Pending'", fields: [] },
        destination: "https://airtable.com/tblJtjtY9qAOG3FS8/viwUz9aheNAvXwzjg"
      },
      google_workspace_waitlist: {
        url: "https://airbridge.hackclub.com/v0.1/Bank%20Promotions/Google%20Workspace%20Waitlist",
        query: { filterByFormula: "Status='Pending'", fields: [] },
        destination: "https://airtable.com/appEzv7w2IBMoxxHe/tbl9CkfZHKZYrXf1T/viwgfJvrrD9Jn9VLj"
      }
    }
  end
end
