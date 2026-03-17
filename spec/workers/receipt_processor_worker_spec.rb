require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe ReceiptProcessorWorker, type: :worker do
  let(:tenant) { 'company_beta' }
  let(:expense) { create(:expense) }
  let(:receipt) { create(:receipt, expense: expense) }

  before do
    allow(Apartment::Tenant).to receive(:switch).with(tenant).and_yield
  end

  describe '#perform' do
    it 'processes the receipt' do
      described_class.new.perform(expense.id, receipt.id, tenant)
      expect(receipt.reload.status).to eq('processed')
    end

    it 'sets processed_at on the receipt' do
      expect do
        described_class.new.perform(expense.id, receipt.id, tenant)
      end.to change { receipt.reload.processed_at }.from(nil)
    end

    it 'raises TenantNotFoundError when tenant is blank' do
      expect do
        described_class.new.perform(expense.id, receipt.id, nil)
      end.to raise_error(TenantNotFoundError)
    end

    it 'raises TenantNotFoundError when tenant is empty string' do
      expect do
        described_class.new.perform(expense.id, receipt.id, '')
      end.to raise_error(TenantNotFoundError)
    end

    it 'raises ActiveRecord::RecordNotFound for unknown expense_id' do
      expect do
        described_class.new.perform(0, receipt.id, tenant)
      end.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'raises ActiveRecord::RecordNotFound for unknown receipt_id' do
      expect do
        described_class.new.perform(expense.id, 0, tenant)
      end.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'logs the error message on failure' do
      allow(Expense).to receive(:find).and_raise(StandardError, 'disk full')
      expect(Rails.logger).to receive(:error).with(a_string_including('ReceiptProcessorWorker'))
      expect do
        described_class.new.perform(expense.id, receipt.id, tenant)
      end.to raise_error(StandardError, 'disk full')
    end
  end

  describe '.perform_async' do
    it 'enqueues the job' do
      Sidekiq::Testing.fake! do
        described_class.jobs.clear
        expect do
          described_class.perform_async(expense.id, receipt.id, tenant)
        end.to change(described_class.jobs, :size).by(1)
      end
    end

    it 'enqueues with correct arguments' do
      Sidekiq::Testing.fake! do
        described_class.jobs.clear
        described_class.perform_async(expense.id, receipt.id, tenant)
        job = described_class.jobs.last
        expect(job['args']).to eq([expense.id, receipt.id, tenant])
      end
    end
  end
end
