require 'rails_helper'

RSpec.describe "User End-To-End Journey", type: :request do
  let!(:neighborhood) do
    Neighborhood.create!(
      name: "Oakridge Hills",
      radius_km: 5.0,
      slug: "oakridge-hills"
    )
  end

  it "successfully completes a borrow, approve, activate, and return cycle" do
    # 1. Register User A (Lender)
    post registration_path, params: {
      user: {
        name: "Lender User",
        email: "lender@example.com",
        password: "password123",
        password_confirmation: "password123",
        address: "123 Main St"
      }
    }
    expect(response).to redirect_to(root_path)
    follow_redirect!
    expect(response.body).to include("Welcome to CommonGoods, Lender User!")
    
    lender = User.find_by(email: "lender@example.com")
    lender.update!(neighborhood: neighborhood)
    
    # Sign out Lender to sign in Borrower
    delete session_path
    expect(response).to redirect_to(new_session_path)

    # 2. Register User B (Borrower)
    post registration_path, params: {
      user: {
        name: "Borrower User",
        email: "borrower@example.com",
        password: "password123",
        password_confirmation: "password123",
        address: "125 Main St"
      }
    }
    expect(response).to redirect_to(root_path)
    borrower = User.find_by(email: "borrower@example.com")
    borrower.update!(neighborhood: neighborhood)

    # 3. Log in Lender to list an item
    delete session_path
    post session_path, params: {
      email_address: "lender@example.com",
      password: "password123"
    }
    expect(response).to redirect_to(root_path)

    post items_path, params: {
      item: {
        name: "Premium Lawn Mower",
        description: "Gas powered push mower.",
        category: "garden",
        condition: "good"
      }
    }
    item = Item.find_by(name: "Premium Lawn Mower")
    expect(response).to redirect_to(item_path(item))

    # Sign out Lender
    delete session_path

    # 4. Log in Borrower to search and request item
    post session_path, params: {
      email_address: "borrower@example.com",
      password: "password123"
    }
    expect(response).to redirect_to(root_path)

    # Request the item
    post item_loans_path(item), params: {
      loan: {
        start_date: Date.current + 1,
        end_date: Date.current + 3,
        message: "Can I cut my grass tomorrow?"
      }
    }
    expect(response).to redirect_to(item_path(item))
    loan = Loan.last
    expect(loan.status).to eq("pending")

    # Sign out Borrower
    delete session_path

    # 5. Log in Lender to approve, activate, and return
    post session_path, params: {
      email_address: "lender@example.com",
      password: "password123"
    }
    expect(response).to redirect_to(root_path)

    # Approve
    patch approve_item_loan_path(item, loan)
    expect(response).to redirect_to(my_lends_loans_path)
    expect(loan.reload.status).to eq("approved")

    # Activate
    patch activate_item_loan_path(item, loan)
    expect(response).to redirect_to(my_lends_loans_path)
    expect(loan.reload.status).to eq("active")
    expect(item.reload.available?).to be false

    # Return
    patch return_item_item_loan_path(item, loan)
    expect(response).to redirect_to(my_lends_loans_path)
    expect(loan.reload.status).to eq("returned")
    expect(item.reload.available?).to be true
  end
end
