module ProjectsHelper

  # project status display style
  def project_status_badge(status)
    dict = { :initialized => 'warning', :ongoing => 'success', :finished => 'secondary' }.stringify_keys
    content_tag :span, Project::STATUS[status] || status, :class => "badge badge-#{dict[status] || 'secondary'}"
  end

  def project_task_category_options
    ProjectTask::CATEGORY.to_a.map(&:reverse)
  end

  def project_task_candidate_options
    @project.experts.pluck(:name_cn, :id)
  end

  def project_task_category_badge(category)
    dict = { :interview => 'primary' }.stringify_keys
    content_tag :span, ProjectTask::CATEGORY[category] || category, :class => "badge badge-#{dict[category] || 'secondary'}"
  end

end