# encoding: utf-8
class ProjectTasksController < ApplicationController
  load_and_authorize_resource
  before_action :authenticate_user!

  # GET /project_tasks/:id/edit
  def edit
    load_project_task
  end

  # PUT /project_tasks/:id
  def update
    begin
      load_project_task

      # construct payment_info_params
      append_params = Hash.new
      if project_task_params[:cost].to_i > 0
        cpi = CandidatePaymentInfo.find(params[:candidate_payment_info_id])
        append_params[:payment_method] = cpi.category
        append_params[:payment_info] = {
          :reference_id => cpi.id,
          :category     => cpi.category,
          :bank         => cpi.bank,
          :account      => cpi.account,
          :username     => cpi.username,
          :memo         => params[:payment_memo]
        }
      else
        append_params[:payment_method] = nil
        append_params[:payment_info] = {}
        append_params[:payment_status] = 'free'
      end

      if @project_task.update(project_task_params.merge(append_params))
        flash[:success] = t(:operation_succeeded)
        redirect_to project_path(@project_task.project)
      else
        render :edit
      end
    rescue Exception => e
      flash.now[:error] = e.message
      render :edit
    end
  end

  # GET /project_tasks/:id/get_base_price.json
  def get_base_price
    load_project_task
    contract = @project_task.active_contract
    render :json => {
             :price => contract.base_price(params[:duration].to_i),
             :currency => ApplicationRecord::CURRENCY[contract.currency]
           }
  end

  private
  def load_project_task
    @project_task = ProjectTask.find(params[:id])
  end

  def project_task_params
    params.require(:project_task).permit(:interview_form, :status, :started_at, :duration, :actual_price, :cost)
  end

end