# encoding: utf-8
class StatisticsController < ApplicationController
  before_action :authenticate_user!

  # GET /statistics/current_month_count_infos.js
  def current_month_count_infos
    current_month = Time.now.beginning_of_month
    project_task_query = ProjectTask.where(status: 'finished').where('started_at >= ?', current_month)
    project_task_cost_query = ProjectTaskCost.joins(:project_task).where('project_tasks.status': 'finished').
      where('project_tasks.started_at >= ?', current_month).where('project_task_costs.category': 'expert')

    total_experts            = Candidate.expert.where('created_at >= ?', current_month).count
    total_tasks              = project_task_query.count
    total_task_duration_hour = (project_task_query.sum(:duration) / 60.0).round(1)
    total_income             = project_task_query.sum(:actual_price)
    total_expert_fee         = project_task_cost_query.sum(:price)

    @current_month_count_infos = [
      { :name => t('dashboard.total_experts'),            :value => total_experts,            :url => nil },
      { :name => t('dashboard.total_tasks'),              :value => total_tasks,              :url => nil },
      { :name => t('dashboard.total_task_duration_hour'), :value => total_task_duration_hour, :url => nil },
      { :name => t('dashboard.total_income'),             :value => total_income,             :url => nil },
      { :name => t('dashboard.total_expert_fee'),         :value => total_expert_fee,         :url => nil }
    ]

    respond_to do |f|
      f.js
    end
  end

  # GET /statistics/current_month_task_ranking?top=10
  def current_month_task_ranking
    current_month = Time.now.beginning_of_month
    result = ProjectTask.joins('LEFT JOIN users on users.id = project_tasks.created_by').
      where('project_tasks.status' => 'finished').
      where('project_tasks.started_at >= ?', current_month).
      select('sum(duration) AS total_duration, users.name_cn AS username, created_by').
      group(:created_by, :username).order(:total_duration => :desc)
    result = result.limit(params[:limit]) if params[:limit].present?

    @current_month_task_ranking = []
    result.each_with_index do |r, index|
      @current_month_task_ranking << { :seq => index + 1, :username => r.username, :hours => (r.total_duration / 60.0).round(1) }
    end

    respond_to do |f|
      f.js
      f.html
    end
  end

  # GET /statistics/unscheduled_projects.js
  def unscheduled_projects
    query = Project.where(status: 'initialized').order(:created_at => :asc)
    query = query.limit(params[:limit]) if params[:limit].present?
    @projects = query

    respond_to do |f|
      f.js
    end
  end

end