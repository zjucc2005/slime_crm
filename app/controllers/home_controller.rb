# encoding: utf-8
class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    if current_user.is_role?('admin')
      load_dashboard_of_admin
    end
  end

  # GET /load_finance_chart.js, remote: true
  def load_finance_chart

  end

  private
  def load_dashboard_of_admin
    @total_experts  = Candidate.expert.count
    @total_projects = Project.where(status: %w[ongoing finished]).count
    @total_tasks    = ProjectTask.where(status: %w[ongoing finished]).count
    @total_staffs   = User.active.count
  end
end