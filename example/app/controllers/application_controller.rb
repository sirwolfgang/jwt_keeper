class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  skip_before_action :verify_authenticity_token

  before_action :default_format_json
  before_action :require_authentication

  private

  def default_format_json
    request.format ||= 'json'
  end

  def not_authenticated
    respond_to do |format|
      format.json { head :unauthorized }
    end
  end

  def authenticated(decoded_token)
    @current_user_id = decoded_token.claims[:uid] # Hold off on database calls until necessary
  end

  def current_user
    @current_user ||= { id: @current_user_id }
  end
end
