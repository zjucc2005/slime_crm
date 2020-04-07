# encoding: utf-8
class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    if current_user.is_role?('admin')
      load_dashboard_of_admin
    end
  end

  private
  def load_dashboard_of_admin
    @total_experts            = Candidate.expert.count
    @total_signed_companies   = Company.signed.count
    @total_tasks              = ProjectTask.where(status: 'finished').count
    @total_task_duration_hour = (ProjectTask.where(status: 'finished').sum(:duration) / 60.0).round(1)
  end
end