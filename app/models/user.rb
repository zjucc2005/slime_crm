# encoding: utf-8
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :validatable, :trackable

  # Associations
  has_many :candidates, :class_name => 'Candidate', :foreign_key => :created_by  # 创建者采用默认关联
  has_many :companies, :class_name => 'Company', :foreign_key => :created_by
  has_many :contracts, :class_name => 'Contract', :foreign_key => :created_by
  has_many :projects, :class_name => 'Project', :foreign_key => :created_by
  has_many :project_tasks, :class_name => 'ProjectTask', :foreign_key => :created_by

  has_many :project_users, :class_name => 'ProjectUser'
  has_many :in_projects, :class_name => 'Project', :through => :project_users  # 用户参与的项目
  has_many :candidate_access_logs, :class_name => 'CandidateAccessLog'

  # validations
  validates_inclusion_of :role, :in => %w[su admin pm pa finance]
  validates_inclusion_of :status, :in => %w[active inactive]
  validates_presence_of :name_cn
  validates_numericality_of :candidate_access_limit, :greater_than_or_equal_to => 0

  # Hooks
  before_validation :setup, :on => [:create, :update]

  # Scopes
  scope :active,   -> { where(status: 'active') }
  scope :inactive, -> { where(status: 'inactive') }
  scope :admin,    -> { where(role: 'admin') }
  scope :pm,       -> { where(role: 'pm') }
  scope :pa,       -> { where(role: 'pa') }
  scope :finance,  -> { where(role: 'finance') }


  ROLES = { :admin => '管理员', :pm => '项目经理', :pa => '项目助理', :finance => '财务' }.stringify_keys
  STATUS = { :active => '激活', :inactive => '未激活' }.stringify_keys

  def admin?
    role == 'admin'
  end

  def is_role?(*args)
    args.include?(role)
  end

  def is_available_role?
    %w[pm pa finance].include?(role)  # admin role is unique
  end

  def can_access_candidate?
    if admin?
      true
    else
      now = Time.now
      candidate_access_logs.where('created_at BETWEEN ? AND ?', now.beginning_of_day, now.end_of_day).count < candidate_access_limit
    end
  end

  private
  def setup
    self.status ||= 'inactive'
    self.confirmed_at = (status == 'active' ? Time.now : nil)
    self.candidate_access_limit ||= 0
  end
end
