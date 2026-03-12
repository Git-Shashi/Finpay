class ExpenseWorkflowService
  def initialize(expense, user)
    @expense = expense
    @user = user
  end

  def approve!
    perform_transition('approved')
  end

  def reject!(reason = nil)
    perform_transition('rejected', reason)
  end

  def reimburse!
    perform_transition('reimbursed')
  end

  def archive!
    perform_transition('archived')
  end

  private

  def perform_transition(to_state, reason = nil)
    from_state = @expense.status
    event_map = {
      'approved' => 'approve',
      'rejected' => 'reject',
      'reimbursed' => 'reimburse',
      'archived' => 'archive'
    }
    event = event_map[to_state] || to_state

    @expense.approved_by = @user
    @expense.send("#{event}!")
    @expense.save!
    @expense.record_transition(from_state, to_state, reason)
    true
  rescue AASM::InvalidTransition
    false
  end
end
