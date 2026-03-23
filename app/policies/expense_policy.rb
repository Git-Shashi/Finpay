class ExpensePolicy < ApplicationPolicy
  # NOTE: Up to Pundit v2.3.1, the inheritance was declared as
  # `Scope < Scope` rather than `Scope < ApplicationPolicy::Scope`.
  # In most cases the behavior will be identical, but if updating existing
  # code, beware of possible changes to the ancestors:
  # https://gist.github.com/Burgestrand/4b4bc22f31c8a95c425fc0e30d7ef1f5

  class Scope < ApplicationPolicy::Scope
    def resolve
      user.admin? ? scope.all : scope.where(user: user)
    end
  end

  def show?
    user.admin? || record.user == user
  end

  def create?
    true
  end

  def update?
    user.admin? || record.user == user
  end

  def destroy?
    user.admin? || record.user == user
  end

  def approve?
    user.admin?
  end

  def reject?
    user.admin?
  end

  def reimburse?
    user.admin?
  end

  def archive?
    user.admin?
  end

  def receipts?
    user.admin? || record.user == user
  end

  def create_receipt?
    user.admin? || record.user == user
  end

  def destroy_receipt?
    user.admin? || record.user == user
  end
end
