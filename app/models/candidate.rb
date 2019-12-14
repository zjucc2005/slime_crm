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

  # Validations
  validates_inclusion_of :category, :in => CATEGORY.keys
  validates_inclusion_of :data_source, :in => DATA_SOURCE.keys
  validates_inclusion_of :gender, :in => GENDER.keys, :allow_nil => true
  validates_presence_of :name_cn, :city, :email, :phone
  validates_presence_of :cpt

  # Hooks
  before_validation :setup, :on => :create

  def latest_work_experience
    experiences.work.order(:started_at => :desc).first
  end

  private
  def setup
    self.category ||= 'expert'     # init category
    self.data_source ||= 'manual'  # init data_source
  end

end
