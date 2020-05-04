# encoding: utf-8
class CandidatesController < ApplicationController
  load_and_authorize_resource
  before_action :authenticate_user!

  # GET /candidates
  def index
    set_per_page
    @hl_words = [] # 高亮关键词
    query = Candidate.expert
    # query code here >>
    query = query.joins('LEFT JOIN candidate_experiences on candidates.id = candidate_experiences.candidate_id')
    query = query.where('UPPER(candidates.name) LIKE :name OR UPPER(candidates.nickname) LIKE :name', { :name => "%#{params[:name].strip.upcase}%" }) if params[:name].present?
    query = query.where('candidates.phone = :phone OR candidates.phone1 = :phone', { :phone => params[:phone].strip }) if params[:phone].present?
    query = query.where('candidates.email = :email OR candidates.email1 = :email', { :email => params[:email].strip }) if params[:email].present?
    query = query.where('candidates.industry' => params[:industry].strip) if params[:industry].present?
    query = query.where('candidates.is_available' => params[:is_available] == 'nil' ? nil : params[:is_available] ) if params[:is_available].present?

    # 专家说明
    if params[:description].present?
      @terms = params[:description].split
      @hl_words += @terms
      if @terms.length > 5
        flash[:error] = t(:keywords_at_most, :limit => 5)
        redirect_to candidates_path and return
      end
      and_conditions = []

      or_fields = %w[candidates.description candidate_experiences.org_cn candidate_experiences.org_en candidate_experiences.title]
      @terms.each do |term|
        and_conditions << "(#{or_fields.map{|field| "#{field} LIKE '%#{term}%'" }.join(' OR ') })"
      end
      query = query.where(and_conditions.join(' AND '))

      # 只搜索当前公司
      if params[:current_company] == 'true'
        query = query.where('candidate_experiences.ended_at' => nil)
      elsif params[:current_company] == 'false'
        query = query.where.not('candidate_experiences.ended_at' => nil)
      end
    end
    @candidates = query.distinct.order(:created_at => :desc).paginate(:page => params[:page], :per_page => @per_page)
  end

  # GET /candidates/:id
  def show
    begin
      load_candidate
    rescue Exception => e
      flash[:error] = e.message
      redirect_to candidates_path
    end
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
    begin
      load_candidate
    rescue Exception => e
      flash[:error] = e.message
      redirect_to candidates_path
    end
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
      redirect_to candidate_path(@candidate)
    rescue Exception => e
      flash[:error] = e.message
      redirect_to candiates_path
    end
  end

  # PUT /candidates/:id/update_is_available.js, remote: true
  def update_is_available
    load_candidate
    @candidate.update(is_available: params[:is_available])
    respond_to{ |f| f.js }
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

  # GET /candidates/:id/show_phone.js, remote: true
  def show_phone
    begin
      load_candidate
      @response = { :status => 'succ' }
    rescue Exception => e
      @response = { :status => 'fail', :reason => e.message }
    end
    respond_to{|f| f.js }
  end

  # GET /candidates/card_template
  def card_template
    @candidates = Candidate.where(id: params[:uids])
    @card_template_options = CardTemplate.where(category: 'Candidate').order(:created_at => :desc).pluck(:name, :id)
  end

  # GET /candidates/gen_card
  def gen_card
    @card_template = CardTemplate.find(params[:card_template_id])
    @candidates = Candidate.where(id: params[:uids])
  end

  # GET /candidates/expert_template
  def expert_template
    @candidates = Candidate.where(id: params[:uids]).order(:created_at => :desc)
    export_expert_template(@candidates)
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
        redirect_with_return_to company_path(@company)
      else
        render 'companies/new_client'
      end
    rescue Exception => e
      flash[:error] = e.message
      redirect_to root_path
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
        redirect_with_return_to company_path(@company)
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

  # GET /candidates/:id/payment_infos
  def payment_infos
    begin
      load_candidate
      @payment_infos = @candidate.payment_infos
    rescue Exception => e
      flash[:error] = e.message
      redirect_to candidates_path
    end
  end

  # GET /candidates/:id/new_payment_info
  def new_payment_info
    begin
      load_candidate
      @payment_info = @candidate.payment_infos.new
    rescue Exception => e
      flash[:error] = e.message
      redirect_to candidates_path
    end
  end

  # POST /candidates/:id/create_payment_info
  def create_payment_info
    begin
      load_candidate

      @payment_info = @candidate.payment_infos.new(candidate_payment_info_params.merge({created_by: current_user.id}))
      if @payment_info.save
        flash[:success] = t(:operation_succeeded)
        redirect_with_return_to candidate_path(@candidate)
      else
        render :new_payment_info
      end
    rescue Exception => e
      flash[:error] = e.message
      redirect_to root_path
    end
  end

  # GET /candidates/:id/project_tasks
  def project_tasks
    begin
      load_candidate
      query = @candidate.project_tasks.where(status: %w[ongoing finished])
      @project_tasks = query.order(:started_at => :desc).paginate(:page => params[:page], :per_page => 20)
    rescue Exception => e
      flash[:error] = e.message
      redirect_to candidates_path
    end
  end

  # GET /candidates/:id/comments
  def comments
    begin
      load_candidate
      @candidate_comments = @candidate.comments.order(:created_at => :desc).paginate(:page => params[:page], :per_page => 20)
    rescue Exception => e
      flash[:error] = e.message
      redirect_to candidates_path
    end
  end

  # GET /candidates/:id/new_comment
  def new_comment
    @candidate_comment = CandidateComment.new
  end

  # GET /candidates/:id/expert_info_for_clipboard
  def expert_info_for_clipboard
    @candidate = Candidate.find(params[:id])
    render :json => { :data => "#{@candidate.name}|#{@candidate.phone}" }
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
    params.require(:candidate).permit(:first_name, :last_name, :nickname, :city, :email, :email1, :phone, :phone1,
                                      :industry, :title, :company_id, :date_of_birth, :gender, :description,
                                      :is_available, :cpt, :currency, :wechat)
  end

  def experience_fields
    [:started_at, :ended_at, :org_cn, :org_en, :title, :description]
  end

  def candidate_payment_info_params
    params.require(:candidate_payment_info).permit(:category, :bank, :sub_branch, :account, :username)
  end

  def export_expert_template(query)
    template_path = 'public/templates/expert_template.xlsx'
    raise 'template file not found' unless File.exist?(template_path)

    book = ::RubyXL::Parser.parse(template_path)  # read from template file
    sheet = book[0]
    query.each_with_index do |expert, index|
      row = index + 1
      exp = expert.latest_work_experience
      sheet.add_cell(row, 0, "##{expert.uid}")    # Expert Code
      sheet.add_cell(row, 1, exp.try(:org_cn))    # Company
      sheet.add_cell(row, 2, exp.try(:title))     # Position
      sheet.add_cell(row, 3, expert.city)         # Region
      sheet.add_cell(row, 4, expert.description)  # Key Insights
    end
    file_dir = "public/export/#{Time.now.strftime('%y%m%d')}"
    FileUtils.mkdir_p file_dir unless File.exist? file_dir
    file_path = "#{file_dir}/expert_#{current_user.id}_#{Time.now.strftime('%H%M%S')}.xlsx"
    book.write file_path
    send_file file_path
  end
end