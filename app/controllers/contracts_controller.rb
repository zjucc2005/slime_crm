# encoding: utf-8
class ContractsController < ApplicationController
  before_action :authenticate_user!

  # POST /contracts
  def create
    begin
      @company = Company.find(params[:contract][:company_id])
      @contract = @company.contracts.new(contract_params.merge(created_by: current_user.id))
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

      if @contract.update(contract_params)
        flash[:success] = t(:operation_succeeded)
        redirect_to edit_contract_path(@contract)
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
    params.require(:contract).permit(:file, :started_at, :ended_at, :cpt, :min_bill_duration, :follow_bill_duration,
                                     :payment_time, :payment_way, :is_tax_included, :is_invoice_needed)
  end
end