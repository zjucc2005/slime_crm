# encoding: utf-8
class FinanceController < ApplicationController
  load_and_authorize_resource
  before_action :authenticate_user!

  # GET /finance
  def index
    query = ProjectTask.where(status: 'finished')
    query = user_channel_filter(query, 'project_tasks.user_channel_id')
    # query = query.where('project_tasks.created_at >= ?', params[:created_at_ge]) if params[:created_at_ge].present?
    # query = query.where('project_tasks.created_at <= ?', params[:created_at_le]) if params[:created_at_le].present?
    query = query.where('project_tasks.started_at >= ?', params[:started_at_ge]) if params[:started_at_ge].present?
    query = query.where('project_tasks.started_at <= ?', params[:started_at_le]) if params[:started_at_le].present?
    %w[id project_id category interview_form charge_status payment_status user_channel_id].each do |field|
      query = query.where("project_tasks.#{field}" => params[field].strip) if params[field].present?
    end
    if params[:project].present?
      query = query.joins(:project).where('projects.code ILIKE :term OR projects.name ILIKE :term',
                                          { term: "%#{params[:project].strip}%" })
    end
    if params[:company].present?
      companies = Company.where('name ILIKE :company OR name_abbr ILIKE :company', { company: "%#{params[:company].strip}%"})
      query = query.joins(:project).where('projects.company_id' => companies.ids)
    end
    if params[:expert].present?
      query = query.joins(:expert).where('candidates.name ILIKE ?', "%#{params[:expert].strip}%")
    end
    # export excel files
    case params[:commit]
      when '中文模板' then export_project_tasks(query, category='cn') and return
      when '英文模板' then export_project_tasks(query, category='en') and return
      when '专家费打款' then export_project_tasks(query, category='expert_fee') and return
      else nil
    end

    @project_tasks = query.order(:started_at => :desc).paginate(:page => params[:page], :per_page => 20)
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

      @project_task.actual_price    = params[:project_task][:actual_price]
      @project_task.shorthand_price = params[:project_task][:shorthand_price]
      @project_task.charge_status   = params[:project_task][:charge_status]
      @project_task.payment_status  = params[:project_task][:payment_status]
      if @project_task.charge_status_changed?
        @project_task.set_charge_timestamp
      end
      if @project_task.save
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

  # PUT /finance/:id/return_back
  def return_back
    load_project_task

    if @project_task.can_return_back?
      @project_task.update!(status: 'ongoing')
      flash[:success] = t(:operation_succeeded)
    else
      flash[:error] = t(:not_authorized)
    end
    redirect_to finance_index_path
  end

  # GET /finance/batch_update_charge_status
  def batch_update_charge_status
    if params[:status] == 'billed'
      ActiveRecord::Base.transaction do
        ProjectTask.where(id: params[:uids], charge_status: 'unbilled').each do |task|
          task.charge_status = 'billed'
          task.set_charge_timestamp
          task.save!
        end
      end
    elsif params[:status] == 'paid'
      ActiveRecord::Base.transaction do
        ProjectTask.where(id: params[:uids], charge_status: 'billed').each do |task|
          task.charge_status = 'paid'
          task.set_charge_timestamp
          task.save!
        end
      end
    end
    flash[:success] = t(:operation_succeeded)
    redirect_to finance_index_path
  end

  # GET /finance/batch_update_payment_status
  def batch_update_payment_status
    if params[:status] == 'paid'
      ActiveRecord::Base.transaction do
        ProjectTask.where(id: params[:uids], payment_status: 'unpaid').each do |task|
          task.update(payment_status: 'paid')
        end
      end
    end
    flash[:success] = t(:operation_succeeded)
    redirect_to finance_index_path
  end

  # GET /finance/export_finance_excel?mode=cn&uids[]=
  def export_finance_excel
    begin
      query = ProjectTask.where(id: params[:uids])
      case params[:mode]
        when 'cn' then export_project_tasks(query, 'cn')
        when 'en' then export_project_tasks(query, 'en')
        when 'expert_fee' then export_project_tasks(query, 'expert_fee')
        else raise('params error')
      end
    rescue Exception => e
      flash[:error] = e.message
      redirect_to finance_index_path
    end
  end

  private
  def load_project_task
    @project_task = ProjectTask.find(params[:id])
    @can_operate = @project_task.user_channel_id == current_user.user_channel_id
  end

  def project_task_params
    params.require(:project_task).permit(:actual_price, :shorthand_price, :charge_status, :payment_status)
  end

  def export_project_tasks(query, category='cn')
    query_limit = 1000  # export data limit
    if query.count > query_limit
      flash[:error] = "导出数据条目过多, 当前: #{query.count}, 最大: #{query_limit}"
      redirect_to finance_index_path and return
    end

    template_path = case category
                      when 'cn' then 'public/templates/finance_template.xlsx'
                      when 'en' then 'public/templates/finance_template.xlsx'
                      when 'expert_fee' then 'public/templates/finance_template_expert_fee.xlsx'
                      else ''
                    end

    raise 'template file not found' unless File.exist?(template_path)
    book = ::RubyXL::Parser.parse(template_path)                      # read from template file
    sheet = book[0]

    case category
      when 'cn' then set_sheet_cn_en(sheet, query, 'cn')
      when 'en' then set_sheet_cn_en(sheet, query, 'en')
      when 'expert_fee' then set_sheet_expert_fee(sheet, query)
      else raise("invalid category[#{category}]")
    end

    file_dir = "public/export/#{Time.now.strftime('%y%m%d')}"
    FileUtils.mkdir_p file_dir unless File.exist? file_dir
    file_path = "#{file_dir}/finance_#{category}_#{current_user.id}_#{Time.now.strftime('%H%M%S')}.xlsx"
    book.write file_path
    send_file file_path
  end

  def set_sheet_cn_en(sheet, query, category='cn')
    query.order(:started_at => :desc).each_with_index do |task, index|
      row = index + 2
      sheet.add_cell(row, 0, task.project.company.name_abbr)          # 客户(公司)/Client
      sheet.add_cell(row, 1, task.project.name)                       # 项目名称/Project
      sheet.add_cell(row, 2, task.project.code)                       # 项目代码/Project code
      sheet.add_cell(row, 3, task.project.clients.first.try(:if_nickname))  # 负责人/Seat
      sheet.add_cell(row, 4, task.started_at.strftime('%F %H:%M'))    # 日期/Date
      interview_form = case category
                         when 'cn' then ProjectTask::INTERVIEW_FORM[task.interview_form]
                         when 'en' then task.interview_form.capitalize
                         else task.interview_form
                       end
      sheet.add_cell(row, 5, interview_form)                          # 访谈类型
      sheet.add_cell(row, 6, "##{task.expert.uid}")                   # 专家编号/Expert UID
      expert_name = case category
                      when 'cn' then task.expert.name
                      when 'en' then task.expert.mr_name
                      else task.expert.name
                    end
      sheet.add_cell(row, 7, expert_name)                             # 专家姓名/Expert name
      exp = task.expert.latest_work_experience
      sheet.add_cell(row, 8, exp.try(:org_cn))                        # 专家公司名称/Expert company
      sheet.add_cell(row, 9, exp.try(:title))                         # 专家职位/Expert title
      sheet.add_cell(row, 10, task.expert_level.capitalize)           # 专家级别/Expert level
      sheet.add_cell(row, 11, task.expert_rate)                       # 倍率/Rate
      sheet.add_cell(row, 12, task.duration)                          # 访谈时长/Duration
      sheet.add_cell(row, 13, task.charge_hour)                       # 收费小时/Charge Hour
      sheet.add_cell(row, 14, task.actual_price)                      # 总费用/Fee
      sheet.add_cell(row, 15, task.currency)                          # 币种/Currency
      sheet.add_cell(row, 16, task.memo)                              # 备注/Comment
      sheet.add_cell(row, 17, task.shorthand_price)                   # 速记费/Shorthand Fee
      sheet.add_cell(row, 18, task.expert.new_expert? ? 'Y' : 'N')    # 新专家/New Expert
      sheet.add_cell(row, 19, task.pm.name_cn)                        # 项目经理/PM
      sheet.add_cell(row, 20, task.pa.name_cn)                        # 专家招募/Research(creator)
      sheet.add_cell(row, 21, task.expert.cpt)                        # 专家基础费率
      # 支出信息
      expert_cost = task.costs.where(category: 'expert').first
      if expert_cost
        sheet.add_cell(row, 22, expert_cost.price)                         # 专家费/Expert Fee
        sheet.add_cell(row, 23, expert_cost.payment_info['username'])      # 账号名/Account name(Username)
        sheet.add_cell(row, 24, expert_cost.bank_or_alipay)                # 银行或者支付宝/Bank&Alipay
        sheet.add_cell(row, 25, expert_cost.payment_info['account'])       # 账号/Account
        sheet.add_cell(row, 26, expert_cost.payment_info['sub_branch'])    # 支行备注/Fee Comment
      end
      recommend_cost = task.costs.where(category: 'recommend').first
      if recommend_cost
        sheet.add_cell(row, 27, recommend_cost.price)                       # 推荐费/Recommend Fee
        sheet.add_cell(row, 28, recommend_cost.payment_info['username'])    # 推荐人账号名
        sheet.add_cell(row, 29, recommend_cost.bank_or_alipay)              # 推荐人银行或支付宝/Bank&Alipay
        sheet.add_cell(row, 30, recommend_cost.payment_info['account'])     # 推荐人帐号/Account
        sheet.add_cell(row, 31, recommend_cost.payment_info['sub_branch'])  # 推荐人支行备注/Sub-branch remarks
      end
      translation_cost = task.costs.where(category: 'translation').first
      if translation_cost
        sheet.add_cell(row, 32, translation_cost.price)                     # 翻译费/Translation
      end
      sheet.add_cell(row, 33, '')                                           # 备注/Remark
    end
  end

  def set_sheet_expert_fee(sheet, query)
    sheet.sheet_name = Time.now.strftime('%Y.%m')
    sum_price = 0
    query = query.joins("LEFT JOIN project_task_costs ON project_task_costs.project_task_id = project_tasks.id AND project_task_costs.category = 'expert' ").
      order("project_task_costs.payment_info ->> 'category' ASC")

    sum_price = 0
    row = 1
    query.each_with_index do |task, index|
      task.costs.each do |cost|
        sheet.add_cell(row, 0, '')                                                             # A, 序号
        sheet.add_cell(row, 1, '')                                                             # B, 是否兴业银行
        sheet.add_cell(row, 2, CandidatePaymentInfo::CATEGORY[cost.payment_info['category']])  # C, 支付宝/银联
        sheet.add_cell(row, 3, cost.payment_info['account'])                                   # D, 收款账号
        sheet.add_cell(row, 4, cost.payment_info['username'])                                  # E, 收款户名
        sheet.add_cell(row, 5, '')
        if cost.payment_info['category'] == 'unionpay'
          sheet.add_cell(row, 5, [cost.payment_info['bank'], cost.payment_info['sub_branch']].join)  # F, 收款银行及营业网点
        end
        sheet.add_cell(row, 6, '')                                                             # G, 是否同城
        sheet.add_cell(row, 7, '')                                                             # H, 汇入地址
        sheet.add_cell(row, 8, cost.price)                                                     # I, 转账金额
        sheet.add_cell(row, 9, '')                                                             # J, 转账用途
        sheet.add_cell(row, 10, task.started_at.strftime('%F'))                                # K, 访谈日期
        sheet.add_cell(row, 11, task.pm.name_cn)                                               # L, 项目助理
        sheet.add_cell(row, 12, task.expert.phone)                                             # M, 手机号
        sheet.add_cell(row, 12, task.expert.mr_name)                                           # N, 专家姓名

        sum_price += cost.price
        row += 1
      end
    end
    sheet.add_cell(row, 8, sum_price)                                                          # 金额汇总
    sheet.add_cell(row, 9, (sum_price / 0.95).round(2))                                        # 金额汇总 / 0.95
  end

end