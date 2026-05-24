# spec/requests/loans_controller_spec.rb
require 'rails_helper'

RSpec.describe "Loans", type: :request do
  let(:neighborhood) do
    Neighborhood.create!(
      name: "Oakridge Hills",
      radius_km: 2.0,
      slug: "oakridge-hills"
    )
  end

  let(:owner) do
    User.create!(
      name: "Lender User",
      email: "lender@example.com",
      password: "password123",
      password_confirmation: "password123",
      address: "123 Main St",
      neighborhood: neighborhood
    )
  end

  let(:borrower) do
    User.create!(
      name: "Borrower User",
      email: "borrower@example.com",
      password: "password123",
      password_confirmation: "password123",
      address: "125 Main St",
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

  # Bulletproof authentication helper using controller method stubbing
  before do
    allow_any_instance_of(ApplicationController).to receive(:find_session_by_cookie).and_wrap_original do |original, *args|
      @test_session || original.call(*args)
    end
  end

  def sign_in(user)
    @test_session = user.sessions.create!(ip_address: "127.0.0.1", user_agent: "RSpec")
  end

  describe "POST /items/:item_id/loans" do
    before { sign_in(borrower) }

    context "with valid parameters" do
      let(:valid_params) do
        {
          loan: {
            start_date: Date.current + 1,
            end_date: Date.current + 3,
            message: "I need to cut my front lawn!"
          }
        }
      end

      it "submits a borrow request to the item" do
        expect {
          post item_loans_path(item), params: valid_params
        }.to change(Loan, :count).by(1)

        expect(response).to redirect_to(item_path(item))
      end
    end
  end

  describe "PATCH approve / decline actions" do
    let!(:loan) do
      Loan.create!(
        item: item,
        borrower: borrower,
        start_date: Date.current + 1,
        end_date: Date.current + 3,
        status: :pending
      )
    end

    context "when signed in as item owner" do
      before { sign_in(owner) }

      it "approves the borrow request successfully" do
        patch approve_item_loan_path(item, loan)
        expect(response).to redirect_to(my_lends_loans_path)
        expect(loan.reload.status).to eq("approved")
      end

      it "declines the borrow request successfully" do
        patch decline_item_loan_path(item, loan)
        expect(response).to redirect_to(my_lends_loans_path)
        expect(loan.reload.status).to eq("declined")
      end

      it "activates the approved loan successfully" do
        loan.update!(status: :approved)
        patch activate_item_loan_path(item, loan)
        expect(response).to redirect_to(my_lends_loans_path)
        expect(loan.reload.status).to eq("active")
      end

      it "marks active loan as returned successfully" do
        loan.update!(status: :active)
        patch return_item_item_loan_path(item, loan)
        expect(response).to redirect_to(my_lends_loans_path)
        expect(loan.reload.status).to eq("returned")
      end
    end

    context "when signed in as someone else" do
      before { sign_in(borrower) }

      it "does not allow approving and redirects to root" do
        patch approve_item_loan_path(item, loan)
        expect(response).to redirect_to(root_path)
        expect(loan.reload.status).to eq("pending")
      end
    end
  end
end
