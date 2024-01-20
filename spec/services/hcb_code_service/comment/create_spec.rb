# frozen_string_literal: true

require "rails_helper"

describe HcbCodeService::Comment::Create do
  context "when hcb_code exists" do
    it "creates a new comment associated with the hcb_code" do
      hcb_code = create(:hcb_code)
      user = create(:user)

      comment = described_class.new(hcb_code_id: hcb_code.id,
                                    content: "Example comment",
                                    current_user: user,
                                    admin_only: true).run


      expect(comment).to be_a(Comment)
      expect(comment.persisted?).to eq(true)
      expect(comment.commentable).to eq(hcb_code)
      expect(comment.user).to eq(user)
      expect(comment.content).to eq("Example comment")
      expect(comment.admin_only).to eq(true)
    end
  end
  context "when hcb_code doesn't exist" do
    it "raises an exception" do
      user = create(:user)
      expect {
        described_class.new(hcb_code_id: -1,
                            content: "Example comment",
                            current_user: user,
                            admin_only: true).run
      }.to raise_error(ActiveRecord::RecordNotFound, "Couldn't find HcbCode with 'id'=-1")
    end
  end
end
