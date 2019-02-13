module TransactionsHelper
  def transactions_filter_item(label, name, selected = false)
    content_tag :a, label, class: 'filterbar__item',
      tabindex: 0, role: 'tab', 'aria-selected': selected,
      data: { name: name.to_s, behavior: 'transactions_filter_item' }
  end
end
