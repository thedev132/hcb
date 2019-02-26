class TransactionPolicy < ApplicationPolicy
  def index?
    user.admin? ||
    record.all? { |r| r.event.users.include? user }
  end

  def show?
    user.admin? || record&.event&.users&.include?(user)
  end

  def edit?
    user.admin? || record&.event&.users&.include?(user)
  end

  def update?
    user.admin? || record&.event&.users&.include?(user)
  end
end
