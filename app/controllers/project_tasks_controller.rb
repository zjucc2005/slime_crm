# encoding: utf-8
class ProjectTasksController < ApplicationController
  load_and_authorize_resource
  before_action :authenticate_user!

  # GET /project_tasks/:id
  def show
    load_project_task
  end

  # GET /project_tasks/:id/edit
  def edit
    begin
      load_project_task
      load_active_contract

      check_editable # 只能编辑自己创建的任务
    rescue Exception => e
      flash[:error] = e.message
      redirect_to project_path(@project_task.project)
    end
  end

  # PUT /project_tasks/:id
  def update
    begin
      load_project_task

      if @project_task.update(project_task_params)
        @project_task.project.last_update
        if params[:commit] == t('action.submit_and_confirm')
          @project_task.finished!
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

    ActiveRecord::Base.transaction do
      cost = @project_task.costs.new(user_channel_id: current_user.user_channel_id)
      cost.category = params[:category]
      cost.price    = params[:price]
      cost.currency = params[:currency]
      cost.memo    = params[:memo]

      if params[:category] == 'expert' && params[:advance_payment] == 'false'  # expert fee
        template_expert = @project_task.expert.payment_infos.where(id: params[:template_expert]).first
        if template_expert
          cost.payment_info = {
            category:   template_expert.category,
            bank:       template_expert.bank,
            sub_branch: template_expert.sub_branch,
            account:    template_expert.account,
            username:   template_expert.username
          }
        else
          cost.payment_info = params[:payment_info]  # general
          @project_task.expert.payment_infos.create!(
            params.require(:payment_info).permit(:category, :bank, :sub_branch, :account, :username).merge(created_by: current_user.id)
          )
        end
      elsif params[:category] == 'recommend'  # recommend fee
        recommender = @project_task.expert.recommender  # recommender expert
        if recommender
          template_recommend = recommender.payment_infos.where(id: params[:template_recommend]).first
          if template_recommend
            cost.payment_info = {
              category:   template_recommend.category,
              bank:       template_recommend.bank,
              sub_branch: template_recommend.sub_branch,
              account:    template_recommend.account,
              username:   template_recommend.username
            }
          else
            cost.payment_info = params[:payment_info]  # general
            recommender.payment_infos.create!(
              params.require(:payment_info).permit(:category, :bank, :sub_branch, :account, :username).merge(created_by: current_user.id)
            )
          end
        else
          cost.payment_info = params[:payment_info]  # general
        end
      else
        cost.payment_info = params[:payment_info]  # general
      end
      cost.save!
    end
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
    f           = params[:f] == 'true'
    is_shorthand = params[:is_shorthand] == 'true'
    base_price  = contract.base_price(params[:duration].to_i, f)
    shorthand_price = is_shorthand ? contract.shorthand_price(params[:duration].to_i) : 0
    expert_rate = params[:expert_rate].to_d
    render :json => {
             :price    => base_price * expert_rate,
             :currency => ApplicationRecord::CURRENCY[contract.currency],
             :is_taxed => t(contract.is_taxed.to_s),
             :tax_rate => contract.tax_rate,
             :shorthand_price => shorthand_price
           }
  end

  # PUT /project_tasks/:id/cancel
  def cancel
    load_project_task

    if @project_task.can_cancel?
      @project_task.update(status: 'cancelled')
      @project_task.project.last_update
      flash[:success] = t(:operation_succeeded)
    else
      flash[:error] = t(:operation_failed)
    end
    redirect_to project_path(@project_task.project)
  end

  # GET /project_tasks/:id/gen_card
  def gen_card
    load_project_task

    if %w[ongoing finished].include?(@project_task.status)
      @company = @project_task.project.company
      @card_template_id = params[:card_template_id] || @company.card_template_id
      @card_template = CardTemplate.where(category: 'ProjectTask', id: @card_template_id).first
      if params[:set_as_default] == 'true'
        @company.update(card_template_id: @card_template.id)  # 保存为默认模板
      end
    else
      flash[:error] = t(:operation_failed)
      redirect_to root_path
    end
  end

  private
  def load_project_task
    @project_task = ProjectTask.find(params[:id])
  end

  def check_editable
    raise t(:not_authorized) unless @project_task.can_be_edited_by(current_user)
  end

  def load_active_contract
    @contract = @project_task.active_contract
    raise t(:contract_expired) if @contract.nil?
  end

  def project_task_params
    params.require(:project_task).permit(:pa_id, :interview_form, :started_at, :expert_level, :expert_rate, :duration, :charge_duration,
                                         :actual_price, :is_shorthand, :shorthand_price, :is_recorded, :memo, :f_flag)
  end

end