# frozen_string_literal: true

class CommentMailerPreview < ActionMailer::Preview
  def notification
    commentable = HcbCode.joins(:comments).order("comments.created_at DESC").first
    comment = commentable.comments.last
    CommentMailer.with(comment:,).notification
  end

end
