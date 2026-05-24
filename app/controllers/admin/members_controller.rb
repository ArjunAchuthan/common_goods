# app/controllers/admin/members_controller.rb
module Admin
  class MembersController < ApplicationController
    before_action :authorize_admin!
    before_action :set_member, only: %i[destroy toggle_role]

    def index
      @members = current_user.neighborhood.users.order(:name)
    end

    def destroy
      @member.update!(neighborhood: nil)
      redirect_to admin_members_path, notice: "#{@member.name} has been removed from the neighborhood."
    end

    def toggle_role
      if @member.member?
        @member.captain!
      else
        @member.member!
      end
      redirect_to admin_members_path, notice: "#{@member.name}'s role updated to #{@member.role}."
    end

    private

    def set_member
      @member = current_user.neighborhood.users.find(params[:id])
    end

    def authorize_admin!
      unless current_user.captain_or_admin?
        redirect_to root_path, alert: "Access restricted to Neighborhood Captains."
      end
    end
  end
end
