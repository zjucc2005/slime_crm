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

  # 是否能访问候选人数据
  def can_access_candidate?
    admin? ? true : candidate_access_logs.today.count < candidate_access_limit
  end

  # 访问候选人记录，每日每个候选人最多一条记录
  def access_candidate(candidate)
    raise I18n.t(:not_authorized) unless can_access_candidate?
    unless candidate_access_logs.today.exists?(candidate_id: candidate.id)
      candidate_access_logs.create!(candidate_id: candidate.id)
    end
    true
  end

  private
  def setup
    self.status ||= 'inactive'
    self.confirmed_at = (status == 'active' ? Time.now : nil)
    self.candidate_access_limit ||= 0
  end
end
