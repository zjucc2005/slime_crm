# encoding: utf-8
module CardTemplateHelper
  def html_safe(content)
    content.gsub(/(\r\n)|\n/, '<br>').html_safe
  end

  def card_template_options
    CardTemplate.pluck(:name, :id)
  end
end