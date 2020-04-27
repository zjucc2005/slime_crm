# encoding: utf-8
class ProjectRequirementsController < ApplicationController
  load_and_authorize_resource
  before_action :authenticate_user!

  # GET /project_requirements/:id/edit
  def edit
    load_project_requirement
  end

  # PUT /project_requirements/:id
  def update
    begin
      load_project_requirement

      raise t(:not_authorized) unless @project_requirement.can_edit?

      if @project_requirement.update(project_requirement_params)
        flash[:success] = t(:operation_succeeded)
        redirect_to project_path(@project_requirement.project)
      else
        render :edit
      end
    rescue Exception => e
      flash[:error] = e.message
      redirect_to root_path
    end
  end

  # PUT /project_requirements/:id/finish
  def finish
    begin
      load_project_requirement
      raise t(:not_authorized) unless @project_requirement.can_edit?
      @project_requirement.update!(status: 'finished')
      flash[:success] = t(:operation_succeeded)
    rescue Exception => e
      flash[:error] = e.message
    end
    redirect_to project_path(@project_requirement.project)
  end

  # PUT /project_requirements/:id/unfinish
  def unfinish
    begin
      load_project_requirement
      raise t(:not_authorized) unless @project_requirement.can_edit?
      @project_requirement.update!(status: 'unfinished')
      flash[:success] = t(:operation_succeeded)
    rescue Exception => e
      flash[:error] = e.message
    end
    redirect_to project_path(@project_requirement.project)
  end

  private
  def project_requirement_params
    params.require(:project_requirement).permit(:content, :demand_number, :file)
  end

  def load_project_requirement
    @project_requirement = ProjectRequirement.find(params[:id])
  end

end