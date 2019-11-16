# encoding: utf-8
class CandidatesController < ApplicationController

  def index
    query = Candidate.all
    # query code here >>

    @candidates = query.order(:created_at => :desc).paginate(:page => params[:page], :per_page => 20)
  end

  def new
    @candidate = Candidate.new
  end

  private
  def load_candidate
    @candidate = Candidate.find(params[:id])
  end

  def candidate_params
    params.require(:candidate).permit!
  end
end