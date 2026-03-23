module Api
  module V1
    class ExpensesController < Api::V1::BaseController
      before_action :authenticate_user!

      def index
        expenses = filtered_expenses.page(params[:page]).per(params[:per_page] || 10)

        render json: {
          expenses: ExpenseListSerializer.new(expenses).as_json,
          pagination: pagination_meta(expenses)
        }, status: :ok
      end

      def show
        authorize expense
        render_success ExpenseSerializer.new(expense).serialize
      end

      def create
        expense = current_user.expenses.build(expense_params)
        authorize expense
        expense.save!
        AuditLogWorker.perform_async(expense.id, 'created', Apartment::Tenant.current)
        render_created ExpenseSerializer.new(expense).serialize
      end

      def update
        authorize expense
        expense.update!(expense_params)
        render_success ExpenseSerializer.new(expense).serialize
      end

      def approve
        authorize expense
        service = ExpenseWorkflowService.new(expense, current_user)
        if service.approve!
          render_success ExpenseSerializer.new(expense).serialize
        else
          render_error I18n.t('expenses.errors.invalid_state')
        end
      end

      def reject
        authorize expense
        service = ExpenseWorkflowService.new(expense, current_user)
        if service.reject!(params[:reason])
          render_success ExpenseSerializer.new(expense).serialize
        else
          render_error I18n.t('expenses.errors.invalid_state')
        end
      end

      def reimburse
        authorize expense
        service = ExpenseWorkflowService.new(expense, current_user)
        if service.reimburse!
          render_success ExpenseSerializer.new(expense).serialize
        else
          render_error I18n.t('expenses.errors.invalid_state')
        end
      end

      def archive
        authorize expense
        service = ExpenseWorkflowService.new(expense, current_user)
        if service.archive!
          render_success ExpenseSerializer.new(expense).serialize
        else
          render_error I18n.t('expenses.errors.invalid_state')
        end
      end

      def destroy
        authorize expense
        expense.destroy
        render_no_content
      end

      # Receipt actions (nested under expenses)
      def receipts
        authorize expense, :receipts?
        render_success ReceiptSerializer.new(expense.receipts).serialize
      end

      def create_receipt
        authorize expense, :create_receipt?
        receipt = expense.receipts.create!(receipt_params)
        ReceiptProcessorWorker.perform_async(expense.id, receipt.id, Apartment::Tenant.current)
        render_created ReceiptSerializer.new(receipt).serialize
      end

      def destroy_receipt
        authorize expense, :destroy_receipt?
        receipt = expense.receipts.find(params[:receipt_id])
        receipt.destroy
        render_no_content
      end

      private

      def filtered_expenses
        expenses = policy_scope(Expense).includes(:user, :category, :receipts)

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

      def receipt_params
        params.require(:receipt).permit(:file, :amount, :receipt_date, :notes)
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
  end
end
