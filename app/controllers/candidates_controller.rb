# encoding: utf-8
class CandidatesController < ApplicationController
  before_action :authenticate_user!

  # GET /candidates
  def index
    query = Candidate.all
    # query code here >>
    if params[:term].present?
      query = query.joins(:experiences).where('candidate_experiences.category': 'work').
          where('UPPER(candidates.name_cn) LIKE :term OR
                 UPPER(candidates.name_en) LIKE :term OR
                 UPPER(candidates.description) LIKE :term OR
                 UPPER(candidate_experiences.org_cn) LIKE :term OR
                 UPPER(candidate_experiences.org_en) LIKE :term', { :term => "%#{params[:term].strip.upcase}%" })
    end
    if params[:name].present?
      query = query.where('UPPER(name_cn) LIKE :name OR UPPER(name_en) LIKE :name', { :name => "%#{params[:name].strip.upcase}%" })
    end
    %w[is_available].each do |field|
      query = query.where(field.to_sym => params[field.to_sym].strip) if params[field.to_sym].present?
    end
    @candidates = query.order(:created_at => :desc).paginate(:page => params[:page], :per_page => 20)
  end

  # GET /candidates/new
  def new
    @candidate = Candidate.new
  end

  # POST /candidates
  def create
    begin
      @candidate = current_user.candidates.new(candidate_params)

      if @candidate.valid?
        ActiveRecord::Base.transaction do
          @candidate.save!

          params[:work_exp].each do |key, val|
            @candidate.experiences.work.create!(val.permit(experience_fields))
          end
        end

        flash[:success] = t(:operation_succeeded)
        redirect_to edit_candidate_path(@candidate)
      else
        render :new
      end
    rescue Exception => e
      flash.now[:error] = e.message
      render :new
    end
  end

  # GET /candidates/:id/edit
  def edit
    load_candidate
  end

  # PUT /candidates/:id
  def update
    begin
      load_candidate

      ActiveRecord::Base.transaction do
        @candidate.update!(candidate_params)                                   # update candidate

        _work_exp = params[:_work_exp] || {}  # old work_exp
        work_exp  = params[:work_exp]  || {}  # new work_exp
        @candidate.experiences.work.where.not(id: _work_exp.keys).destroy_all  # update existed experiences
        @candidate.experiences.work.where(id: _work_exp.keys).each do |exp|
          exp.update!(_work_exp[exp.id.to_s].permit(experience_fields))
        end
        work_exp.each do |key, val|
          @candidate.experiences.work.create!(val.permit(experience_fields))   # create new experiences
        end
      end
      flash[:success] = t(:operation_succeeded)
      redirect_to edit_candidate_path(@candidate)
    rescue Exception => e
      flash.now[:error] = e.message
      render :edit
    end
  end

  # GET /candidates/add_experience
  def add_experience
    respond_to do |f|
      f.js
    end
  end

  # GET /candidates/gen_card
  def gen_card
    @candidates = Candidate.where(id: params[:uids])
  end

  private
  def load_candidate
    @candidate = Candidate.find(params[:id])
  end

  def candidate_params
    params.require(:candidate).permit(:name_cn, :name_en, :city, :email, :email1, :phone, :phone1, :industry, :title,
                                      :date_of_birth, :gender, :description, :is_available, :cpt,
                                      :bank, :bank_card, :bank_user, :alipay_account, :alipay_user)
  end

  def experience_fields
    [:started_at, :ended_at, :org_cn, :org_en, :department, :title, :description]
  end
end