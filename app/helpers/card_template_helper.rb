# encoding: utf-8
module CardTemplateHelper
  def html_safe(content)
    content.gsub(/(\r\n)|\n/, '<br>').html_safe
  end

  # 卡片模板
  # category: 'Candidate/ProjectTask'
  def card_template_options(category)
    user_channel_filter(CardTemplate.where(category: category).order(seq: :desc, created_at: :asc)).pluck(:name, :id)
  end

end