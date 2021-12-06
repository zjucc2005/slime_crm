# encoding: utf-8
class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    if current_user.is_role?('su', 'admin')
      load_dashboard_of_admin
    elsif current_user.is_role?('finance')
      load_dashboard_of_finance
    elsif current_user.is_role?('pm', 'pa')
      load_dashboard_of_pm
    end
  end

  private
  def load_dashboard_of_admin
    @total_experts              = user_channel_filter(Candidate.expert).count
    @total_signed_companies     = user_channel_filter(Company.signed).count
    @total_tasks                = user_channel_filter(ProjectTask.where(status: 'finished')).count
    @total_charge_duration_hour = (user_channel_filter(ProjectTask.where(status: 'finished')).sum(:charge_duration) / 60.0).round(1)
    load_tips
  end

  def load_dashboard_of_finance
    load_dashboard_of_admin
    load_finance_tips
  end

  def load_dashboard_of_pm
    @total_experts              = Candidate.expert.where(created_by: current_user.id).count
    @total_tasks                = ProjectTask.where(status: 'finished', created_by: current_user.id).count
    @total_charge_duration_hour = (ProjectTask.where(status: 'finished', created_by: current_user.id).sum(:charge_duration) / 60.0).round(1)

    query = ProjectTask.where('pm_id = :uid OR pa_id = :uid', uid: current_user.id).where(status: 'ongoing')
    @project_tasks = query.order(:started_at => :asc).paginate(:page => params[:page], :per_page => 50)
    load_tips
  end

  def load_tips
    query = Project.where(status: 'ongoing').where.not(payment_way: 'advance_payment').
        where('last_task_created_at < ?', Time.now - 30.days).where('created_at > ?', '2021-05-01')
    idle_project_count = user_channel_filter(query.where(created_by: current_user.id)).count
    idle_project_url = idle_project_count.zero? ? nil : projects_path(is_idle: true, created_by: current_user.id)
    @tips = [
        { name: t('dashboard.idle_projects'), value: idle_project_count, url: idle_project_url }
    ]
    if current_user.admin?
      idle_project_admin_count = user_channel_filter(query).count
      idle_project_admin_url = idle_project_admin_count.zero? ? nil : projects_path(is_idle: true)
      @tips << { name: t('dashboard.idle_projects_admin'), value: idle_project_admin_count, url: idle_project_admin_url }
    end
  end

  def load_finance_tips
    overdue_task_count = user_channel_filter(ProjectTask.where(status: 'finished', charge_status: 'billed').where('charge_deadline < ?', Time.now)).count
    overdue_task_url = overdue_task_count.zero? ? nil : finance_index_path(overdue_charge: true)
    @finance_tips = [
        { name: t('dashboard.overdue_tasks'), value: overdue_task_count, url: overdue_task_url }
    ]
  end
end