# encoding: utf-8
module CardTemplateHelper
  def html_safe(content)
    content.gsub(/(\r\n)|\n/, '<br>').html_safe
  end

  def card_template_options
    CardTemplate.where(user_channel_id: current_user.user_channel_id).pluck(:name, :id)
  end
end