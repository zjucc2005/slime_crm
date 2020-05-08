# encoding: utf-8
class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    if current_user.is_role?('admin', 'finance')
      load_dashboard_of_admin
    elsif current_user.is_role?('pm', 'pa')
      load_dashboard_of_pm
    end
  end

  private
  def load_dashboard_of_admin
    @total_experts            = Candidate.expert.count
    @total_signed_companies   = Company.signed.count
    @total_tasks              = ProjectTask.where(status: 'finished').count
    @total_charge_duration_hour = (ProjectTask.where(status: 'finished').sum(:charge_duration) / 60.0).round(1)
  end

  def load_dashboard_of_pm
    @project_tasks = ProjectTask.where(status: 'ongoing', created_by: current_user.id)
  end
end