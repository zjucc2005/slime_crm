# encoding: utf-8
class Contract < ApplicationRecord

  # ENUM
  TYPE_OF_PAYMENT_DAY = { :natural => '自然日' }.stringify_keys
  PAYMENT_WAY = { :monthly => '月结', :by_project => '项目结', :advance_payment => '预付' }.stringify_keys

  # Associations
  belongs_to :creator, :class_name => 'User', :foreign_key => :created_by, :optional => true
  belongs_to :company, :class_name => 'Company'

  # Validations
  validates_presence_of :file, :started_at, :ended_at, :base_duration, :progressive_duration, :payment_way
  validates_format_of :base_duration, :with => /\A\d+(,\d+)*\Z/, :error => :invalid_format, :message => :invalid_format

  mount_uploader :file, FileUploader

  before_validation :setup, :on => :create

  # Scopes
  scope :available, -> { where('started_at <= :now AND ended_at >= :now', { :now => Time.now }) }

  ##
  # 重要!!价格算法
  # 参数 duration - 参与计费市场, f - follow up标识, 为true时按递进时长计算
  def base_price(duration=0, f=false)
    (priced_duration(duration, f) / 60.0 * charge_rate).round  # 整数
  end

  # 用于计价的时长, 实际时长根据合同的 base/progressive_duration 规则得出
  def priced_duration(duration=0, f=false)
    return 0 if duration.zero?
    return progressive_duration * (duration.to_f / progressive_duration).ceil if f
    thresholds = base_duration.split(',').map(&:to_i).sort  # base_duration 的 Array 形式, 升序排列
    result = thresholds[0]
    if duration > thresholds[-1]
      step = ((duration - thresholds[-1]).to_f / progressive_duration).ceil
      result = thresholds[-1] + progressive_duration * step
    else
      thresholds.each do |threshold|
        if duration <= threshold
          result = threshold
          break
        end
      end
    end
    result
  end

  # 收费时长整合 base + progressive
  def charge_duration
    "#{base_duration}+#{progressive_duration}"
  end

  private
  def setup
    self.started_at ||= Time.now
    self.type_of_payment_day ||= 'natural'
    self.tax_rate ||= 0
  end

end
