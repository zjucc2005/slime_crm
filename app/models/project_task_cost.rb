# encoding: utf-8
class ProjectTaskCost < ApplicationRecord
  # ENUM
  CATEGORY = {
    :expert      => '专家费用',
    :recommend   => '推荐费用',
    :translation => '翻译费用',
    :others      => '其他费用'
  }.stringify_keys

  CATEGORY_LIMIT = {
    :expert      => 1,  # 费用条目限制
    :recommend   => 1,
    :translation => 1,
    :others      => 999
  }.stringify_keys

  # Associations
  belongs_to :project_task, :class_name => 'ProjectTask'

  # Validations
  validates_inclusion_of :category, :in => CATEGORY.keys
  validates_presence_of :price, :currency

  before_validation :setup, :on => :create

  # 用于表格导出
  def bank_or_alipay
    if self.payment_info['category'] == 'alipay'
      CandidatePaymentInfo::CATEGORY['alipay']
    elsif self.payment_info['category'] == 'unionpay'
      self.payment_info['bank']
    end
  end

  private
  def setup
    self.payment_status ||= 'unpaid'  # init
  end
end
