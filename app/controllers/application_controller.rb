class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.

  protect_from_forgery with: :null_session
  # skip_before_filter :verify_authenticity_token
  after_action :set_csrf_cookie
  respond_to :html, :json

  layout :false

  def dashboard

  end

  def is_account_demo(email)
    if DEMO_ACCOUNTS_IP_WHITELIST.include?(request.remote_ip)
      return false
    end

    return DEMO_ACCOUNTS.include?(email)
  end

  protected

  def set_app_domain
    @appDomain = request.domain
    @appDomain << ':' + request.port.to_s unless request.port.blank?
  end
  def set_csrf_cookie
    cookies['XSRF-TOKEN'] = form_authenticity_token if protect_against_forgery?
  end

end
