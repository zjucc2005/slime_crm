# encoding: utf-8
class CandidatesController < ApplicationController

  def index
    query = Candidate.all
    # query code here >>

    @candidates = query.order(:created_at => :desc).paginate(:page => params[:page], :per_page => 20)
  end

  def new
    @candidate = Candidate.new
  end

  def create
    begin
      @candidate = current_user.candidates.new(candidate_params)

      if @candidate.valid?
        ActiveRecord::Base.transaction do
          @candidate.save!
          # candidate.experiences.map(&:save)
        end
      end

    rescue Exception => e
      flash.now[:error] = "#{e.message}"
      render :new
    end
  end

  private
  def load_candidate
    @candidate = Candidate.find(params[:id])
  end

  def candidate_params
    params.require(:candidate).permit(:name_cn, :name_en, :city, :email, :email1, :phone, :phone1, :industry, :title,
                                      :date_of_birth, :gender, :description, :is_available, :cpt,
                                      :bank, :bank_card, :bank_user, :alipay_account, :alipay_user)
  end
end