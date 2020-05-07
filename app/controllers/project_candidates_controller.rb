# encoding: utf-8
class ProjectCandidatesController < ApplicationController
  load_and_authorize_resource
  before_action :authenticate_user!

  # PUT /project_candidates/:id/update_mark.js, remote: true
  def update_mark
    load_project_candidate
    @project_candidate.update(mark: params[:mark])
    respond_to{ |f| f.js }
  end

  private
  def load_project_candidate
    @project_candidate = ProjectCandidate.find(params[:id])
  end

end