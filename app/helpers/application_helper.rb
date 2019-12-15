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

  def fa_icon_tag(category)
    content_tag :i, nil, :class => "fa fa-#{category}"
  end

  def model_error_tag(instance)
    if instance.errors.any?
      content_tag :ul, :class => 'model-error' do
        instance.errors.full_messages.map do |message|
          content_tag :li, message, :class => 'model-error-item'
        end.join.html_safe
      end
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
    [[t(:true), 'true'], [t(:false), 'false']]
  end

  def boolean_display(val)
    t(val.to_s.to_sym)
  end

  ##
  # show creator of instance
  def show_creator(instance)
    creator = case action_name
            when 'new' then current_user.name_cn
            when 'create' then current_user.name_cn
            when 'show' then instance.creator.name_cn
            when 'edit' then instance.creator.name_cn
            when 'update' then instance.creator.name_cn
            else 'unknown'
            end
    "#{mt(:candidate, :created_by)}: #{creator}"
  end

  ##
  # show timestamps of instance
  def show_timestamps(instance)
    if %w[new create].include? action_name

    else
      created_at = instance.created_at.strftime('%F %T')
      updated_at = instance.updated_at.strftime('%F %T')
      "创建时间: #{created_at}, 最近更新: #{updated_at}"
    end
  end
end
