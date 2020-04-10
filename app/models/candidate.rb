# encoding: utf-8
class Candidate < ApplicationRecord

  # ENUM
  CATEGORY = { :expert => '专家', :client => '客户' }.stringify_keys
  DATA_SOURCE = { :manual => '手工录入', :excel => 'Excel导入', :plugin => '插件采集' }.stringify_keys
  GENDER = { :male => '男', :female => '女' }.stringify_keys

  # Associations
  belongs_to :creator, :class_name => 'User', :foreign_key => :created_by
  belongs_to :company, :class_name => 'Company', :optional => true
  has_many :experiences, :class_name => 'CandidateExperience', :dependent => :destroy
  has_many :payment_infos, :class_name => 'CandidatePaymentInfo', :dependent => :destroy
  has_many :comments, :class_name => 'CandidateComment', :dependent => :destroy

  has_many :project_candidates, :class_name => 'ProjectCandidate'
  has_many :projects, :class_name => 'Project', :through => :project_candidates
  has_many :project_tasks, :class_name => 'ProjectTask', :foreign_key => :expert_id
  has_many :candidate_access_logs, :class_name => 'CandidateAccessLog'

  # Validations
  validates_inclusion_of :category, :in => CATEGORY.keys
  validates_inclusion_of :data_source, :in => DATA_SOURCE.keys
  validates_inclusion_of :gender, :in => GENDER.keys, :allow_nil => true
  validates_inclusion_of :currency, :in => CURRENCY.keys, :allow_nil => true
  validates_presence_of :name, :first_name
  validates_presence_of :cpt

  before_validation :setup, :on => [:create, :update]

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
  %w[wechat].each do |k|
    define_method(:"#{k}"){ self.property[k] }
    define_method(:"#{k}="){ |v| self.property[k] = v }
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

  def latest_work_experience
    experiences.work.order(:started_at => :desc).first
  end

  def normal_project_task_count
    project_tasks.where(status: %w[ongoing finished]).count
  end

  # new expert has at most 1 task
  def new_expert?
    project_tasks.where(status: 'finished').count <= 1
  end

  # card template params setting
  def card_template_params(field)
    case field.to_sym
      when :uid         then self.uid
      when :name        then self.name
      when :city        then self.city
      when :phone       then self.phone
      when :description then self.description
      when :company     then self.latest_work_experience.try(:org_cn)
      when :title       then self.latest_work_experience.try(:title)
      else nil
    end
  end

  private
  def setup
    self.category    ||= 'expert'  # init category
    self.data_source ||= 'manual'  # init data_source
    self.first_name    = first_name.try(:strip)
    self.last_name     = last_name.try(:strip)
    self.name          = "#{last_name}#{first_name}"
  end

end
