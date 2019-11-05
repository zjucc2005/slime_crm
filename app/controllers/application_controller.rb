class ApplicationController < ActionController::Base
  def home
    if signed_in?
      render :home
    else
      redirect_to new_user_session_path
    end
  end
end
