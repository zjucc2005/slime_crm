# encoding: utf-8
module CandidatesHelper

  def show_candidate_category
    category = case action_name
               when 'new' then 'expert'
               when 'edit' then @candidate.category
               else 'unknown'
               end
    Candidate::CATEGORY[category]
  end

  def show_candidate_data_source
    data_source = case action_name
                    when 'new' then 'manual'
                    when 'edit' then @candidate.data_source
                    when 'show' then @candidate.data_source
                    else 'unknown'
                  end
    Candidate::DATA_SOURCE[data_source]
  end

  def candidate_is_available_status(val)
    if val.nil?
      'pending'
    else
      val ? 'valid' : 'invalid'
    end
  end

  def candidate_is_available_display(val)
    val.nil? ? t(:pending) : t(val.to_s.to_sym)
  end

  def candidate_is_available_options
    [[t(:pending), ''], [t(:true), 'true'], [t(:false), 'false']]
  end

  def candidate_is_available_search_options
    [[t(:true), 'true'], [t(:false), 'false'], [t(:pending), 'nil']]
  end

  def work_exps
    params[:work_exp] || []
  end

  def candidate_payment_info_category_badge(category)
    dict = {
      :alipay => 'primary',
      :unionpay => 'danger'
    }.stringify_keys
    content_tag :span, CandidatePaymentInfo::CATEGORY[category] || category, :class => "badge badge-#{dict[category] || 'secondary'}"
  end

  # ========================================
  ##
  # background color for cps
  def cps_bg(value)
    case value
      when (0..1500) then 'bg-primary'
      when (1500..3000) then 'bg-success'
      when (3000..6000) then 'bg-warning'
      when (6000..10000) then 'bg-danger'
      else 'bg-gray'
    end
  end

  ##
  # highlight text by search params
  def hl(text, words=[])
    return text if words.blank? || text.nil?
    words.each do |word|
      text = text.gsub(word, "<hl class='text-red'>#{word}</hl>")
    end
    text.html_safe
  end

end