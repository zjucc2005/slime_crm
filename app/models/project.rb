# encoding: utf-8
class Project < ApplicationRecord
  # ENUM
  STATUS = {
      :initialized => '新项目',
      :ongoing     => '进展中',
      :finished    => '已结束',
      :cancelled   => '已取消'
  }.stringify_keys

  # Associations
  belongs_to :creator, :class_name => 'User', :foreign_key => :created_by
  belongs_to :company, :class_name => 'Company'
  has_many :project_candidates, :class_name => 'ProjectCandidate'
  has_many :candidates, :class_name => 'Candidate', :through => :project_candidates
  has_many :project_users, :class_name => 'ProjectUser'
  has_many :users, :class_name => 'User', :through => :project_users
  has_many :project_tasks, :class_name => 'ProjectTask'

  # Validations
  validates_presence_of :name, :code
  validates_uniqueness_of :code, :case_sensitive => false
  validates_inclusion_of :status, :in => STATUS.keys

  before_validation :setup, :on => :create

  # has_many :clients / :experts 作为 has_many :candidates 的补充, 依据 project_candidates.category
  # 和 candidates.client / candidates.expert 有区别, 只读
  def clients
    Candidate.joins(:project_candidates).where(
        :'project_candidates.project_id' => self.id,
        :'project_candidates.category'   => 'client')
  end

  def experts
    Candidate.joins(:project_candidates).where(
        :'project_candidates.project_id' => self.id,
        :'project_candidates.category'   => 'expert')
  end

  # has_many :pm_users / :pa_users 作为 has_many :users 的补充, 依据 project_users.category
  # 和 users.pm / users.pa 有区别， 只读
  def pm_users
    User.joins(:project_users).where(
        :'project_users.project_id' => self.id,
        :'project_users.category' => 'pm')
  end

  def pa_users
    User.joins(:project_users).where(
        :'project_users.project_id' => self.id,
        :'project_users.category'   => 'pa')
  end

  def can_edit?
    %w[initialized ongoing].include?(status)
  end

  def can_destroy?
    true
  end

  private
  def setup
    self.status ||= 'initialized'
  end

end
