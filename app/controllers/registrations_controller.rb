# app/controllers/registrations_controller.rb
class RegistrationsController < ApplicationController
  allow_unauthenticated_access

  def new
    @user = User.new
    @invitation = Invitation.find_by_valid_token(params[:token])
  end

  def create
    @user = User.new(user_params)
    @invitation = Invitation.find_by_valid_token(params[:invitation_token])

    if @invitation
      @user.neighborhood = @invitation.neighborhood
    end

    if @user.save
      @invitation&.accept!(@user)
      start_new_session_for(@user)
      redirect_to root_path, notice: "Welcome to CommonGoods, #{@user.name}!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :address)
  end
end
