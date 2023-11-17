# frozen_string_literal: true

module TagsHelper
  def tag_dom_id(hcb_code, tag, suffix = "")
    "hcb_code_#{hcb_code.hashid}_tag_#{tag.id}#{suffix}"
  end

  def tag_dom_class(*args)
    ".#{tag_dom_id(*args)}"
  end
end
