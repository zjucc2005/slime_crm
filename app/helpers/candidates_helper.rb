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

  def show_owner
    owner = case action_name
            when 'new' then current_user.name_cn
            when 'edit' then @candidate.owner.name_cn
            else 'unknown'
            end
    "拥有者: #{owner}"
  end

  def show_timestamps
    if action_name == 'new'

    else
      created_at = @candidate.created_at.strftime('%F %T')
      updated_at = @candidate.updated_at.strftime('%F %T')
      "创建时间: #{created_at}, 最近更新: #{updated_at}"
    end
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