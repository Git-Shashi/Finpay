require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe AuditLogWorker, type: :worker do
  let(:tenant) { 'company_beta' }
  let(:expense) { create(:expense) }

  before do
    allow(Apartment::Tenant).to receive(:switch).with(tenant).and_yield
  end

  describe '#perform' do
    it 'creates an activity log for the expense' do
      expect {
        described_class.new.perform(expense.id, 'created', tenant)
      }.to change(ActivityLog, :count).by(1)
    end

    it 'stores the correct action in the log' do
      described_class.new.perform(expense.id, 'approved', tenant)
      expect(ActivityLog.last.action).to eq('approved')
    end

    it 'associates the log with the correct expense' do
      described_class.new.perform(expense.id, 'created', tenant)
      expect(ActivityLog.last.expense).to eq(expense)
    end

    it 'raises TenantNotFoundError when tenant is blank' do
      expect {
        described_class.new.perform(expense.id, 'created', nil)
      }.to raise_error(TenantNotFoundError)
    end

    it 'raises TenantNotFoundError when tenant is empty string' do
      expect {
        described_class.new.perform(expense.id, 'created', '')
      }.to raise_error(TenantNotFoundError)
    end

    it 'raises ActiveRecord::RecordNotFound for unknown expense_id' do
      expect {
        described_class.new.perform(0, 'created', tenant)
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'logs the error message on failure' do
      allow(Expense).to receive(:find).and_raise(StandardError, 'db connection lost')
      expect(Rails.logger).to receive(:error).with(a_string_including('AuditLogWorker'))
      expect {
        described_class.new.perform(expense.id, 'created', tenant)
      }.to raise_error(StandardError, 'db connection lost')
    end
  end

  describe 'sidekiq options' do
    it 'has retry set to 5' do
      expect(described_class.sidekiq_options['retry']).to eq(5)
    end
  end

  describe '.perform_async' do
    it 'enqueues the job' do
      Sidekiq::Testing.fake! do
        described_class.jobs.clear
        expect {
          described_class.perform_async(expense.id, 'created', tenant)
        }.to change(described_class.jobs, :size).by(1)
      end
    end

    it 'enqueues with correct arguments' do
      Sidekiq::Testing.fake! do
        described_class.jobs.clear
        described_class.perform_async(expense.id, 'approved', tenant)
        job = described_class.jobs.last
        expect(job['args']).to eq([expense.id, 'approved', tenant])
      end
    end
  end
end
