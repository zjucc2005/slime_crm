# encoding: utf-8
class CandidatePaymentInfosController < ApplicationController
  load_and_authorize_resource
  before_action :authenticate_user!

  # GET /candidate_payment_infos/:id/edit
  def edit
    load_candidate_payment_info
  end

  # PUT /candidate_payment_infos/:id
  def update
    begin
      load_candidate_payment_info

      if @candidate_payment_info.update(candidate_payment_info_params)
        flash[:success] = t(:operation_succeeded)
        redirect_to payment_infos_candidate_path(@candidate_payment_info.candidate)
      else
        render :edit
      end
    rescue Exception => e
      flash[:error] = e.message
      redirect_to root_path
    end
  end

  # DELETE /candidate_payment_infos/:id
  def destroy
    begin
      load_candidate_payment_info

      @candidate_payment_info.destroy!
      flash[:success] = t(:operation_succeeded)
      redirect_to payment_infos_candidate_path(@candidate_payment_info.candidate)
    rescue Exception => e
      flash[:error] = e.message
      redirect_to root_path
    end
  end

  private
  def load_candidate_payment_info
    @candidate_payment_info = CandidatePaymentInfo.find(params[:id])
  end

  def candidate_payment_info_params
    params.require(:candidate_payment_info).permit(:category, :bank, :sub_branch, :account, :username, :id_number)
  end

end