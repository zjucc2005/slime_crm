# encoding: utf-8
class CandidatesController < ApplicationController
  def index
  end

  def new
    render :plain => "url(:#{controller_name}, :#{action_name}) route ok!"
  end
end