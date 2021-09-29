# encoding: utf-8
require 'rubyXL/convenience_methods/cell'
require 'rubyXL/convenience_methods/color'
require 'rubyXL/convenience_methods/font'
require 'rubyXL/convenience_methods/workbook'
require 'rubyXL/convenience_methods/worksheet'

class ProjectsController < ApplicationController
  load_and_authorize_resource
  before_action :authenticate_user!

  # GET /projects
  def index
    # query = current_user.is_role?('admin') ? Project.all : current_user.projects
    query = params[:my_project] == 'true' ? current_user.projects : Project.all
    query = user_channel_filter(query)
    query = query.where('created_at >= ?', params[:created_at_ge]) if params[:created_at_ge].present?
    query = query.where('created_at <= ?', params[:created_at_le]) if params[:created_at_le].present?
    %w[name code].each do |field|
      query = query.where("#{field} ILIKE ?", "%#{params[field].strip}%") if params[field].present?
    end
    %w[id status user_channel_id].each do |field|
      query = query.where(field.to_sym => params[field]) if params[field].present?
    end
    if params[:company].present?
      query = query.joins(:company).where('companies.name ILIKE :company OR companies.name_abbr ILIKE :company', { company: "%#{params[:company].strip}%" })
    end

    @projects = query.order(:created_at => :desc).paginate(:page => params[:page], :per_page => 20)
  end

  # GET /projects/new
  def new
    @project = Project.new
    load_signed_company_options
  end

  # POST /projects
  def create
    begin
      @project = Project.new(project_params.merge(created_by: current_user.id, user_channel_id: current_user.user_channel_id))

      if @project.valid?
        ActiveRecord::Base.transaction do
          @project.save!
          if current_user.is_role?('pm')
            @project.project_users.find_or_create_by!(category: 'pm', user_id: current_user.id)
          end
        end
        flash[:success] = t(:operation_succeeded)
        redirect_to project_path(@project)
      else
        load_signed_company_options
        render :new
      end
    rescue Exception => e
      flash[:error] = e.message
      redirect_to projects_path
    end
  end

  # GET /projects/:id
  def show
    load_project
  end

  # GET /projects/:id/edit
  def edit
    load_project
    load_signed_company_options
  end

  # PUT /projects/:id
  def update
    begin
      load_project

      if @project.update(project_params_update)
        flash[:success] = t(:operation_succeeded)
        redirect_to project_path(@project)
      else
        load_signed_company_options
        render :edit
      end
    rescue Exception => e
      flash[:error] = e.message
      redirect_to projects_path
    end
  end

  # DELETE /projects/:id
  def destroy
    begin
      load_project

      if @project.can_destroy?
        @project.destroy!
        flash[:success] = t(:operation_succeeded)
        redirect_to projects_path
      else
        raise t(:cannot_delete)
      end
    rescue Exception => e
      flash[:error] = e.message
      redirect_to projects_path
    end
  end

  # GET/PUT /projects/add_users
  def add_users
    # if request.put?
    #   begin
    #     @project = Project.find(params[:project_id])
    #     raise t(:not_authorized) unless @project.can_edit?
    #
    #     ActiveRecord::Base.transaction do
    #       # add pm
    #       pm_users = User.where(id: params[:uids], role: 'pm')
    #       pa_users = User.where(id: params[:uids], role: 'pa')
    #       pm_users.each do |user|
    #         @project.project_users.find_or_create_by!(category: user.role, user_id: user.id)
    #       end
    #       # add pa
    #       pa_users.each do |user|
    #         @project.project_users.find_or_create_by!(category: user.role, user_id: user.id)
    #       end
    #     end
    #     flash[:success] = t(:operation_succeeded)
    #     redirect_to project_path(@project)
    #   rescue Exception => e
    #     flash[:error] = e.message
    #     redirect_to projects_path
    #   end
    # end

    begin
      @project = Project.find(params[:project_id])
      raise t(:not_authorized) unless @project.can_edit?

      ActiveRecord::Base.transaction do
        # add pm
        pm_users = User.where(id: params[:uids], role: 'pm')
        pa_users = User.where(id: params[:uids], role: 'pa')
        pm_users.each do |user|
          @project.project_users.find_or_create_by!(category: user.role, user_id: user.id)
        end
        # add pa
        pa_users.each do |user|
          @project.project_users.find_or_create_by!(category: user.role, user_id: user.id)
        end
      end
      flash[:success] = t(:operation_succeeded)
      redirect_to project_path(@project)
    rescue Exception => e
      flash[:error] = e.message
      redirect_to projects_path
    end
  end

  # GET/PUT /projects/add_experts.js
  def add_experts
    # if request.put?
    #   begin
    #     @project = Project.find(params[:project_id])
    #     raise t(:not_authorized) unless @project.can_edit?
    #
    #     ActiveRecord::Base.transaction do
    #       (params[:uids] || []).each do |candidate_id|
    #         @project.project_candidates.expert.find_or_create_by!(candidate_id: candidate_id)
    #       end
    #     end
    #     flash[:success] = t(:operation_succeeded)
    #     if params[:commit] == t('action.submit_and_continue_to_add')
    #       redirect_to candidates_path(from_source: 'project', project_id: @project.id)
    #     else
    #       redirect_to project_path(@project)
    #     end
    #   rescue Exception => e
    #     flash[:error] = e.message
    #     redirect_to projects_path
    #   end
    # end

    begin
      @project = Project.find(params[:project_id])
      raise t(:not_authorized) unless @project.can_edit?

      ActiveRecord::Base.transaction do
        (params[:uids] || []).each do |candidate_id|
          @project.project_candidates.expert.find_or_create_by!(candidate_id: candidate_id)
        end
      end
      @notice = t(:operation_succeeded)

      if params[:mode] == '0'
        flash[:success] = t(:operation_succeeded)
        redirect_to project_path(@project)
      end
    rescue Exception => e
      @notice = e.message
    end

    respond_to do |f|
      f.js
      f.html
    end
  end

  # GET/PUT /projects/:id/add_clients
  def add_clients
    begin
      load_project
      query = @project.company.candidates
      %w[name nickname title phone email].each do |field|
        query = query.where("#{field} ILIKE ?", "%#{params[field].strip}%") if params[field].present?
      end
      @clients = query.order(:created_at => :desc)

      if request.put?
        raise t(:not_authorized) unless @project.can_edit?

        ActiveRecord::Base.transaction do
          @project.project_candidates.client.destroy_all
          (params[:uids] || []).each do |candidate_id|
            @project.project_candidates.client.create!(candidate_id: candidate_id)
          end
        end
        flash[:success] = t(:operation_succeeded)
        redirect_to project_path(@project)
      end
    rescue Exception => e
      flash[:error] = e.message
      redirect_to projects_path
    end
  end

  # GET/PUT /projects/:id/add_project_task
  def add_project_task
    begin
      load_project
      @project_task = @project.project_tasks.new

      if request.put?
        raise t(:not_authorized) unless @project.can_add_task?
        @project_task = ProjectTask.new(project_task_params.merge(project_id: @project.id,
                                                                  created_by: current_user.id, pm_id: current_user.id,
                                                                  user_channel_id: current_user.user_channel_id))
        if @project_task.save
          flash[:success] = t(:operation_succeeded)
          redirect_with_return_to(project_path(@project))
        else
          render :add_project_task
        end
      end
    rescue Exception => e
      flash[:error] = e.message
      redirect_to projects_path
    end
  end

  # GET/PUT /projects/:id/add_project_requirement
  def add_project_requirement
    begin
      load_project
      @project_requirement = @project.project_requirements.new

      if request.put?
        raise t(:not_authorized) unless @project.can_add_requirement?

        # @project_requirement = @project.project_requirements.new(project_requirement_params.to_h.merge(created_by: current_user.id))
        @project_requirement = ProjectRequirement.new(project_requirement_params.merge(project_id: @project.id, created_by: current_user.id))
        if @project_requirement.save
          flash[:success] = t(:operation_succeeded)
          redirect_to project_path(@project)
        else
          render :add_project_requirement
        end
      end
    rescue Exception => e
      flash[:error] = e.message
      redirect_to projects_path
    end
  end

  # DELETE /projects/:id/delete_user?user_id=1
  def delete_user
    begin
      load_project
      raise t(:not_authorized) unless @project.can_edit?
      @project.project_users.find_by(user_id: params[:user_id]).destroy
      flash[:success] = t(:operation_succeeded)
      redirect_to project_path(@project)
    rescue Exception => e
      flash[:error] = e.message
      redirect_to projects_path
    end
  end

  # DELETE /projects/:id/delete_expert?expert_id=1
  def delete_expert
    begin
      load_project
      raise t(:not_authorized) unless @project.can_edit?
      @project.project_candidates.find_by(candidate_id: params[:expert_id]).destroy
      flash[:success] = t(:operation_succeeded)
      redirect_to project_path(@project)
    rescue Exception => e
      flash[:error] = e.message
      redirect_to projects_path
    end
  end

  # DELETE /projects/:id/delete_client?client_id=1
  def delete_client
    begin
      load_project
      raise t(:not_authorized) unless @project.can_edit?
      @project.project_candidates.find_by(candidate_id: params[:client_id]).destroy
      flash[:success] = t(:operation_succeeded)
      redirect_to project_path(@project)
    rescue Exception => e
      flash[:error] = e.message
      redirect_to projects_path
    end
  end

  # PUT /project/:id/start
  def start
    begin
      load_project
      raise t(:not_authorized) unless @project.can_start?
      @project.start!
      flash[:success] = t(:operation_succeeded)
      redirect_to project_path(@project)
    rescue Exception => e
      flash[:error] = e.message
      redirect_to projects_path
    end
  end

  # PUT /projects/:id/close
  def close
    begin
      load_project
      raise t(:not_authorized) unless @project.can_close?
      @project.close!
      flash[:success] = t(:operation_succeeded)
      redirect_to project_path(@project)
    rescue Exception => e
      flash[:error] = e.message
      redirect_to projects_path
    end
  end

  # PUT /projects/:id/reopen
  def reopen
    begin
      load_project
      raise t(:not_authorized) unless @project.can_reopen?
      @project.reopen!
      flash[:success] = t(:operation_succeeded)
      redirect_to project_path(@project)
    rescue Exception => e
      flash[:error] = e.message
      redirect_to projects_path
    end
  end

  # GET /projects/:id/experts
  def experts
    load_project
    query = @project.experts
    @experts = query.paginate(:page => params[:page], :per_page => 100)
  end

  # GET /projects/:id/project_tasks
  def project_tasks
    load_project
    query = @project.project_tasks
    @project_tasks = query.order(:created_at => :desc).paginate(:page => params[:page], :per_page => 20)
  end

  # POST /projects/:id/export_billing_excel?template=1&close_or_not=false
  def export_billing_excel
    load_project
    begin
      case params[:template]
        when 'atkins_insights_usage_report' then export_atkins_insights_usage_report(@project)
        else raise('params error')
      end
    rescue Exception => e
      flash[:error] = e.message
      redirect_to project_path(@project)
    end
  end

  private
  def load_project
    @project = Project.find(params[:id])
    @can_operate = @project.can_be_operated_by(current_user)
  end

  def project_params
    params.require(:project).permit(:company_id, :name, :code, :industry)
  end

  def project_params_update
    params.require(:project).permit(:name, :code, :industry, :requirement, :started_at, :ended_at)
  end

  def project_task_params
    params.require(:project_task).permit(:category, :expert_id, :client_id, :pa_id, :interview_form, :started_at, :expert_level, :expert_rate, :is_shorthand)
  end

  def project_requirement_params
    params.require(:project_requirement).permit(:content, :demand_number, :file)
  end

  # 加载客户公司
  def load_signed_company_options
    @signed_company_options = user_channel_filter(Company.signed).pluck(:name, :id)
  end

  def export_atkins_insights_usage_report(project)
    template_path = 'public/templates/atkins_insights_usage_report_template.xlsx'
    raise 'template file not found' unless File.exist?(template_path)
    query = project.project_tasks.where(status: 'finished').order(:started_at => :asc)
    raise 'project task not found' if query.count == 0

    book = ::RubyXL::Parser.parse(template_path)  # read from template file
    sheet = book[0]

    # 主体
    row = 1
    query.each do |task|
      sheet.add_cell(row, 0, task.project.company.name)                                       # A, Client
      sheet.add_cell(row, 1, task.project.name)                                               # B, Project
      sheet.add_cell(row, 2, task.project.code)                                               # C, Project Code
      sheet.add_cell(row, 3, task.client.if_nickname)                                         # D, Seat
      sheet.add_cell(row, 4, task.started_at.strftime('%F %H:%M'))                            # E, Date
      sheet.add_cell(row, 5, {'face-to-face' => 'F2F contact'}[task.interview_form] || task.interview_form.capitalize)  # F, Type of Activity
      sheet.add_cell(row, 6, task.expert.mr_name)                                             # G, Expert
      exp = task.expert.latest_work_experience
      if exp
        sheet.add_cell(row, 7, exp.org_cn)                                                    # H, Expert Company
        sheet.add_cell(row, 8, exp.title)                                                     # I, Expert Title
      end
      sheet.add_cell(row, 9, task.expert_level.capitalize)                                    # J, Expert Level
      sheet.add_cell(row, 10, task.expert_rate)                                               # K, Rate
      sheet.add_cell(row, 11, task.duration)                                                  # L, Duration/mins
      sheet.add_cell(row, 12, (task.charge_duration / 60.0).round(2))                         # M, Charge Hour
      sheet.add_cell(row, 13, task.base_price)                                                # N, Fee
      sheet.add_cell(row, 14, {'RMB' => 'CNY'}[task.currency] || task.currency)               # O, Currency
      sheet.add_cell(row, 15, '')                                                             # P, Comment
      sheet.add_cell(row, 16, task.shorthand_price > 0 ? task.shorthand_price.to_i : '')      # Q, Shorthand

      # 格式设定
      (0..16).each {|i|
        sheet[row][i].change_border(:bottom, :thin)
        sheet[row][i].change_border(:right, :thin)
      }
      row += 1
    end

    # 汇总 - 左边
    sheet.add_cell(row+2, 12, '')
    sheet.add_cell(row+3, 12, 'Shorthand')
    sheet.add_cell(row+4, 12, ' +Tax(VAT)')
    sheet.add_cell(row+5, 12, 'Total')
    # 汇总 - 右边
    sheet.add_cell(row+2, 13, '', "SUM(N2:N#{row})")
    sheet.add_cell(row+3, 13, '', "SUM(Q2:Q#{row})")
    sheet.add_cell(row+4, 13, '', "(N#{row+3}+N#{row+4})*0.06")
    sheet.add_cell(row+5, 13, '', "SUM(N#{row+3}:N#{row+5})")
    # 汇总 - 格式设定
    (12..13).each {|i|
      sheet[row+2][i].change_border(:top, :thin)
      sheet[row+5][i].change_border(:top, :thin)
      sheet[row+5][i].change_border(:bottom, :thin)
    }
    (2..5).each {|i|
      sheet[row+i][12].change_border(:left, :thin)
      sheet[row+i][13].change_border(:right, :thin)
    }

    file_dir = "public/export/#{Time.now.strftime('%y%m%d')}"
    FileUtils.mkdir_p file_dir unless File.exist? file_dir
    file_path = "#{file_dir}/atkins_insights_usage_report_#{project.code}_#{Time.now.strftime('%Y%m%d')}.xlsx"
    book.write file_path
    send_file file_path
  end
end