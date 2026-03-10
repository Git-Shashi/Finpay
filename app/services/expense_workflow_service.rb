class ExpenseWorkflowService
  def initialize(expense, user)
    @expense = expense
    @user = user
  end

  def approve!
    return false unless can_approve?
    @expense.approved_by = @user
    @expense.approve!
    true
  end

  def reject!(reason = nil)
    return false unless can_approve?
    @expense.approved_by = @user
    @expense.reject!
    ActivityLog.create!(
      expense: @expense,
      user: @user,
      from_state: 'pending',
      to_state: 'rejected',
      reason: reason
    )
    true
  end

  def reimburse!
    return false unless can_reimburse?
    @expense.reimburse!
    true
  end

  def archive!
    @expense.archive!
    true
  end

  private

  def can_approve?
    @user.admin? || @user.manager?
  end

  def can_reimburse?
    @user.admin? || @user.manager?
  end
end