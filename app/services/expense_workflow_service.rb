class ExpenseWorkflowService
  def initialize(expense, user)
    @expense = expense
    @user = user
  end

  def approve!
    return false unless can_approve?

    from_state = @expense.aasm_state
    @expense.approved_by = @user
    @expense.approve!
    @expense.record_transition(from_state, 'approved')
    true
  end

  def reject!(reason = nil)
    return false unless can_approve?

    from_state = @expense.aasm_state
    @expense.approved_by = @user
    @expense.reject!
    @expense.record_transition(from_state, 'rejected',reason)
    true
  end

  def reimburse!
    return false unless can_reimburse?

    from_state = @expense.aasm_state
    @expense.reimburse!
    @expense.record_transition(from_state, 'reimbursed')
    true
  end

  def archive!
    from_state = @expense.aasm_state
    @expense.archive!
    @expense.record_transition(from_state, 'archived')
    true
  end

  private

  def can_approve?
    @user.admin?
  end

  def can_reimburse?
    @user.admin?
  end
end
