# encoding: utf-8
class CandidatesController < ApplicationController
  def index
    # flash[:notice] = 'route ok!'
  end

  def new
    render :plain => "url(:#{controller_name}, :#{action_name}) route ok!"
  end
end