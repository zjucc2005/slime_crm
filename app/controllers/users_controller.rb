# encoding: utf-8
class UsersController < ApplicationController
  before_action :authenticate_user!


  # GET /users/:id
  def show
    load_user
  end

  # GET /users/:id/edit
  def edit
    load_user
  end

  # GET /users/my_account
  def my_account
    @user = current_user
  end

  # GET /users/edit_my_account
  def edit_my_account
    @user = current_user
  end

  # PUT /users/update_my_account
  def update_my_account

  end

  # GET /users/edit_my_password
  def edit_my_password
    @user = current_user
  end

  # PUT /users/update_my_password
  def update_my_password
    begin
      @user = current_user

      raise t(:invalid_current_password) unless @user.valid_password?(params[:current_password])
      raise t(:inconsistent_password) unless params[:password] == params[:password_confirmation]
      @user.update!(password: params[:password].strip)

      flash[:success] = t('devise.passwords.updated_not_active')
      redirect_to my_account_users_path
    rescue Exception => e
      flash[:error] = e.message
      redirect_to edit_my_password_users_path
    end
  end

  private
  def load_user
    @user = User.find(params[:id])
  end
end