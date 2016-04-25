class SessionsController < ApplicationController
  skip_before_action :require_authentication, only: :create

  # GET /session
  def show
    token = read_authentication_token

    respond_to do |format|
      format.json { render json: token }
    end
  end

  # POST /session
  def create
    @user = { id: 1 }

    respond_to do |format|
      if @user
        write_authentication_token(JWTKeeper::Token.create(uid: @user[:id]))
        format.json { head :created }
      else
        clear_authentication_token
        format.json { head :unauthorized }
      end
    end
  end

  # PATCH/PUT /session
  def update
    token = read_authentication_token

    respond_to do |format|
      if token.rotate
        write_authentication_token(token)
        format.json { head :created }
      else
        clear_authentication_token
        format.json { head :unauthorized }
      end
    end
  end

  # DELETE /session
  def destroy
    read_authentication_token.revoke

    respond_to do |format|
      clear_authentication_token
      format.json { head :no_content }
    end
  end
end
