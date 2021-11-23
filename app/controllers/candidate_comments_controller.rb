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
    if @candidate_comment.valid?
      ActiveRecord::Base.transaction do
        @candidate_comment.save
        @candidate_comment.topped
      end
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
        @candidate_comment.topped
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

  # GET /candidate_comments/new_feedback?candidate_id=1
  def new_feedback
    @candidate = Candidate.find(params[:candidate_id])
    @candidate_comment = @candidate.comments.new
  end

  def edit_feedback
    begin
      load_candidate_comment
      @candidate = @candidate_comment.candidate
    rescue Exception => e
      flash[:error] = e.message
      redirect_to root_path
    end
  end

  def new_contact
    @candidate = Candidate.find(params[:candidate_id])
    @candidate_comment = @candidate.comments.new
  end

  def edit_contact
    begin
      load_candidate_comment
      @candidate = @candidate_comment.candidate
    rescue Exception => e
      flash[:error] = e.message
      redirect_to root_path
    end
  end

  def activate_feedback
    load_candidate_comment
    @candidate = @candidate_comment.candidate
    @candidate_comment.activate!
    respond_to{ |f| f.js }
    # redirect_with_return_to comments_feedback_candidate_path(@candidate_comment.candidate)
  end

  private
  def candidate_comment_params
    params.require(:candidate_comment).permit(:category, :content, :is_top)
  end

  def load_candidate_comment
    @candidate_comment = CandidateComment.find(params[:id])
  end

end