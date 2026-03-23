require 'rails_helper'

RSpec.describe ExpensePolicy, type: :policy do
  let(:user) { User.new }

  subject { described_class }

  permissions ".scope" do
    pending "add some examples to (or delete) #{__FILE__}"
  end

  permissions :show? do
   context "when the user is the owner of the expense" do
      let(:expense) { Expense.new(user: user) }

      it "allows access" do
        expect(subject).to permit(user, expense)
      end
    end
    context "when the user is the admin" do
      let(:admin) { User.new(admin: true) }
      let(:expense) { Expense.new(user: User.new) }

      it "allows access" do
        expect(subject).to permit(admin, expense)
      end
    end
    context "when the user is not the owner and not an admin" do
      let(:other_user) { User.new }
      let(:expense) { Expense.new(user: User.new) }

      it "denies access" do
        expect(subject).not_to permit(other_user, expense)
      end
  end

  permissions :create? do
    pending "add some examples to (or delete) #{__FILE__}"
  end

  permissions :update? do
    pending "add some examples to (or delete) #{__FILE__}"
  end

  permissions :destroy? do
    pending "add some examples to (or delete) #{__FILE__}"
  end
end
