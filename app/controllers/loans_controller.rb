# app/controllers/loans_controller.rb
class LoansController < ApplicationController
  before_action :set_loan, only: %i[show approve decline activate return_item]
  before_action :authorize_item_owner!, only: %i[approve decline activate return_item]
  before_action :set_item, only: %i[create]

  def index
    @loans = current_user.loans_as_borrower.includes(item: :user).order(created_at: :desc)
  end

  def show
  end

  def my_borrows
    @loans = current_user.loans_as_borrower.includes(item: :user).order(created_at: :desc)
  end

  def my_lends
    @loans = Loan.joins(:item)
                 .where(items: { user_id: current_user.id })
                 .includes(:borrower, :item)
                 .order(created_at: :desc)
  end

  def create
    @loan = @item.loans.build(loan_params)
    @loan.borrower = current_user

    if @loan.save
      # Notify the item owner
      @loan.send(:create_notification,
        recipient: @item.user,
        actor: current_user,
        action: "loan_requested"
      )
      redirect_to @item, notice: "Borrow request sent! The owner will be notified."
    else
      redirect_to @item, alert: @loan.errors.full_messages.join(", ")
    end
  end

  def approve
    @loan.approve!
    redirect_back fallback_location: my_lends_loans_path, notice: "Request approved!"
  end

  def decline
    @loan.decline!
    redirect_back fallback_location: my_lends_loans_path, notice: "Request declined."
  end

  def activate
    @loan.activate!
    redirect_back fallback_location: my_lends_loans_path, notice: "Loan is now active."
  end

  def return_item
    @loan.return_item!
    redirect_back fallback_location: my_lends_loans_path, notice: "Item marked as returned."
  end

  private

  def set_loan
    @loan = Loan.find(params[:id])
  end

  def set_item
    @item = Item.find(params[:item_id])
  end

  def authorize_item_owner!
    unless @loan.item.user_id == current_user.id
      redirect_to root_path, alert: "Not authorized."
    end
  end

  def loan_params
    params.require(:loan).permit(:start_date, :end_date, :message)
  end
end
