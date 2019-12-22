# encoding: utf-8
class LocationDataController < ApplicationController
  load_and_authorize_resource
  before_action :authenticate_user!

  # GET /location_data?level=0
  def index
    if params[:parent_id].present?
      load_each_level
      @location_data = LocationDatum.where(level: params[:level], parent_id: params[:parent_id])
    else
      @location_data = LocationDatum.where(level: params[:level] || 0)
    end
  end

  # GET /location_data/autocomplete_city.json
  def autocomplete_city
    @cities = LocationDatum.cities.where("name LIKE ?", "%#{params[:term].strip}%")
    render :json => @cities.map{ |city|
      if LocationDatum::DIRECT_CODE.include?(city.code[0, 2])
        city.name
      else
        "#{city.parent.name}#{city.name}"
      end
    }
  end

  private
  def load_each_level
    @parent = LocationDatum.find(params[:parent_id])

    instance_variable_set("@level_#{@parent.level}", @parent)
    if @parent.level > 0
      1.upto(@parent.level) do |i|
        instance_variable_set("@level_#{@parent.level - i}",  instance_variable_get("@level_#{@parent.level - i + 1}").parent)
      end
    end
  end

end