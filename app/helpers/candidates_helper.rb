# encoding: utf-8
module CandidatesHelper

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