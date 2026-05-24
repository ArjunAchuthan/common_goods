# app/controllers/neighborhoods_controller.rb
class NeighborhoodsController < ApplicationController
  before_action :set_neighborhood

  def show
    @items = @neighborhood.available_items
                          .includes(:user, images_attachments: :blob)
                          .order(created_at: :desc)
    @members = @neighborhood.users.order(:name)
  end

  def dashboard
    authorize_captain!
    @members = @neighborhood.users.order(:name)
    @recent_items = @neighborhood.items.order(created_at: :desc).limit(10)
    @active_loans = Loan.joins(:item)
                        .where(items: { user_id: @neighborhood.users.select(:id) })
                        .where(status: %i[pending approved active])
                        .includes(:borrower, item: :user)
                        .order(created_at: :desc)
  end

  private

  def set_neighborhood
    @neighborhood = Neighborhood.find(params[:id])
  end

  def authorize_captain!
    unless current_user.captain_or_admin? && current_user.neighborhood_id == @neighborhood.id
      redirect_to root_path, alert: "Only Neighborhood Captains can access the dashboard."
    end
  end
end
