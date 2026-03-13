class ExpensesController < ApplicationController
  before_action :authenticate_user!

  def index
    expenses = filtered_expenses
    expenses = expenses.page(params[:page]).per(params[:per_page] || 10)

    render json: {
      expenses: ExpenseListSerializer.new(expenses).as_json,
      pagination: pagination_meta(expenses)
    }, status: :ok
  end

  def show
    if expense
      render json: ExpenseSerializer.new(expense).as_json
    else
      render json: { error: I18n.t('expenses.errors.not_found') }, status: :not_found
    end
  end

  def create
    expense = current_user.expenses.build(expense_params)
    if expense.save
      AuditLogWorker.perform_async(expense.id, 'created',Apartment::Tenant.current) 
      render json: ExpenseSerializer.new(expense).as_json, status: :created
    else
      render json: { errors: expense.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if expense
      expense.update!(expense_params)
      render json: ExpenseSerializer.new(expense).as_json
    else
      render json: { error: I18n.t('expenses.errors.not_found') }, status: :not_found
    end
  end

  def approve
    return unless authorize_user!

    service = ExpenseWorkflowService.new(expense, current_user)
    if service.approve!
      render json: ExpenseSerializer.new(expense).as_json, status: :ok
    else
      render json: { error: I18n.t('expenses.errors.invalid_state') }, status: :unprocessable_entity
    end
  end

  def reject
    return unless authorize_user!

    service = ExpenseWorkflowService.new(expense, current_user)
    if service.reject!(params[:reason])
      render json: ExpenseSerializer.new(expense).as_json, status: :ok
    else
      render json: { error: I18n.t('expenses.errors.invalid_state') }, status: :unprocessable_entity
    end
  end

  def reimburse
    return unless authorize_user!

    service = ExpenseWorkflowService.new(expense, current_user)
    if service.reimburse!
      render json: ExpenseSerializer.new(expense).as_json, status: :ok
    else
      render json: { error: I18n.t('expenses.errors.invalid_state') }, status: :unprocessable_entity
    end
  end

  def archive
    return unless authorize_user!

    service = ExpenseWorkflowService.new(expense, current_user)
    if service.archive!
      render json: ExpenseSerializer.new(expense).as_json, status: :ok
    else
      render json: { error: I18n.t('expenses.errors.invalid_state') }, status: :unprocessable_entity
    end
  end

  def destroy
    if expense
      expense.destroy
      head :no_content
    else
      render json: { error: I18n.t('expenses.errors.not_found') }, status: :not_found
    end
  end

  private

  def authorize_user!
    unless current_user.admin?
      render json: { error: I18n.t('expenses.errors.not_authorized') }, status: :unprocessable_entity
      return false
    end
    true
  end

  def filtered_expenses
    expenses = Expense.includes(:user, :category, :receipts)

    expenses = expenses.by_category(params[:category_id]) if params[:category_id].present?
    expenses = expenses.by_status(params[:status]) if params[:status].present?

    if params[:start_date].present? && params[:end_date].present?
      expenses = expenses.by_date_range(params[:start_date], params[:end_date])
    end

    expenses
  end

  def expense
    @expense ||= Expense.find(params[:id])
  end

  def expense_params
    params.require(:expense).permit(:category_id, :amount, :description, :expense_date)
  end

  def pagination_meta(expenses)
    {
      current_page: expenses.current_page,
      next_page: expenses.next_page,
      prev_page: expenses.prev_page,
      total_pages: expenses.total_pages,
      total_count: expenses.total_count
    }
  end
end