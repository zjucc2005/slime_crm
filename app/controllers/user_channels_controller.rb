# encoding: utf-8
class UserChannelsController < ApplicationController
  load_and_authorize_resource
  before_action :authenticate_user!

  # GET /user_channels
  def index
    query = UserChannel.all
    @user_channels = query.order(:id => :asc).paginate(:page => params[:page], :per_page => 20)
  end

  # GET /user_channels/new
  def new
    @user_channel = UserChannel.new
  end

  # POST /user_channels
  def create
    @user_channel = UserChannel.new(user_channel_params)
    if @user_channel.save
      flash[:success] = t(:operation_succeeded)
      redirect_to user_channels_path
    else
      render :new
    end
  end

  # GET /user_channels/:id/edit
  def edit
    load_user_channel
  end

  # PUT /user_channels/:id
  def update
    load_user_channel

    if @user_channel.update(user_channel_params)
      flash[:success] = t(:operation_succeeded)
      redirect_to user_channels_path
    else
      render :edit
    end
  end

  # GET /user_channels/:id/new_admin
  def new_admin
    load_user_channel
    @user = @user_channel.users.new(role: 'admin', status: 'active')
  end

  # PUT /user_channels/:id/create_admin
  def create_admin
    load_user_channel

    @user = @user_channel.users.new(user_params.merge(role: 'admin', status: 'active'))
    if @user.save
      flash[:success] = t(:operation_succeeded)
      redirect_to user_channels_path
    else
      render :new_admin
    end
  end

  private
  def user_channel_params
    params.require(:user_channel).permit(:name)
  end

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :title, :date_of_employment,
                                 :name_cn, :name_en, :phone, :date_of_birth)
  end

  def load_user_channel
    @user_channel = UserChannel.find(params[:id])
  end
end