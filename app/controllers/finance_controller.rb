# encoding: utf-8
class FinanceController < ApplicationController
  load_and_authorize_resource
  before_action :authenticate_user!

  # GET /finance
  def index
    query = ProjectTask.where(status: 'finished')
    query = query.where('project_tasks.created_at >= ?', params[:created_at_ge]) if params[:created_at_ge].present?
    query = query.where('project_tasks.created_at <= ?', params[:created_at_le]) if params[:created_at_le].present?
    %w[category interview_form charge_status payment_status].each do |field|
      query = query.where("project_tasks.#{field}" => params[field].strip) if params[field].present?
    end
    if params[:project].present?
      query = query.joins(:project).where('UPPER(projects.code) = UPPER(?) OR UPPER(projects.name) LIKE UPPER(?)',
                                          params[:project].strip, "%#{params[:project].strip}%")
    end
    if params[:company].present?
      companies = Company.where('UPPER(name_abbr) = UPPER(?) OR UPPER(name) LIKE UPPER(?)',
                                params[:company].strip, "%#{params[:company].strip}%")
      query = query.joins(:project).where('projects.company_id' => companies.ids)
    end
    if params[:commit] == t('action.search_and_export')
      export_project_tasks(query)
      return
    end
    @project_tasks = query.order(:created_at => :desc).paginate(:page => params[:page], :per_page => 20)
  end

  # GET /finance/:id
  def show
    load_project_task
  end

  # GET /finance/:id/edit
  def edit
    load_project_task
  end

  # PUT /finance/:id
  def update
    begin
      load_project_task

      if @project_task.update(project_task_params)
        flash[:success] = t(:operation_succeeded)
        redirect_to finance_path(@project_task)
      else
        render :edit
      end
    rescue Exception => e
      flash.now[:error] = e.message
      render :edit
    end
  end

  private
  def load_project_task
    @project_task = ProjectTask.find(params[:id])
  end

  def project_task_params
    params.require(:project_task).permit(:actual_price, :charge_status, :payment_status)
  end

  def export_project_tasks(query)
    query_limit = 1000  # export data limit
    if query.count > query_limit
      flash[:error] = "导出数据条目过多, 当前: #{query.count}, 最大: #{query_limit}"
      redirect_to finance_index_path and return
    end

    template_path = 'public/templates/finance_template.xlsx'
    raise 'template file not found' unless File.exist?(template_path)

    book = ::RubyXL::Parser.parse(template_path)              # read from template file
    sheet = book[0]

    query.each_with_index do |task, index|
      row = index + 2
      sheet.add_cell(row, 0, task.project.company.name)               # 客户(公司)/Client
      sheet.add_cell(row, 1, task.project.name)                       # 项目名称/Project
      sheet.add_cell(row, 2, task.project.code)                       # 项目代码/Project code
      sheet.add_cell(row, 3, task.project.clients.first.try(:name))   # 负责人/Seat
      sheet.add_cell(row, 4, task.started_at.strftime('%F %H:%M%p'))  # 日期/Date
      sheet.add_cell(row, 5, task.interview_form)                     # 访谈类型
      sheet.add_cell(row, 6, "##{task.candidate.uid}")                # 专家编号/Expert UID
      sheet.add_cell(row, 7, task.candidate.name)                     # 专家姓名/Expert name
      exp = task.candidate.latest_work_experience
      sheet.add_cell(row, 8, exp.try(:org_cn))                        # 专家公司名称/Expert company
      sheet.add_cell(row, 9, exp.try(:title))                         # 专家职位/Expert title
      sheet.add_cell(row, 10, '')                                     # 专家级别/Expert level(取值待定)
    end

    file_dir = "public/export/#{Time.now.strftime('%y%m%d')}"
    FileUtils.mkdir_p file_dir unless File.exist? file_dir
    file_path = "#{file_dir}/finance_#{current_user.id}_#{Time.now.strftime('%H%M%S')}.xlsx"
    book.write file_path
    send_file file_path
  end

end