class UserPolicy < ApplicationPolicy
  def index?
    user&.admin?
  end

  def show?
    user.present? && (user.admin? || user == record)
  end

  def create?
    user&.admin?
  end

  def update?
    user.present? && (user.admin? || user == record)
  end

  def destroy?
    user&.admin? && user != record # Admin can't delete themselves
  end

  def change_role?
    user&.admin? && user != record
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user&.admin?
        scope.all
      else
        scope.where(id: user.id) # Users can only see themselves
      end
    end
  end

  # Custom permissions for user-specific actions
  def update_profile?
    user.present? && (user.admin? || user == record)
  end

  def change_password?
    user.present? && user == record
  end
end 
