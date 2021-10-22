# frozen_string_literal: true

class ProjectCodeAreasController < ApplicationController
  load_and_authorize_resource
  before_action :authenticate_user!

  def index
    query = ProjectCodeArea.all
    query = query.where('name LIKE ?', "%#{params[:name].strip}%") if params[:name].present?
    @project_code_areas = query.order(:created_at => :asc).paginate(:page => params[:page], :per_page => 50)
  end

  def new
    @project_code_areas = ProjectCodeArea.new
  end

  def create
    @project_code_area = ProjectCodeArea.new(project_code_area_params)
    if @project_code_area.save
      flash[:success] = t(:operation_succeeded)
      if params[:commit] == t('action.submit_and_continue')
        redirect_to new_project_code_area_path
      else
        redirect_to project_code_areas_path
      end
    else
      render :new
    end
  end

  def edit
    load_project_code_area
  end

  def update
    load_project_code_area
    if @project_code_area.update(project_code_area_params)
      flash[:success] = t(:operation_succeeded)
      redirect_to project_code_areas_path
    else
      render :edit
    end
  end

  def destroy
    load_project_code_area
    if @project_code_area.destroy
      flash[:success] = t(:operation_succeeded)
    else
      flash[:error] = t(:operation_failed)
    end
    redirect_to project_code_areas_path
  end

  private

  def project_code_area_params
    params.require(:project_code_area).permit(:name, :company_name, :address, :email)
  end

  def load_project_code_area
    @project_code_area = ProjectCodeArea.find(params[:id])
  end

end