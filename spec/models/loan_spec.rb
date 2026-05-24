# spec/models/loan_spec.rb
require 'rails_helper'

RSpec.describe Loan, type: :model do
  let(:neighborhood) do
    Neighborhood.create!(
      name: "Sunnyvale Hills",
      radius_km: 2.0,
      slug: "sunnyvale-hills"
    )
  end

  let(:owner) do
    User.create!(
      name: "Alice Johnson",
      email: "alice@example.com",
      password: "password123",
      password_confirmation: "password123",
      address: "100 Maple St",
      neighborhood: neighborhood
    )
  end

  let(:borrower) do
    User.create!(
      name: "Bob Martinez",
      email: "bob@example.com",
      password: "password123",
      password_confirmation: "password123",
      address: "102 Maple St",
      neighborhood: neighborhood
    )
  end

  let(:item) do
    Item.create!(
      name: "Lawn Mower",
      description: "Gas powered push mower.",
      category: :garden,
      condition: :good,
      available: true,
      user: owner
    )
  end

  let(:valid_attributes) do
    {
      item: item,
      borrower: borrower,
      start_date: Date.current + 1,
      end_date: Date.current + 3,
      status: :pending
    }
  end

  describe 'Validations' do
    it 'is valid with correct attributes' do
      loan = Loan.new(valid_attributes)
      expect(loan).to be_valid
    end

    it 'is invalid if end date is equal to start date' do
      loan = Loan.new(valid_attributes.merge(end_date: valid_attributes[:start_date]))
      expect(loan).not_to be_valid
      expect(loan.errors[:end_date]).to include("must be after start date")
    end

    it 'is invalid if the borrower is the owner' do
      loan = Loan.new(valid_attributes.merge(borrower: owner))
      expect(loan).not_to be_valid
      expect(loan.errors[:base]).to include("You cannot borrow your own item")
    end
  end

  describe 'State Transitions' do
    it 'handles approve! state change and marks approved' do
      loan = Loan.create!(valid_attributes)
      expect(loan.status).to eq("pending")
      
      loan.approve!
      expect(loan.status).to eq("approved")
    end

    it 'handles decline! state change and marks declined' do
      loan = Loan.create!(valid_attributes)
      loan.decline!
      expect(loan.status).to eq("declined")
      expect(loan.item.reload.available?).to be true
    end

    it 'handles return_item! and returns the item' do
      loan = Loan.create!(valid_attributes.merge(status: :active))
      loan.return_item!
      expect(loan.status).to eq("returned")
      expect(loan.item.reload.available?).to be true
    end
  end
end
