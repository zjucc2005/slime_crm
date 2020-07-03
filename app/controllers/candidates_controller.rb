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
    query = query.where('candidates.id' => params[:id].strip) if params[:id].present?
    query = query.where('candidates.name ~* :name OR candidates.nickname ~* :name', { :name => params[:name].strip }) if params[:name].present?
    query = query.where('candidates.phone ~* :phone OR candidates.phone1 ~* :phone', { :phone => params[:phone].strip.shellescape }) if params[:phone].present?
    query = query.where('candidates.email ~* :email OR candidates.email1 ~* :email', { :email => params[:email].strip.shellescape }) if params[:email].present?
    query = query.where('candidates.industry' => params[:industry].strip) if params[:industry].present?
    query = query.where('candidates.is_available' => params[:is_available] == 'nil' ? nil : params[:is_available] ) if params[:is_available].present?
    %w[recommender_id data_channel].each do |field|
      query = query.where(field.to_sym => params[field].strip) if params[field].present?
    end

    # 专家说明
    if params[:description].present?
      @terms = params[:description].split
      @hl_words += @terms
      if @terms.length > 5
        flash[:error] = t(:keywords_at_most, :limit => 5)
        redirect_to candidates_path and return
      end
      and_conditions = []
      or_fields = %w[candidates.description candidate_experiences.org_cn candidate_experiences.org_en candidate_experiences.title candidate_experiences.description]
      @terms.each do |term|
        # and_conditions << "(#{or_fields.map{|field| "#{field} ~* '#{term}'" }.join(' OR ')})"
        and_conditions << "(#{or_fields.map{|f| "coalesce(#{f},'')" }.join(' || ')} ~* '#{term}')"
      end
      query = query.joins('LEFT JOIN candidate_experiences on candidates.id = candidate_experiences.candidate_id')
      query = query.where(and_conditions.join(' AND '))

      # 只搜索当前公司
      if params[:current_company] == 'true'
        query = query.where('candidate_experiences.ended_at' => nil)
      elsif params[:current_company] == 'false'
        query = query.where.not('candidate_experiences.ended_at' => nil)
      end
      query = query.distinct  # 去重
    end
    @candidates = query.order(:created_at => :desc).paginate(:page => params[:page], :per_page => @per_page)
  end

  # GET /candidates/:id
  def show
    begin
      load_candidate
      session_cache_show_history
    rescue Exception => e
      flash[:error] = e.message
      redirect_to candidates_path
    end
  end

  # GET /candidates/new
  def new
    @candidate = Candidate.new(recommender_id: params[:recommender_id])
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
          unless @candidate.validates_presence_of_experiences
            raise t(:operation_failed)
          end
        end

        flash[:success] = t(:operation_succeeded)
        redirect_to candidate_path(@candidate)
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
        _work_exp = params[:_work_exp] || {}  # old work_exp
        work_exp  = params[:work_exp]  || {}  # new work_exp
        @candidate.experiences.work.where.not(id: _work_exp.keys).destroy_all  # update existed experiences
        @candidate.experiences.work.where(id: _work_exp.keys).each do |exp|
          exp.update!(_work_exp[exp.id.to_s].permit(experience_fields))
        end
        work_exp.each do |key, val|
          @candidate.experiences.work.create!(val.permit(experience_fields))   # create new experiences
        end
        @candidate.update!(candidate_params)                                   # update candidate
        unless @candidate.validates_presence_of_experiences
          raise t(:operation_failed)
        end
      end

      flash[:success] = t(:operation_succeeded)
      redirect_to candidate_path(@candidate)
    rescue Exception => e
      flash[:error] = e.message
      render :edit
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
  # def card_template
  #   @candidates = Candidate.where(id: params[:uids])
  #   @card_template_options = CardTemplate.where(category: 'Candidate').order(:created_at => :desc).pluck(:name, :id)
  # end

  # GET /candidates/gen_card
  def gen_card
    @card_template = CardTemplate.find(params[:card_template_id])
    @candidates = Candidate.where(id: params[:uids])
  end

  # GET /candidates/expert_template
  def expert_template
    if params[:project_id].present?
      @candidates = Candidate.joins(:project_candidates).
        where(:'candidates.id' => params[:uids], :'project_candidates.project_id' => params[:project_id]).
        order(:'project_candidates.created_at' => :asc)
    else
      @candidates = Candidate.where(id: params[:uids]).order(:created_at => :desc)
    end
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
    @errors = []
    if request.post?
      begin
        sheet = open_spreadsheet(params[:file])
        @errors << 'excel表格里没有信息' if sheet.last_row < 2
        @errors << 'excel不能超过10000行' if sheet.last_row > 10000
        2.upto(sheet.last_row) do |i|
          parser = Utils::ExpertTemplateParser.new(sheet.row(i), current_user.id)
          @errors << "Row #{i}: #{parser.errors.join(', ')}" unless parser.import
        end
      rescue Exception => e
        @errors << e.message
      end

      if @errors.blank?
        flash[:notice] = t(:operation_succeeded)
        redirect_to candidates_path
      else
        render :import_expert
      end
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
      @candidate_comments = @candidate.comments.order(:is_top => :desc, :created_at => :desc).paginate(:page => params[:page], :per_page => 20)
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

  # GET /candidates/recommender_info?recommender_id=1
  def recommender_info
    begin
      @recommender = Candidate.expert.where(id: params[:recommender_id]).first
      raise "expert not found with id #{params[:id]}" if @recommender.nil?
      render :json => { status: '0', name: @recommender.name }
    rescue Exception => e
      render :json => { status: '1', reason: e.message }
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
    params.require(:candidate).permit(:first_name, :last_name, :nickname, :city, :email, :email1, :phone, :phone1,
                                      :industry, :title, :company_id, :date_of_birth, :gender, :description,
                                      :is_available, :cpt, :currency, :recommender_id, :wechat, :cpt_face_to_face,
                                      :data_channel)
  end

  def experience_fields
    [:started_at, :ended_at, :org_cn, :org_en, :title, :description]
  end

  def candidate_payment_info_params
    params.require(:candidate_payment_info).permit(:category, :bank, :sub_branch, :account, :username)
  end

  def export_expert_template(query)
    template_path = 'public/templates/expert_template_20200518.xlsx'
    raise 'template file not found' unless File.exist?(template_path)

    book = ::RubyXL::Parser.parse(template_path)  # read from template file
    sheet = book[0]
    query.each_with_index do |expert, index|
      row = index + 3
      exp = expert.latest_work_experience
      sheet.add_cell(row, 1, "##{expert.uid}")    # Expert Code
      sheet.add_cell(row, 2, exp.try(:org_cn))    # Company
      sheet.add_cell(row, 3, exp.try(:title))     # Position
      sheet.add_cell(row, 4, expert.city)         # Region
      sheet.add_cell(row, 5, expert.description)  # Key Insights
    end
    file_dir = "public/export/#{Time.now.strftime('%y%m%d')}"
    FileUtils.mkdir_p file_dir unless File.exist? file_dir
    file_path = "#{file_dir}/expert_#{current_user.id}_#{Time.now.strftime('%H%M%S')}.xlsx"
    book.write file_path
    send_file file_path
  end

  def session_cache_show_history
    begin
      fifo = Utils::Fifo.new(session[:cache_show_history], len: 10, dup: false)
      fifo.push([@candidate.id, "##{@candidate.uid} #{@candidate.name}"])
      session[:cache_show_history] = fifo.to_a
    rescue
      session[:cache_show_history] = nil
    end
  end
end