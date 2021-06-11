# encoding: utf-8
class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    if current_user.is_role?('su', 'admin', 'finance')
      load_dashboard_of_admin
    elsif current_user.is_role?('pm', 'pa')
      load_dashboard_of_pm
    end
  end

  private
  def load_dashboard_of_admin
    @total_experts              = user_channel_filter(Candidate.expert).count
    @total_signed_companies     = user_channel_filter(Company.signed).count
    @total_tasks                = user_channel_filter(ProjectTask.where(status: 'finished')).count
    @total_charge_duration_hour = ( user_channel_filter(ProjectTask.where(status: 'finished')).sum(:charge_duration) / 60.0).round(1)
  end

  def load_dashboard_of_pm
    @total_experts              = Candidate.expert.where(created_by: current_user.id).count
    @total_tasks                = ProjectTask.where(status: 'finished', created_by: current_user.id).count
    @total_charge_duration_hour = (ProjectTask.where(status: 'finished', created_by: current_user.id).sum(:charge_duration) / 60.0).round(1)

    query = ProjectTask.where('pm_id = :uid OR pa_id = :uid', uid: current_user.id)
    @project_tasks = query.order(:status => :desc, :started_at => :desc).paginate(:page => params[:page], :per_page => 50)
  end
end