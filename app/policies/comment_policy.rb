class CommentPolicy < ApplicationPolicy
  def new?
    user.admin? || record.commentable.event.users.include?(user)
  end

  def create?
    user.admin? || record.commentable.event.users.include?(user)
  end
end
