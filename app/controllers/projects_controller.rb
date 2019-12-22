# encoding: utf-8
class ProjectsController < ApplicationController
  load_and_authorize_resource
  before_action :authenticate_user!

  # GET /projects
  def index
  end
end