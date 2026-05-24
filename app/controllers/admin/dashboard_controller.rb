# app/controllers/admin/dashboard_controller.rb
module Admin
  class DashboardController < ApplicationController
    before_action :authorize_admin!

    def index
      @neighborhood = current_user.neighborhood
      @stats = {
        total_members: @neighborhood.users.count,
        total_items: @neighborhood.items.count,
        active_loans: Loan.joins(:item).where(items: { user_id: @neighborhood.users.select(:id) }, status: :active).count,
        flagged_items: @neighborhood.items.flagged.count
      }
      @recent_members = @neighborhood.users.order(created_at: :desc).limit(5)
      @recent_items = @neighborhood.items.includes(:user).order(created_at: :desc).limit(10)
    end

    private

    def authorize_admin!
      unless current_user.captain_or_admin?
        redirect_to root_path, alert: "Access restricted to Neighborhood Captains."
      end
    end
  end
end
