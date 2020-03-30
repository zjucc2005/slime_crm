# encoding: utf-8
class CandidatePaymentInfo < ApplicationRecord
  # ENUM
  CATEGORY = {
    :unionpay => '银联',
    :alipay   => '支付宝'
  }.stringify_keys

  # Assocications
  belongs_to :creator, :class_name => 'User', :foreign_key => :created_by
  belongs_to :candidate, :class_name => 'Candidate'

  # Validations
  validates_presence_of :account, :username
  validates_inclusion_of :category, :in => CATEGORY.keys

  def to_template
    case category
      when 'unionpay' then "#{CATEGORY[category]} | #{bank} | #{sub_branch} | #{account} | #{username}"
      when 'alipay' then "#{CATEGORY[category]} | #{account} | #{username}"
      else category
    end
  end
end
