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

  has_many :project_candidates, :class_name => 'ProjectCandidate'
  has_many :projects, :class_name => 'Project', :through => :project_candidates
  has_many :project_tasks, :class_name => 'ProjectTask'
  has_many :candidate_access_logs, :class_name => 'CandidateAccessLog'

  # Validations
  validates_inclusion_of :category, :in => CATEGORY.keys
  validates_inclusion_of :data_source, :in => DATA_SOURCE.keys
  validates_inclusion_of :gender, :in => GENDER.keys, :allow_nil => true
  validates_inclusion_of :currency, :in => CURRENCY.keys, :allow_nil => true
  validates_presence_of :name, :first_name
  validates_presence_of :cpt

  # Hooks
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

  def latest_work_experience
    experiences.work.order(:started_at => :desc).first
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
