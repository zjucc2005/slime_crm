# encoding: utf-8
class ProjectTask < ApplicationRecord
  # ENUM
  CATEGORY = { :interview => '访谈' }.stringify_keys
  STATUS = { :ongoing  => '进展中', :finished => '已结束', :cancelled => '已取消'}.stringify_keys
  CHARGE_STATUS = { :unbilled => '未出账', :billed => '已出账', :paid => '已收费'}.stringify_keys
  PAYMENT_STATUS = { :unpaid => '未支付', :paid => '已支付' }.stringify_keys
  INTERVIEW_FORM = {
    :telephone      => '电话',
    :'face-to-face' => '面谈',
    :data           => '数据',
    :roadshow       => '路演',
    :others         => '其他'
  }.stringify_keys
  EXPERT_LEVEL = { :standard => 'Standard', :premium  => 'Premium' }.stringify_keys

  # Associations
  belongs_to :creator, :class_name => 'User', :foreign_key => :created_by, :optional => true
  belongs_to :project, :class_name => 'Project'
  belongs_to :expert, :class_name => 'Candidate', :foreign_key => :expert_id
  belongs_to :client, :class_name => 'Candidate', :foreign_key => :client_id
  belongs_to :pm, :class_name => 'User', :foreign_key => :pm_id

  has_many :costs, :class_name => 'ProjectTaskCost'

  # Validations
  validates_presence_of :started_at
  validates_inclusion_of :category, :in => CATEGORY.keys
  validates_inclusion_of :status, :in => STATUS.keys
  validates_inclusion_of :interview_form, :in => INTERVIEW_FORM.keys

  before_validation :setup, :on => [:create, :update]
  after_update :sync_payment_status
  # Scopes
  scope :interview, -> { where( category: 'interview') }

  def finished!
    ActiveRecord::Base.transaction do
      contract = active_contract
      self.status = 'finished'
      self.charge_status = contract.payment_way == 'advance_payment' ? 'paid' : 'unbilled'  # 预付合同直接已收费
      self.save!

      project_candidate = ProjectCandidate.where(project_id: project_id, candidate_id: expert_id).first
      project_candidate.update!(mark: 'interviewed') if project_candidate  # 自动更新专家项目中标识为已访谈
    end
  end

  def can_cancel?
    %w[ongoing].include? status
  end

  def can_return_back?
    %w[unbilled].include? charge_status
  end

  # 当前执行中的合同(最新), 用于获取价格计算规则
  def active_contract
    project.active_contract
  end

  # 收费小时(用于财务表格导出)
  def charge_hour
    (charge_duration / 60.0).round(2)
  end

  def set_charge_timestamp
    case charge_status
      when 'billed' then
        self.billed_at = Time.now
        self.charge_deadline = billed_at + charge_days.to_i.days
      when 'paid'   then
        self.charged_at = Time.now
      else nil
    end
  end

  def expert_cost_friendly
    cost = costs.expert.first
    cost ? cost.price : nil
  end

  private
  def setup
    self.status         ||= 'ongoing'   # init
    self.charge_status  ||= 'unbilled'  # init
    self.payment_status ||= 'unpaid'    # init

    if charge_duration.present?
      contract = active_contract
      self.charge_days    = contract.payment_days                                            # 账期(天数)
      self.ended_at       = started_at + duration.to_i * 60                                  # 结束时间 = 开始时间 + 时长
      self.charge_rate    = contract.charge_rate                                             # 收费倍率
      self.base_price     = contract.base_price(charge_duration.to_i) * expert_rate.to_d     # 基础收费(根据收费时长)
      self.actual_price ||= base_price                                                       # 实际收费
      self.currency       = contract.currency                                                # 货币
      self.is_taxed       = contract.is_taxed                                                # 是否含税
      self.tax            = is_taxed ? 0 : actual_price * contract.tax_rate                  # 税费 = 实际收费 * 税率
    end
    self.shorthand_price ||= 0                                                               # 速记费用
    self.total_price    = actual_price.to_f + tax.to_f + shorthand_price.to_f                # 总费用
  end

  def sync_payment_status
    costs.map{|cost| cost.update(payment_status: self.payment_status) }
  end
end
