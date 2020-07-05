# encoding: utf-8
module UsersHelper

  # user role options
  def user_role_options
    permit_roles = %w[pm pa finance]
    User::ROLES.select{|k, v| permit_roles.include? k }.to_a.map(&:reverse)
  end

  # user status options
  def user_status_options
    User::STATUS.to_a.map(&:reverse)
  end

  # user role display style
  def user_role_badge(role)
    dict = { :admin => 'danger', :pm => 'primary', :pa => 'info', :finance => 'warning' }.stringify_keys
    content_tag :span, User::ROLES[role] || role, :class => "badge badge-#{dict[role] || 'dark'}"
  end

  # user status display style
  def user_status_badge(status)
    dict = { :active => 'success', :inactive => 'secondary' }.stringify_keys
    content_tag :span, User::STATUS[status] || status, :class => "badge badge-#{dict[status] || 'secondary'}"
  end

  # user channel display style
  def user_channel_badge(channel)
    content_tag :span, channel, :class => 'badge badge-dark'
  end

  def user_channel_filter(query, field='user_channel_id')
    if current_user.su? && current_user.user_channel_id.blank?
      query
    else
      query.where(field => current_user.user_channel_id)
    end
  end

  def user_channel_options
    UserChannel.all.order(:id => :asc).pluck(:name, :id)
  end

end