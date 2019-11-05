module ApplicationHelper
  def display_flash_message
    msg = ''
    %w[notice success warning error].each do |category|
      msg << flash_tag(category.to_sym) if flash[category.to_sym]
    end
    msg.html_safe
  end

  def flash_tag(category)
    _type_ =  {:error => 'danger', :warning => 'warning', :success => 'success', :notice => 'info' }[category]
    # render :partial => 'shared/flash', :locals => { :category => _type_, :message => message }
    content_tag(:div, :class => "alert alert-#{_type_} alert-dismissible fade show") do
      button_tag('&times;'.html_safe, :type => 'button', :class => 'close', :data => { :dismiss => 'alert' }) +
      flash[category]
    end
  end
end
