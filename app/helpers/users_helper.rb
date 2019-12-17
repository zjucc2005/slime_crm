# encoding: utf-8
module UsersHelper

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

end