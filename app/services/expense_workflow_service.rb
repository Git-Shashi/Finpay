class ExpenseWorkflowService
  def initialize(expense, user)
    @expense = expense
    @user = user
  end

  def approve!
    perform_transition('approve')
  end

  def reject!(reason = nil)
    perform_transition('reject', reason)
  end

  def reimburse!
    perform_transition('reimburse')
  end

  def archive!
    perform_transition('archive')
  end

  private

  def perform_transition(event, reason = nil)
    from_state = @expense.status
    @expense.approved_by = @user
    @expense.send("#{event}!")
    @expense.save!
    @expense.record_transition(from_state, @expense.status, reason)
    true
  rescue AASM::InvalidTransition
    false
  end
end