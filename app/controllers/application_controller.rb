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

  def redirect_with_return_to(default_path)
    if params[:return_to].present?
      redirect_to params[:return_to]
    else
      redirect_to default_path
    end
  end

end
