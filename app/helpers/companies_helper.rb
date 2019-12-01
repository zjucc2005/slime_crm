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
    _style_ = { :normal => 'primary', :client => 'danger' }.stringify_keys
    content_tag :span, Company::CATEGORY[category], :class => "badge badge-#{_style_[category]}"
  end
end