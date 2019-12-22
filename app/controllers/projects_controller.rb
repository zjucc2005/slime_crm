# encoding: utf-8
class ProjectsController < ApplicationController
  load_and_authorize_resource
  before_action :authenticate_user!

  # GET /projects
  def index
  end

  # GET /projects/new
  def new
    @project = Project.new
  end

  # POST /projects
  def create
    begin
    rescue Exception => e

    end
  end

  private
  def load_project
    @project = Project.find(params[:id])
  end

  def project_params
    params.require(:project).permit!
  end


end