module ProjectsHelper

  # project status display style
  def project_status_badge(status)
    dict = { :initialized => 'warning', :ongoing => 'success', :finished => 'secondary' }.stringify_keys
    content_tag :span, Project::STATUS[status] || status, :class => "badge badge-#{dict[status] || 'secondary'}"
  end

end