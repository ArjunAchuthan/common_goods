# app/controllers/invitations_controller.rb
class InvitationsController < ApplicationController
  allow_unauthenticated_access only: %i[accept]

  def new
    @invitation = current_user.sent_invitations.build
  end

  def create
    @invitation = current_user.sent_invitations.build(invitation_params)
    @invitation.neighborhood = current_user.neighborhood

    if @invitation.save
      # In production, send an invitation email here
      redirect_to root_path, notice: "Invitation sent to #{@invitation.invitee_email}!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def accept
    @invitation = Invitation.find_by_valid_token(params[:token])

    if @invitation
      if user_signed_in?
        @invitation.accept!(current_user)
        redirect_to root_path, notice: "Welcome to #{@invitation.neighborhood.name}!"
      else
        redirect_to new_registration_path(token: params[:token])
      end
    else
      redirect_to new_session_path, alert: "This invitation is invalid or has expired."
    end
  end

  private

  def invitation_params
    params.require(:invitation).permit(:invitee_email)
  end
end
