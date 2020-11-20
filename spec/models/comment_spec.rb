# frozen_string_literal: true

require "rails_helper"

RSpec.describe Comment, type: :model do
  fixtures "users",  "transactions", "comments"

  let(:transaction) { transactions(:transaction1) }
  let(:comment) { comments(:comment1) }

  before do
    comment.commentable_type = Transaction
    comment.commentable_id = transaction.id
  end

  it "is valid" do
    expect(comment).to be_valid
  end

  context "when missing content" do
    before do
      comment.content = ""
    end

    it "is not valid" do
      expect(comment).not_to be_valid
    end

    context "has attachment" do
      before do
        comment.file.attach(
          io: File.open(Rails.root.join("spec", "fixtures", "files", "attachment1.txt")),
          filename: "attachment1.txt",
          content_type: "text/plain"
        )
      end

      it "is valid" do
        expect(comment).to be_valid
      end
    end
  end
end
