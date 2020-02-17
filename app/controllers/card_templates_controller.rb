# encoding: utf-8
class CardTemplatesController < ApplicationController
  load_and_authorize_resource
  before_action :authenticate_user!

  # GET /card_templates
  def index
    @card_templates = CardTemplate.all.order(:created_at => :desc).paginate(:page => params[:page], :per_page => 20)
  end

  # GET /card_templates/:id
  def show
    load_card_template
  end

  # GET /card_templates/new
  def new
    @card_template = CardTemplate.new
  end

  # POST /card_templates
  def create
    begin
      @card_template = CardTemplate.new(card_template_params)

      if @card_template.save
        flash[:success] = t(:operation_succeeded)
        redirect_to card_templates_path
      else
        render :new
      end
    rescue Exception => e
      flash[:error] = e.message
      redirect_to card_templates_path
    end
  end

  # GET /card_templates/:id/edit
  def edit
    load_card_template
  end

  # PUT /card_templates/:id
  def update
    begin
      load_card_template

      if @card_template.update(card_template_params)
        flash[:success] = t(:operation_succeeded)
        redirect_to card_templates_path
      else
        render :edit
      end
    rescue Exception => e
      flash[:error] = e.message
      redirect_to card_templates_path
    end
  end

  # DELETE /card_templates/:id
  def destroy
    begin
      load_card_template

      raise t(:cannot_delete) unless @card_template.can_destroy?
      @card_template.destroy!
      flash[:success] = t(:operation_succeeded)
      redirect_to card_templates_path
    rescue Exception => e
      flash[:error] = e.message
      redirect_to card_templates_path
    end
  end

  private
  def card_template_params
    params.require(:card_template).permit(:name, :content)
  end

  def load_card_template
    @card_template = CardTemplate.find(params[:id])
  end

end