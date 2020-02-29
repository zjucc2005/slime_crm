# encoding: utf-8
class BanksController < ApplicationController
  load_and_authorize_resource
  before_action :authenticate_user!

  # GET /banks
  def index
    query = Bank.all
    query = query.where('name LIKE ?', "%#{params[:name].strip}%") if params[:name].present?
    @banks = query.order(:created_at => :asc).paginate(:page => params[:page], :per_page => 50)
  end

  # GET /banks/new
  def new
    @bank = Bank.new
  end

  # POST /banks
  def create
    @bank = Bank.new(bank_params)
    if @bank.save
      flash[:success] = t(:operation_succeeded)
      if params[:commit] == t('action.submit_and_continue')
        redirect_to new_bank_path
      else
        redirect_to banks_path
      end
    else
      render :new
    end
  end

  # GET /banks/:id/edit
  def edit
    load_bank
  end

  # PUT /banks/:id
  def update
    load_bank

    if @bank.update(bank_params)
      flash[:success] = t(:operation_succeeded)
      redirect_to banks_path
    else
      render :edit
    end
  end

  # DETELE /banks/:id
  def destroy
    load_bank

    if @bank.destroy
      flash[:success] = t(:operation_succeeded)
    else
      flash[:error] = t(:operation_failed)
    end
    redirect_to banks_path
  end

  private
  def bank_params
    params.require(:bank).permit(:name)
  end

  def load_bank
    @bank = Bank.find(params[:id])
  end

end