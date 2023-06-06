# frozen_string_literal: true

# This concern allows to sign in users when a valid invitation token is passed through url params.
# The user will be identified through the token. If the token is linked to a RdvsUser, it will also be
# linked to a rdv.
module TokenInvitable
  extend ActiveSupport::Concern

  included do
    prepend_before_action :store_token_in_session_and_redirect, if: -> { params[:invitation_token].present? }
    prepend_before_action :sign_in_with_session_token, if: -> { session[:invitation_token].present? }
  end

  private

  def store_token_in_session_and_redirect
    return redirect_with_error(t("devise.invitations.invitation_token_invalid")) unless token_valid?
    return redirect_with_error(t("devise.invitations.current_user_mismatch")) if current_user_mismatch?

    store_token_in_session

    redirect_to current_path_without_invitation_token
  end

  def store_token_in_session
    session[:invitation_token] = params[:invitation_token]
  end

  def token_valid?
    invited_user.present?
  end

  def current_path_without_invitation_token
    current_url_params = Rack::Utils.parse_nested_query(request.query_string).deep_symbolize_keys
    current_url_params.delete(:invitation_token)
    current_url_params.any? ? "#{request.path}?#{current_url_params.to_query}" : request.path
  end

  def sign_in_with_session_token
    return session.delete(:invitation_token) unless token_valid?
    return session.delete(:invitation_token) if current_user_mismatch?

    invited_user.only_invited!(rdv: rdv_user_by_invitation_token&.rdv)
    sign_in(invited_user, store: false)
  end

  def current_user_mismatch?
    invited_user.present? && current_user.present? && current_user != invited_user
  end

  def redirect_with_error(error_msg)
    flash[:error] = error_msg
    redirect_to root_path
  end

  def invited_user
    user_by_invitation_token || rdv_user_by_invitation_token&.user&.user_to_notify
  end

  def rdv_by_token
    rdv_user_by_invitation_token&.rdv
  end

  def invitation_token
    params[:invitation_token] || session[:invitation_token]
  end

  def user_by_invitation_token
    # find_by_invitation_token is a method added by the devise_invitable gem
    @user_by_invitation_token ||=
      invitation_token.present? ? User.find_by_invitation_token(invitation_token, true) : nil
  end

  def rdv_user_by_invitation_token
    @rdv_user_by_invitation_token ||=
      invitation_token.present? ? RdvsUser.find_by_invitation_token(invitation_token, true) : nil
  end
end
