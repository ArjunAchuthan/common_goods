# app/controllers/admin/flagged_items_controller.rb
module Admin
  class FlaggedItemsController < ApplicationController
    before_action :authorize_admin!
    before_action :set_item, only: %i[unflag remove]

    def index
      @flagged_items = current_user.neighborhood.items.flagged.includes(:user).order(updated_at: :desc)
    end

    def unflag
      @item.unflag!
      redirect_to admin_flagged_items_path, notice: "\"#{@item.name}\" has been unflagged."
    end

    def remove
      @item.destroy
      redirect_to admin_flagged_items_path, notice: "Item removed permanently.", status: :see_other
    end

    private

    def set_item
      @item = current_user.neighborhood.items.find(params[:id])
    end

    def authorize_admin!
      unless current_user.captain_or_admin?
        redirect_to root_path, alert: "Access restricted to Neighborhood Captains."
      end
    end
  end
end
