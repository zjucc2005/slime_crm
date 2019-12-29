# encoding: utf-8
class ProjectsController < ApplicationController
  load_and_authorize_resource
  before_action :authenticate_user!

  # GET /projects
  def index
    query = Project.all
    @projects = query.order(:created_at => :desc).paginate(:page => params[:page], :per_page => 20)
  end

  # GET /projects/new
  def new
    @project = Project.new
    load_signed_company_options
  end

  # POST /projects
  def create
    begin
      @project = current_user.projects.new(project_params)

      if @project.save
        flash[:success] = t(:operation_succeeded)
        redirect_to project_path(@project)
      else
        load_signed_company_options
        render :new
      end
    rescue Exception => e
      flash[:error] = e.message
      redirect_to projects_path
    end
  end

  # GET /projects/:id
  def show
    load_project
  end

  # GET /projects/:id/edit
  def edit
    load_project
    load_signed_company_options
  end

  # PUT /projects/:id
  def update
    begin
      load_project

      if @project.update(project_params)
        flash[:success] = t(:operation_succeeded)
        redirect_to project_path(@project)
      else
        load_signed_company_options
        render :edit
      end
    rescue Exception => e
      flash[:error] = e.message
      redirect_to projects_path
    end
  end

  # DELETE /projects/:id
  def destroy
    begin
      load_project

      if @project.can_destroy?
        @project.destroy!
        flash[:success] = t(:operation_succeeded)
        redirect_to projects_path
      else
        raise t(:cannot_delete)
      end
    rescue Exception => e
      flash[:error] = e.message
      redirect_to projects_path
    end
  end

  # GET/PUT /projects/:id/add_clients
  def add_clients
    begin
      load_project
      @clients = @project.company.seats

      if request.put?
        raise t(:not_authorized) unless @project.can_edit?

        ActiveRecord::Base.transaction do
          @project.project_candidates.client.destroy_all
          (params[:uids] || []).each do |candidate_id|
            @project.project_candidates.client.create!(candidate_id: candidate_id)
          end
        end
        flash[:success] = t(:operation_succeeded)
        redirect_to project_path(@project)
      end
    rescue Exception => e
      flash[:error] = e.message
      redirect_to projects_path
    end
  end

  private
  def load_project
    @project = Project.find(params[:id])
  end

  def project_params
    params.require(:project).permit(:company_id, :name, :code, :industry, :requirement, :started_at, :ended_at)
  end

  # 加载客户公司
  def load_signed_company_options
    @signed_company_options = Company.signed.pluck(:name, :id)
  end
end