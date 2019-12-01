# encoding: utf-8
class CompaniesController < ApplicationController
  before_action :authenticate_user!

  # GET /companies
  def index
    query = Company.all
    # query here >>

    # >>
    @companies = query.order(:created_at => :desc).paginate(:page => params[:page], :per_page => 20)
  end

  # GET /companies/:id
  def show
    load_company
  end

  # GET /companies/new
  def new
    @company = Company.new
  end

  # POST /companies
  def create
    begin
      @company = current_user.companies.new(company_params)

      if @company.save
        flash[:success] = t(:operation_succeeded)
        redirect_to company_path(@company)
      else
        render :new
      end
    rescue Exception => e
      flash.now[:error] = e.message
      render :new
    end
  end

  # GET /companies/:id/edit
  def edit
    load_company
  end

  # PUT /companies/:id
  def update
    begin
      load_company

      if @company.update(company_params)
        flash[:success] = t(:operation_succeeded)
        redirect_to company_path(@company)
      else
        render :edit
      end
    rescue Exception => e
      flash.now[:error] = e.message
      render :edit
    end
  end

  private
  def load_company
    @company = Company.find(params[:id])
  end

  def company_params
    params.require(:company).permit(:category, :name, :name_abbr, :industry, :city, :description,
                                    :bd_started_at, :bd_ended_at)
  end

end