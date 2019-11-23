# encoding: utf-8
module CandidatesHelper

  ##
  #
  def show_category
    category = case action_name
               when 'new' then 'expert'
               when 'edit' then @candidate.category
               else 'unknown'
               end
    Candidate::CATEGORY[category]
  end

  def show_data_source
    data_source = case action_name
                  when 'new' then 'manual'
                  when 'edit' then @candidate.data_source
                  else 'unknown'
                  end
    Candidate::DATA_SOURCE[data_source]
  end

  def work_exps
    params[:work_exp] || []
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
  def hl(text, keyword)
    return text if keyword.nil? || text.nil?
    text.gsub(keyword, "<hl class='bg-red text-white'>#{keyword}</hl>").html_safe
  end

end