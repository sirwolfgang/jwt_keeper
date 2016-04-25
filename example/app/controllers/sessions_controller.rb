class SessionsController < ApplicationController
  skip_before_action :require_authentication, only: :create

  # GET /sessions
  def create
    @user = { id: 1 }

    respond_to do |format|
      if @user
        write_authentication_token(JWTKeeper::Token.create(uid: @user[:id]))
        format.json { head :created }
      else
        format.json { head :unauthorized }
      end
    end
  end

  # PATCH/PUT /sessions
  def update
    token = read_authentication_token

    respond_to do |format|
      if token.rotate
        write_authentication_token(token)
        format.json { head :created }
      else
        format.json { head :unauthorized }
      end
    end
  end

  # DELETE /sessions
  def destroy
    token = read_authentication_token
    token.revoke
    clear_authentication_token

    respond_to do |format|
      format.json { head :no_content }
    end
  end
end
