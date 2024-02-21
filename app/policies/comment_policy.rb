# frozen_string_literal: true

class CommentPolicy < ApplicationPolicy
  class Scope
    def initialize(user, scope)
      @user  = user
      @scope = scope
    end

    def resolve
      if user.admin?
        scope.all
      else
        scope.not_admin_only
      end
    end

    private

    attr_reader :user, :scope

  end

  def new?
    user.admin? || users.include?(user)
  end

  def create?
    user.admin? || users.include?(user)
  end

  def edit?
    user.admin? || (users.include?(user) && record.user == user)
  end

  def update?
    user.admin? || (users.include?(user) && record.user == user)
  end

  def show?
    user.admin? || (users.include?(user) && !record.admin_only)
  end

  private

  def users
    record.commentable.respond_to?(:events) ? record.commentable.events.collect(&:users).flatten : record.commentable.event.users
  end

end
