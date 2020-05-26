# encoding: utf-8
class ContractsController < ApplicationController
  load_and_authorize_resource
  before_action :authenticate_user!

  # POST /contracts
  def create
    begin
      @company = Company.find(params[:contract][:company_id])
      @contract = @company.contracts.new(
          contract_params.merge({ created_by: current_user.id, financial_info: params[:financial_info].permit(financial_info_fields) })
      )
      if @contract.save
        flash[:success] = t(:operation_succeeded)
        redirect_to company_path(@company)
      else
        flash.now[:error] = t(:operation_failed)
        render 'companies/new_contract'
      end
    rescue Exception => e
      flash[:error] = e.message
      redirect_to companies_path
    end
  end

  # GET /contracts/:id/edit
  def edit
    load_contract
  end

  # PUT /contracts/:id
  def update
    begin
      load_contract

      if @contract.update(contract_params.merge(financial_info: params[:financial_info].permit(financial_info_fields)))
        flash[:success] = t(:operation_succeeded)
        redirect_to company_path(@contract.company)
      else
        render :edit
      end
    rescue Exception => e
      flash.now[:error] = e.message
      render :edit
    end
  end

  private
  def load_contract
    @contract = Contract.find(params[:id])
  end

  def contract_params
    params.require(:contract).permit(:file, :started_at, :ended_at, :charge_rate, :currency, :base_duration, :progressive_duration,
                                     :payment_days, :type_of_payment_day, :payment_way, :is_taxed, :tax_rate, :is_invoice_needed,
                                     :shorthand_rate)
  end

  def financial_info_fields
    [:name_cn, :name_en, :phone, :email]
  end
end