# encoding: utf-8
class StatisticsController < ApplicationController
  before_action :authenticate_user!
  # load_and_authorize_resource

  # GET /statistics/current_month_count_infos.js
  def current_month_count_infos
    current_month = Time.now.beginning_of_month
    project_task_query = ProjectTask.where(status: 'finished', currency: 'RMB').where('started_at >= ?', current_month)
    project_task_query = user_channel_filter(project_task_query)
    project_task_cost_query = ProjectTaskCost.joins(:project_task).where('project_tasks.status': 'finished', 'project_task_costs.currency': 'RMB').
      where('project_tasks.started_at >= ?', current_month).where('project_task_costs.category': 'expert')
    project_task_cost_query = user_channel_filter(project_task_cost_query)

    total_experts              = user_channel_filter(Candidate.expert.where('created_at >= ?', current_month)).count
    total_tasks                = project_task_query.count
    total_charge_duration_hour = (project_task_query.sum(:charge_duration) / 60.0).round(1)
    total_income               = project_task_query.sum(:actual_price)
    total_income_unbilled      = project_task_query.where('project_tasks.charge_status' => 'unbilled').sum(:actual_price)
    total_income_billed        = project_task_query.where('project_tasks.charge_status' => 'billed').sum(:actual_price)
    total_expert_fee           = project_task_cost_query.sum('project_task_costs.price')
    total_expert_fee_unpaid    = project_task_cost_query.where('project_tasks.payment_status' => 'unpaid').sum('project_task_costs.price')

    @current_month_count_infos = [
      { :name => t('dashboard.total_experts'),              :value => total_experts,              :url => nil },
      { :name => t('dashboard.total_tasks'),                :value => total_tasks,                :url => nil },
      { :name => t('dashboard.total_charge_duration_hour'), :value => total_charge_duration_hour, :url => nil },
      { :name => t('dashboard.total_income'),               :value => total_income,               :url => finance_summary_statistics_path },
      { :name => t('dashboard.total_income_unbilled'),      :value => total_income_unbilled,      :url => nil },
      { :name => t('dashboard.total_income_billed'),        :value => total_income_billed,        :url => nil },
      { :name => t('dashboard.total_expert_fee'),           :value => total_expert_fee,           :url => finance_summary_statistics_path },
      { :name => t('dashboard.total_expert_fee_unpaid'),    :value => total_expert_fee_unpaid,    :url => nil }
    ]

    respond_to do |f|
      f.js
    end
  end

  # GET /statistics/current_month_task_ranking?limit=10
  def current_month_task_ranking
    # 最近12个月份
    current_month = Time.now.beginning_of_month
    @month_options = []
    12.times do |i|
      _month_ = current_month - i.month
      @month_options << [_month_.strftime('%Y-%m'), _month_.strftime('%F')]
    end

    s_month = (params[:month].to_time rescue nil) || current_month  # 统计月份
    result = []
    users = User.active.where(role: %w[admin pm pa])  # 激活中用户 + 角色admin/pm/pa
    users = user_channel_filter(users)
    project_tasks = ProjectTask.where(status: 'finished').where('started_at >= ? AND started_at < ?', s_month, s_month + 1.month)
    users.each do |user|
      pm_minutes = project_tasks.where(pm_id: user.id).sum(:charge_duration) * 0.5  # 权重 0.5
      pa_minutes = project_tasks.where(pa_id: user.id).sum(:charge_duration) * 0.5  # 权重 0.5
      total_minutes = pm_minutes + pa_minutes
      if total_minutes > 0
        result << { :username => user.name_cn, :pm_minutes => pm_minutes, :pa_minutes => pa_minutes, :total_minutes => total_minutes }
      end
    end
    @current_month_task_ranking = result.sort_by{|e| e[:total_minutes]}.reverse
    if params[:limit].present?
      @current_month_task_ranking = @current_month_task_ranking[0, params[:limit].to_i]
    end
    respond_to do |f|
      f.js
      f.html
    end
  end

  # GET /statistics/current_month_call_ranking?limit=10&mode=b
  # mode: b, 双月比较模式
  def current_month_call_ranking
    current_month = Time.now.beginning_of_month
    @month_options = []
    12.times do |i|
      _month_ = current_month - i.month
      @month_options << [_month_.strftime('%Y-%m'), _month_.strftime('%F')]
    end
    s_month = (params[:month].to_time rescue nil) || current_month  # 统计月份
    query = ProjectTask.joins(:project).where('project_tasks.status': 'finished').where('project_tasks.started_at BETWEEN ? AND ?', s_month, s_month + 1.month)
    group_data = query.select('projects.company_id AS company_id, COUNT(*) AS count').group('company_id').order('count DESC')
    if params[:limit].present?
      group_data = group_data.limit(params[:limit])
    end
    @result = group_data.map do |item|
      company = Company.find(item.company_id)
      { id: company.id, name: company.name, name_abbr: company.name_abbr, count: [item.count] }
    end
    if params[:mode] == 'b'
      @result.each do |item|
        prev_count = ProjectTask.joins(:project).where('project_tasks.status': 'finished', 'projects.company_id': item[:id]).
            where('project_tasks.started_at BETWEEN ? AND ?', s_month - 1.month, s_month).count
        item[:count] << prev_count
      end
    end
    if @result.blank?
      @result = [{ name: 'NO DATA', name_abbr: 'NO DATA', count: [0] }]  # friendly show for chart
    end
    # test data
    # @result = [
    #     { name: '昆仑', name_abbr: '昆仑', count: [100, 121] },
    #     { name: '淡水泉', name_abbr: '淡水泉', count: [88, 80] },
    #     { name: 'RB', name_abbr: 'RB', count: [76, 30] },
    #     { name: '锶钟', name_abbr: '锶钟', count: [32, 80], prev: 80 },
    #     { name: '安永', name_abbr: '安永', count: [28, 2], prev: 2 },
    #     { name: '东方证券', name_abbr: '东方证券', count: [16, 20], prev: 20 },
    #     { name: 'WIW', name_abbr: 'WIW', count: [7, 5], prev: 5 },
    #     { name: 'L.E.K.', name_abbr: 'L.E.K.', count: [2, 0], prev: 0 },
    #     { name: 'LLL', name_abbr: 'LLL', count: [2, 2], prev: 2 },
    #     { name: 'C.C.', name_abbr: 'C.C.', count: [2, 1], prev: 1 }
    # ]
    respond_to do |f|
      f.js
      f.html
    end
  end

  # GET /statistics/unscheduled_projects.js
  # def unscheduled_projects
  #   query = Project.where(status: 'initialized').order(:created_at => :asc)
  #   query = user_channel_filter(query)
  #   query = query.limit(params[:limit]) if params[:limit].present?
  #   @projects = query
  #
  #   respond_to do |f|
  #     f.js
  #   end
  # end

  # GET /statistics/ongoing_project_tasks
  def ongoing_project_tasks
    query = ProjectTask.where(status: 'ongoing').order(:started_at => :asc)
    query = user_channel_filter(query)
    @count = query.count
    query = query.limit(params[:limit]) if params[:limit].present?
    @project_tasks = query
  end

  # GET /statistics/finance_summary
  def finance_summary
    current_year = Time.now.year
    @year_options = (2019..current_year).to_a.reverse              # year options
    @year = params[:year] || current_year                          # statistical year
    @currency = params[:currency] || 'RMB'                         # currency
    @user_channel_id = params[:user_channel_id] || current_user.user_channel_id  # user_channel_id
    @x_axis = I18n.locale == :zh_cn ?
      %w[1月 2月 3月 4月 5月 6月 7月 8月 9月 10月 11月 12月] : %w[Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec]

    # annual total infos
    o_time = Time.local @year  # original time

    income              = []
    expense             = []
    expense_expert      = []
    expense_recommend   = []
    expense_translation = []
    expense_others      = []

    project_task_query = ProjectTask.where(status: 'finished', currency: @currency)
    project_task_cost_query = ProjectTaskCost.joins(:project_task).where('project_tasks.status': 'finished', 'project_task_costs.currency': @currency)
    if @user_channel_id.present?
      project_task_query = project_task_query.where(user_channel_id: @user_channel_id)
      project_task_cost_query = project_task_cost_query.where(user_channel_id: @user_channel_id)
    end

    12.times do |i|
      s_time = o_time + i.month  # start time
      e_time = s_time + 1.month  # end time

      cost_group = project_task_cost_query.where('project_tasks.started_at BETWEEN ? AND ?', s_time, e_time).
        select('SUM(project_task_costs.price) AS sum_price, project_task_costs.category').group('project_task_costs.category')

      expert_fee      = cost_group.select{|c| c.category == 'expert' }[0].try(:sum_price)      || 0.0
      recommend_fee   = cost_group.select{|c| c.category == 'recommend' }[0].try(:sum_price)   || 0.0
      translation_fee = cost_group.select{|c| c.category == 'translation' }[0].try(:sum_price) || 0.0
      others_fee      = cost_group.select{|c| c.category == 'others' }[0].try(:sum_price)      || 0.0

      income << project_task_query.where('started_at BETWEEN ? AND ?', s_time, e_time).sum(:actual_price)
      expense << expert_fee + recommend_fee + translation_fee + others_fee
      expense_expert << expert_fee
      expense_recommend << recommend_fee
      expense_translation << translation_fee
      expense_others << others_fee
    end


    @result = [
      { :name => t('dashboard.total_income'), :data => income },
      { :name => t('dashboard.expense'), :data => expense },
      { :name => t('dashboard.expense_expert'), :data => expense_expert, :stack => t('dashboard.expense') },
      { :name => t('dashboard.expense_recommend'), :data => expense_recommend, :stack => t('dashboard.expense') },
      { :name => t('dashboard.expense_translation'), :data => expense_translation, :stack => t('dashboard.expense') },
      { :name => t('dashboard.expense_others'), :data => expense_others, :stack => t('dashboard.expense') },
    ]

    @annual_count_infos = [
      { :name => t('dashboard.total_income'), :value => income.sum },
      { :name => t('dashboard.expense'), :value => expense.sum },
      { :name => t('dashboard.expense_expert'), :value => expense_expert.sum },
      { :name => t('dashboard.expense_recommend'), :value => expense_recommend.sum },
      { :name => t('dashboard.expense_translation'), :value => expense_translation.sum },
      { :name => t('dashboard.expense_others'), :value => expense_others.sum }
    ]
  end
end