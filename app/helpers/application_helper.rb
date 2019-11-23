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
    content_tag(:div, :class => "alert alert-#{_type_} alert-dismissible fade show mb-0") do
      button_tag('&times;'.html_safe, :type => 'button', :class => 'close', :data => { :dismiss => 'alert' }) +
      flash[category]
    end
  end

  ##
  # I18n for models
  def mt(model, attr=nil)
    if attr.nil?
      I18n.t("activerecord.models.#{model}")
    else
      if I18n.exists?("activerecord.attributes.#{model}.#{attr}")
        I18n.t("activerecord.attributes.#{model}.#{attr}")
      elsif I18n.exists?("attributes.#{attr}")
        I18n.t("attributes.#{attr}")
      else
        I18n.t("activerecord.attributes.#{model}.#{attr}")
      end
    end
  end

  ##
  # activate sidebar options
  def activate_sidebar
    nav_item = :"nav_#{controller_name}"
    # special settings here >>

    # >>
    provide nav_item, 'active'
  end

  ##
  # boolean options for select tag
  def boolean_options
    [[I18n.t(:true), 'true'], [I18n.t(:false), 'false']]
  end
end
