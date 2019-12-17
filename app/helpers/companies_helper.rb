# encoding: utf-8
module CompaniesHelper

  # category display style
  def company_category_badge(category)
    dict = { :normal => 'secondary', :client => 'primary' }.stringify_keys
    content_tag :span, Company::CATEGORY[category], :class => "badge badge-#{dict[category]}"
  end

  # signed status display style
  def company_signed_badge(is_signed=true)
    if is_signed
      content_tag :span, t(:company_signed), :class => 'badge badge-danger'
    else
      content_tag :span, t(:company_not_signed), :class => 'badge badge-secondary'
    end
  end
end