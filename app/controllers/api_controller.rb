# encoding: utf-8
class ApiController < ApplicationController
  skip_before_action :verify_authenticity_token, raise: false

  # 创建专家接口
  # POST /api/createExpert
  def createExpert
    begin
      load_request_params
      user_channel = UserChannel.all.order(:id => :asc).first  # default user_channel
      user = user_channel.users.admin.order(:id => :asc).first # default admin user
      @result = Api::Candidate.create_expert(@request_params, user.id, user_channel.id)
      render :json => @result
    rescue Exception => e
      render :json => { status: false, msg: e.message }
    end
  end

  private
  def load_request_params
    request.body.rewind
    request_body_read = request.body.read
    logger.info "request body: #{request_body_read}"
    @request_params = JSON.parse(request_body_read) rescue params
  end
end