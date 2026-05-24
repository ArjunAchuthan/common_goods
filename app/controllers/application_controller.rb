# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  include Authentication

  helper_method :current_user, :user_signed_in?

  private

  def current_user
    Current.user
  end

  def user_signed_in?
    current_user.present?
  end
end
