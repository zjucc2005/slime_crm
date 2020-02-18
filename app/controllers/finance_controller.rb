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
      # >> export code here
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

end