# encoding: utf-8
class CandidatesController < ApplicationController
  load_and_authorize_resource
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

  # GET /candidates/:id
  def show
    load_candidate
  end

  # GET /candidates/new
  def new
    @candidate = Candidate.new
  end

  # POST /candidates
  def create
    begin
      @candidate = Candidate.new(candidate_params.merge(created_by: current_user.id))

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

  # DELETE /candidates/:id
  def destroy
    begin
      load_candidate

      @candidate.destroy!
      flash[:success] = t(:operation_succeeded)
      redirect_back(fallback_location: root_path)
    rescue Exception => e
      logger.info "delete candidate failed: #{e.message}"
      flash[:error] = t(:operation_failed)
      redirect_back(fallback_location: root_path)
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

  # POST /candidates/create_client
  def create_client
    begin
      @company = Company.find(params[:candidate][:company_id])
      @client = @company.candidates.client.new(
          candidate_params.merge({created_by: current_user.id, city: @company.city, cpt: 0})
      )
      if @client.save
        flash[:success] = t(:operation_succeeded)
        if params[:return_to].present?
          redirect_to params[:return_to]
        else
          redirect_to company_path(@company)
        end
      else
        flash.now[:error] = t(:operation_failed)
        render 'companies/new_client'
      end
    rescue Exception => e
      flash[:error] = e.message
      redirect_to companies_path
    end
  end

  # GET /candidates/:id/edit_client
  def edit_client
    load_client
    @company = @client.company
  end

  # PUT /candidates/:id/update_client
  def update_client
    begin
      load_client
      @company = @client.company

      if @client.update(candidate_params)
        flash[:success] = t(:operation_succeeded)
        redirect_to company_path(@company)
      else
        render :edit_client
      end
    rescue Exception => e
      flash.now[:error] = e.message
      render :edit_client
    end
  end

  # POST /candidates/import_expert
  def import_expert
    begin
      sheet = open_spreadsheet(params[:file])

      # render :json => sheet.to_json and return

      ActiveRecord::Base.transaction do
        2.upto(sheet.last_row) do |i|
          row = sheet.row(i)
          name        = row[1].to_s.strip
          next if name.blank?
          description = row[2].to_s.strip
          emails      = row[3].to_s.split
          phones      = row[4].to_s.split
          cpt         = row[5].to_s.match(/\d+/).to_s.to_i
          currency    = row[5].to_s.match(/(RMB|USD)/).to_s
          first_name, last_name = Candidate.name_split(name)
          Candidate.expert.create!(
              created_by: current_user.id,
              data_source: 'excel',
              first_name: first_name,
              last_name: last_name,
              phone: phones[0],
              phone1: phones[1],
              email: emails[0],
              email1: emails[1],
              description: description,
              cpt: cpt,
              currency: currency.present? ? currency : 'RMB',
              is_available: true
          )
        end
      end
      flash[:notice] = t(:operation_succeeded)
      redirect_to candidates_path
    rescue Exception => e
      flash[:error] = e.message
      redirect_to candidates_path
    end
  end

  private
  def load_candidate
    @candidate = Candidate.find(params[:id])
    current_user.access_candidate(@candidate)  # 访问次数统计/访问权限
  end

  def load_client
    @client = Candidate.find(params[:id])
  end

  def candidate_params
    params.require(:candidate).permit(:first_name, :last_name, :nickname, :city, :email, :email1, :phone, :phone1, :industry, :company_id,
                                      :date_of_birth, :gender, :description, :is_available, :cpt, :currency,
                                      :bank, :bank_card, :bank_user, :alipay_account, :alipay_user)
  end

  def experience_fields
    [:started_at, :ended_at, :org_cn, :org_en, :title, :description]
  end
end