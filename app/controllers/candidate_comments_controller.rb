# encoding: utf-8
class CandidateCommentsController < ApplicationController
  load_and_authorize_resource
  before_action :authenticate_user!

  # GET /candidate_comments/new?candidate_id=1
  def new
    @candidate = Candidate.find(params[:candidate_id])
    @candidate_comment = @candidate.comments.new
  end

  # POST /candidate_comments
  def create
    @candidate = Candidate.find(params[:candidate_id])
    @candidate_comment = @candidate.comments.new(candidate_comment_params.merge(created_by: current_user.id))
    if @candidate_comment.save
      flash[:success] = t(:operation_succeeded)
      redirect_with_return_to comments_candidate_path(@candidate)
    else
      render :new
    end
  end

  # GET /candidate_comments/:id/edit
  def edit
    begin
      load_candidate_comment
      @candidate = @candidate_comment.candidate
    rescue Exception => e
      flash[:error] = e.message
      redirect_to root_path
    end
  end

  # PUT /candidate_comments/:id
  def update
    begin
      load_candidate_comment

      if @candidate_comment.update(candidate_comment_params)
        flash[:success] = t(:operation_succeeded)
        redirect_with_return_to comments_candidate_path(@candidate_comment.candidate)
      else
        render :edit
      end
    rescue Exception => e
      flash[:error] = e.message
      redirect_to root_path
    end
  end

  # DELETE /candidate_comments/:id
  def destroy
    begin
      load_candidate_comment

      @candidate_comment.destroy!
      flash[:success] = t(:operation_succeeded)
      redirect_with_return_to comments_candidate_path(@candidate_comment.candidate)
    rescue Exception => e
      flash[:error] = e.message
      redirect_to root_path
    end
  end

  private
  def candidate_comment_params
    params.require(:candidate_comment).permit(:content)
  end

  def load_candidate_comment
    @candidate_comment = CandidateComment.find(params[:id])
    raise I18n.t(:not_authorized) unless @candidate_comment.created_by == current_user.id || current_user.admin?
  end

end