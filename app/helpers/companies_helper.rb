# encoding: utf-8
module CompaniesHelper

  def show_company_category
    category = case action_name
               when 'new' then nil
               when 'edit' then @company.category
               else nil
               end
    Company::CATEGORY[category]
  end

  def show_company_owner
    show_owner(@company)
  end

  def show_company_timestamps
    show_timestamps(@company)
  end

  def category_options
    Company::CATEGORY.to_a.map(&:reverse)
  end

  ##
  # category display style
  def company_category_badge(category)
    dict = { :normal => 'secondary', :client => 'primary' }.stringify_keys
    content_tag :span, Company::CATEGORY[category], :class => "badge badge-#{dict[category]}"
  end

  def company_signed_badge(is_signed=true)
    if is_signed
      content_tag :span, t(:company_signed), :class => 'badge badge-danger'
    else
      content_tag :span, t(:company_not_signed), :class => 'badge badge-secondary'
    end

  end
end