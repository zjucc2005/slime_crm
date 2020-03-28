# encoding: utf-8
class IndustriesController < ApplicationController
  load_and_authorize_resource
  before_action :authenticate_user!

  # GET /industries
  def index
    query = Industry.all
    query = query.where('name LIKE ?', "%#{params[:name].strip}%") if params[:name].present?
    @industries = query.order(:created_at => :asc).paginate(:page => params[:page], :per_page => 50)
  end

  # GET /industries/new
  def new
    @industry = Industry.new
  end

  # POST /industries
  def create
    @industry = Industry.new(industry_params)

    if @industry.save
      flash[:success] = t(:operation_succeeded)
      if params[:commit] == t('action.submit_and_continue')
        redirect_to new_industry_path
      else
        redirect_to industries_path
      end
    else
      render :new
    end
  end

  # GET /industries/:id/edit
  def edit
    load_industry
  end

  # PUT /industries/:id
  def update
    load_industry

    if @industry.update(industry_params)
      flash[:success] = t(:operation_succeeded)
      redirect_to industries_path
    else
      render :edit
    end
  end

  # DETELE /industries/:id
  def destroy
    load_industry

    if @industry.destroy
      flash[:success] = t(:operation_succeeded)
    else
      flash[:error] = t(:operation_failed)
    end
    redirect_to industries_path
  end

  private
  def industry_params
    params.require(:industry).permit(:name)
  end

  def load_industry
    @industry = Industry.find(params[:id])
  end
end