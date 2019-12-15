# encoding: utf-8
class CandidatesController < ApplicationController
  before_action :authenticate_user!

  # GET /candidates
  def index
    query = Candidate.expert
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

          (params[:work_exp] || {}).each do |key, val|
            @candidate.experiences.work.create!(val.permit(experience_fields))
          end
        end

        flash[:success] = t(:operation_succeeded)
        redirect_to edit_candidate_path(@candidate)
      else
        flash.now[:error] = t(:operation_failed)
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
    @seq = "#{Time.now.to_i}#{sprintf('%02d', rand(100))}"
    respond_to { |f| f.js }
  end

  # GET /candidates/gen_card
  def gen_card
    @candidates = Candidate.where(id: params[:uids])
  end

  # POST /candidates/create_seat
  def create_seat
    begin
      @company = Company.find(params[:candidate][:company_id])
      @candidate = @company.seats.client.new(
          candidate_params.merge({created_by: current_user.id, city: @company.city, cpt: 0})
      )
      if @candidate.save
        flash[:success] = t(:operation_succeeded)
        redirect_to company_path(@company)
      else
        flash.now[:error] = t(:operation_failed)
        render 'companies/new_seat'
      end
    rescue Exception => e
      flash[:error] = e.message
      redirect_to companies_path
    end
  end

  # GET /candidates/:id/edit_seat
  def edit_seat
    load_seat
    @company = @seat.company
  end

  # PUT /candidates/:id/update_seat
  def update_seat
    begin
      load_seat
      @company = @seat.company

      if @seat.update(candidate_params)
        flash[:success] = t(:operation_succeeded)
        redirect_to company_path(@company)
      else
        render :edit_seat
      end
    rescue Exception => e
      flash.now[:error] = e.message
      render :edit_seat
    end
  end

  private
  def load_candidate
    @candidate = Candidate.find(params[:id])
  end

  def load_seat
    @seat = Candidate.find(params[:id])
  end

  def candidate_params
    params.require(:candidate).permit(:name_cn, :name_en, :city, :email, :email1, :phone, :phone1, :industry, :company_id,
                                      :date_of_birth, :gender, :description, :is_available, :cpt,
                                      :bank, :bank_card, :bank_user, :alipay_account, :alipay_user)
  end

  def experience_fields
    [:started_at, :ended_at, :org_cn, :org_en, :department, :title, :description]
  end
end