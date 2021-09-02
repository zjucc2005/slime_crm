# encoding: utf-8
class Candidate < ApplicationRecord

  # ENUM
  CATEGORY = { :expert => '专家', :client => '客户' }.stringify_keys
  DATA_SOURCE = { :manual => '手工录入', :excel => 'Excel导入', :plugin => '插件采集', :api => 'API创建' }.stringify_keys
  GENDER = { :male => '男', :female => '女' }.stringify_keys
  DATA_CHANNEL = {
    :linkedin  => 'Linkedin',
    :liepin    => '猎聘',
    :search    => '搜索（谷歌，百度等）',
    :social    => '社交（微博，脉脉）',
    :recommend => '专家推荐',
    :contact   => '通讯录',
    :gllue     => '谷露导入',
    :excel     => '批量导入',
    :plugin    => '插件采集'
  }.stringify_keys

  # Associations
  belongs_to :creator, :class_name => 'User', :foreign_key => :created_by, :optional => true
  belongs_to :user_channel, :class_name => 'UserChannel', :optional => true
  belongs_to :recommender, :class_name => 'Candidate', :foreign_key => :recommender_id, :optional => true
  belongs_to :company, :class_name => 'Company', :optional => true
  has_many :experiences, :class_name => 'CandidateExperience', :dependent => :destroy
  has_many :payment_infos, :class_name => 'CandidatePaymentInfo', :dependent => :destroy
  has_many :comments, :class_name => 'CandidateComment', :dependent => :destroy

  has_many :project_candidates, :class_name => 'ProjectCandidate', :dependent => :destroy
  has_many :projects, :class_name => 'Project', :through => :project_candidates
  has_many :project_tasks, :class_name => 'ProjectTask', :foreign_key => :expert_id
  has_many :candidate_access_logs, :class_name => 'CandidateAccessLog'
  has_many :recommended_experts, :class_name => 'Candidate', :foreign_key => :recommender_id

  # Validations
  validates_inclusion_of :category, :in => CATEGORY.keys
  validates_inclusion_of :data_source, :in => DATA_SOURCE.keys
  validates_inclusion_of :gender, :in => GENDER.keys, :allow_nil => true
  validates_inclusion_of :currency, :in => CURRENCY.keys, :allow_nil => true
  validates_presence_of :name, :last_name
  validates_presence_of :cpt

  before_validation :setup, :validates_uniqueness_of_phone, :on => [:create, :update]

  # Scopes
  scope :expert, -> { where(category: 'expert') }
  scope :client, -> { where(category: 'client') }

  class << self
    def name_split(name)
      if self::FUXING.include?(name[0, 2])
        last_name = name[0, 2]
        first_name = name[2, name.length - 2]
      else
        last_name = name[0]
        first_name = name[1, name.length - 1]
      end
      [first_name, last_name]
    end
  end

  # property fields
  %w[wechat cpt_face_to_face].each do |k|
    define_method(:"#{k}"){ self.property[k] }
    define_method(:"#{k}="){ |v| self.property[k] = v }
  end

  def can_delete?
    if self.category == 'client'
      self.projects.count == 0  # 未参与项目
    elsif self.category == 'expert'
      project_tasks.count.zero? && self.recommended_experts.count == 0  # 未参与项目 & 未推荐过其他专家
    end
  end

  def validates_presence_of_experiences
    return true unless self.category == 'expert'
    if self.experiences.work.count == 0
      errors.add(:work_experiences, :blank)
      false
    else
      true
    end
  end

  # English name form - Mr./Miss sb.
  def mr_name
    _mr_   = gender == 'female' ? 'Miss' : 'Mr.'
    _name_ = last_name
    if /\p{Han}+/.match(last_name)
      _name_ = Pinyin.t(last_name).capitalize rescue last_name
    end
    "#{_mr_} #{_name_}"
  end

  # uid + name
  def uid_name
    "#{uid} #{name}"
  end

  # nickname 优先
  def if_nickname
    nickname.present? ? nickname : name
  end

  def work_experiences
    experiences.work  # 定义属性
  end

  def latest_work_experience
    experiences.work.order(:started_at => :desc).first
  end

  # new expert has at most 1 task
  def new_expert?
    project_tasks.where(status: 'finished').count <= 1
  end

  # card template params setting
  def card_template_params(field)
    case field.to_sym
      when :uid          then self.uid
      when :name         then self.name
      when :city         then self.city
      when :phone        then self.phone
      when :description  then self.description
      when :company      then self.latest_work_experience.try(:org_cn)
      when :title        then self.latest_work_experience.try(:title)
      when :expert_level then self._c_t_expert_level
      when :gj_rate      then self._c_t_gj_rate_
      else nil
    end
  end

  # for card template use
  def _c_t_expert_level
    case currency
      when 'RMB' then cpt.to_i >= 1500 ? 'Premium Expert' : 'Standard Expert'
      when 'USD' then cpt.to_i >= 200 ? 'Premium Expert' : 'Standard Expert'
      else 'Standard Expert'
    end
  end

  def _c_t_gj_rate_
    _rate_ = 0
    if currency == 'RMB'
      _rate_ = case self.cpt
        when 0 then 0
        when 0..1000 then 2800
        when 1000..1500 then 3360
        when 1500..2000 then 4200
        when 2000..2500 then 5040
        when 2500..3000 then 5600
        else 'TBD'
      end
    end
    _rate_ == 0 ? '' : "电话-#{_rate_}/小时"
  end

  private
  def setup
    self.category    ||= 'expert'  # init category
    self.data_source ||= 'manual'  # init data_source
    self.first_name    = first_name.try(:strip)
    self.last_name     = last_name.try(:strip)
    self.name          = "#{last_name}#{first_name}"
    self.phone         = phone.to_s.gsub(/[^\d]/, '')  # remove non-numeric chars
    self.phone1        = phone1.to_s.gsub(/[^\d]/, '')
    self.email         = email.strip if email
    self.email1        = email1.strip if email1
  end

  def validates_uniqueness_of_phone
    if self.category == 'expert'
      query = self.class.expert.where.not(id: self.id)
      if phone.present?
        errors.add(:phone, :taken) if query.exists?(phone: phone) || query.exists?(phone1: phone)
      end
      if phone1.present?
        errors.add(:phone1, :taken) if query.exists?(phone: phone1) || query.exists?(phone1: phone1)
      end
    elsif self.category == 'client'
      query = self.class.client.where.not(id: self.id)
      if phone.present?
        errors.add(:phone, :taken) if query.exists?(phone: phone) || query.exists?(phone1: phone)
      end
      if phone1.present?
        errors.add(:phone1, :taken) if query.exists?(phone: phone1) || query.exists?(phone1: phone1)
      end
    else
      true
    end
  end

end
