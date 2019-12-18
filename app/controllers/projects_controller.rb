# encoding: utf-8
class ProjectsController < ApplicationController
  before_action :authenticate_user!

  # GET /projects
  def index
  end
end