# frozen_string_literal: true

class CommentPolicy < ApplicationPolicy
  def new?
    user.admin? || record.commentable.event.users.include?(user)
  end

  def create?
    user.admin? || record.commentable.event.users.include?(user)
  end

  def edit?
    user.admin? || record.commentable.event.users.include?(user)
  end

  def update?
    user.admin? || record.commentable.event.users.include?(user)
  end
end
