class ApplicationController < ActionController::Base

  # handle unauthorized access
  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.json { head :forbidden, content_type: 'text/html' }
      format.html { redirect_to main_app.root_url, notice: exception.message }
      format.js   { head :forbidden, content_type: 'text/html' }
    end
  end

  private
  def open_spreadsheet(file)
    begin
      Roo::Spreadsheet.open file
    rescue
      raise '文件格式错误'
    end
  end

end
