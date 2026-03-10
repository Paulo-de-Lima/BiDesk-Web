class SessionsController < ApplicationController
  skip_before_action :require_authentication, only: [:new, :create]

  def new
    redirect_to dashboard_path if authenticated?
  end

  def create
    admin = Admin.first
    if admin&.authenticate(params[:password])
      session[:admin_id] = admin.id
      redirect_to dashboard_path, notice: "Login realizado com sucesso!"
    else
      flash.now[:alert] = "Senha incorreta"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session[:admin_id] = nil
    redirect_to login_path, notice: "Logout realizado com sucesso!"
  end
end
