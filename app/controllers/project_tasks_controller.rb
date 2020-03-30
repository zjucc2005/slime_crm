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

      if @project_task.update(project_task_params)
        if params[:commit] == t('action.submit_and_confirm')
          @project_task.update(status: 'finished')
        end
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

  # POST /project_tasks/:id/add_cost.js, remote: true
  def add_cost
    load_project_task
    @project_task.costs.create!(
       category:     params[:category],
       price:        params[:price],
       currency:     params[:currency],
       memo:         params[:memo],
       payment_info: params[:payment_info]
    )
    respond_to{|f| f.js }
  end

  # DELETE /project_tasks/:id/remove_cost.js, remote: true
  def remove_cost
    load_project_task

    cost = @project_task.costs.where(id: params[:project_task_cost_id]).first
    cost.try(:destroy!)
    respond_to{|f| f.js { render :add_cost } }

  end

  # GET /project_tasks/:id/get_base_price.json
  def get_base_price
    load_project_task
    contract    = @project_task.active_contract
    base_price  = contract.base_price(params[:duration].to_i)
    expert_rate = params[:expert_rate].to_d
    render :json => {
             :price    => base_price * expert_rate,
             :currency => ApplicationRecord::CURRENCY[contract.currency],
             :is_taxed => t(contract.is_taxed.to_s),
             :tax_rate => contract.tax_rate
           }
  end

  # PUT /project_tasks/:id/cancel
  def cancel
    load_project_task

    if @project_task.can_cancel?
      @project_task.update(status: 'cancelled')
      flash[:success] = t(:operation_succeeded)
    else
      flash[:error] = t(:operation_failed)
    end
    redirect_to project_path(@project_task.project)
  end

  private
  def load_project_task
    @project_task = ProjectTask.find(params[:id])
  end

  def project_task_params
    params.require(:project_task).permit(:interview_form, :started_at, :expert_level, :expert_rate, :duration,
                                         :actual_price, :is_shorthand, :shorthand_price, :is_recorded)
  end

end