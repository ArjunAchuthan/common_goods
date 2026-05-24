# app/controllers/sessions_controller.rb
class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[new create]

  def new
  end

  def create
    user = User.find_by(email: params[:email_address]&.downcase)

    if user&.authenticate(params[:password])
      start_new_session_for(user)
      redirect_to after_authentication_url, notice: "Welcome back, #{user.name}!"
    else
      redirect_to new_session_path, alert: "Invalid email or password."
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path, notice: "You have been signed out.", status: :see_other
  end
end
