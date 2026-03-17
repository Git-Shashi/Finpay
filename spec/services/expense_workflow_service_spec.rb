require 'rails_helper'

RSpec.describe ExpenseWorkflowService, type: :service do
  let(:admin) { create(:user, :admin) }
  let(:expense) { create(:expense) }
  let(:service) { described_class.new(expense, admin) }

  before do
    allow(AuditLogWorker).to receive(:perform_async)
    allow(Apartment::Tenant).to receive(:current).and_return('company_beta')
  end

  describe '#approve!' do
    context 'when expense is pending' do
      it 'returns true' do
        expect(service.approve!).to be true
      end

      it 'transitions expense to approved' do
        service.approve!
        expect(expense.reload).to be_approved
      end

      it 'sets approved_by to the user' do
        service.approve!
        expect(expense.reload.approved_by).to eq(admin)
      end

      it 'creates an activity log entry' do
        expect { service.approve! }.to change(ActivityLog, :count).by(1)
      end

      it 'enqueues an AuditLogWorker job' do
        service.approve!
        expect(AuditLogWorker).to have_received(:perform_async)
          .with(expense.id, 'status_changed to approved', 'company_beta')
      end
    end

    context 'when expense is already approved' do
      let(:expense) { create(:expense, :approved) }

      it 'returns false' do
        expect(service.approve!).to be false
      end

      it 'does not enqueue an AuditLogWorker job' do
        service.approve!
        expect(AuditLogWorker).not_to have_received(:perform_async)
      end
    end
  end

  describe '#reject!' do
    context 'when expense is pending' do
      it 'returns true' do
        expect(service.reject!).to be true
      end

      it 'transitions expense to rejected' do
        service.reject!
        expect(expense.reload).to be_rejected
      end

      it 'stores rejection reason in activity log' do
        service.reject!('over budget')
        log = ActivityLog.last
        expect(log.reason).to eq('over budget')
      end

      it 'enqueues an AuditLogWorker job' do
        service.reject!
        expect(AuditLogWorker).to have_received(:perform_async)
          .with(expense.id, 'status_changed to rejected', 'company_beta')
      end
    end

    context 'when expense is already rejected' do
      let(:expense) { create(:expense, :rejected) }

      it 'returns false' do
        expect(service.reject!).to be false
      end
    end
  end

  describe '#reimburse!' do
    context 'when expense is approved' do
      let(:expense) { create(:expense, :approved) }

      it 'returns true' do
        expect(service.reimburse!).to be true
      end

      it 'transitions expense to reimbursed' do
        service.reimburse!
        expect(expense.reload).to be_reimbursed
      end

      it 'enqueues an AuditLogWorker job' do
        service.reimburse!
        expect(AuditLogWorker).to have_received(:perform_async)
          .with(expense.id, 'status_changed to reimbursed', 'company_beta')
      end
    end

    context 'when expense is pending' do
      it 'returns false' do
        expect(service.reimburse!).to be false
      end
    end
  end

  describe '#archive!' do
    context 'when expense is pending' do
      it 'returns true' do
        expect(service.archive!).to be true
      end

      it 'transitions expense to archived' do
        service.archive!
        expect(expense.reload).to be_archived
      end

      it 'enqueues an AuditLogWorker job' do
        service.archive!
        expect(AuditLogWorker).to have_received(:perform_async)
          .with(expense.id, 'status_changed to archived', 'company_beta')
      end
    end

    context 'when expense is approved' do
      let(:expense) { create(:expense, :approved) }

      it 'returns true' do
        expect(service.archive!).to be true
      end
    end

    context 'when expense is already archived' do
      let(:expense) { create(:expense, :archived) }

      it 'returns false' do
        expect(service.archive!).to be false
      end
    end
  end
end
