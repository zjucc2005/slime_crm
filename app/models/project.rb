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
  has_many :project_candidates, :class_name => 'ProjectCandidate', :dependent => :destroy
  has_many :candidates, :class_name => 'Candidate', :through => :project_candidates
  has_many :project_users, :class_name => 'ProjectUser', :dependent => :destroy
  has_many :users, :class_name => 'User', :through => :project_users
  has_many :project_requirements, :class_name => 'ProjectRequirement'
  has_many :project_tasks, :class_name => 'ProjectTask'

  # Validations
  validates_presence_of :name
  validates_inclusion_of :status, :in => STATUS.keys

  before_validation :setup, :on => :create

  # has_many :clients / :experts 作为 has_many :candidates 的补充, 依据 project_candidates.category
  # 和 candidates.client / candidates.expert 有区别, 只读
  def clients
    Candidate.joins(:project_candidates).where(
        :'project_candidates.project_id' => self.id,
        :'project_candidates.category'   => 'client').order(:'project_candidates.created_at' => :asc)
  end

  def experts
    Candidate.joins(:project_candidates).where(
        :'project_candidates.project_id' => self.id,
        :'project_candidates.category'   => 'expert').order(:'project_candidates.created_at' => :asc)
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
    project_tasks.where.not(status: 'cancelled').count == 0  # 只能删除没有任务的项目
  end

  def can_start?
    %w[initialized].include?(status)
  end

  def can_close?
    %w[ongoing].include?(status)
  end

  def can_reopen?
    %w[finished].include?(status)
  end

  def can_add_requirement?
    %w[ongoing].include?(status)
  end
  alias :can_add_task? :can_add_requirement?

  def can_add_pm_user?
    pm_users.count == 0
  end

  def can_add_pa_user?
    true
  end

  def can_delete_user?(user, operator)
    if self.created_by == user.id
      operator.admin?                   # 创建者PM只能被ADMIN移除
    else
      operator.is_role?('admin', 'pm')  # PM/PA可以被ADMIN/PM移除
    end
  end

  def can_be_operated_by(user)
    if user.admin?
      true
    else
      self.project_users.where(user_id: user.id).count > 0
    end
  end

  def start!
    self.status = 'ongoing'
    self.started_at ||= Time.now
    self.save!
  end

  def close!
    self.status = 'finished'
    self.ended_at ||= Time.now
    self.save!
  end

  def reopen!
    self.status = 'ongoing'
    self.ended_at = nil
    self.save!
  end

  def active_contract
    company.contracts.available.order(:started_at => :desc).first
  end

  def total_project_tasks
    project_tasks.where(status: 'finished').count
  end

  def total_duration
    (project_tasks.where(status: 'finished').sum(:duration) / 60.0).round(1)
  end

  def total_charge_duration
    (project_tasks.where(status: 'finished').sum(:charge_duration) / 60.0).round(1)
  end

  def project_option_friendly
    "#{company.name_abbr} - #{code} - #{name}"
  end

  def last_update
    if self.update(updated_at: Time.now)

    else
      Rails.logger.info "CC TEST: #{self.errors.full_messages}"
      raise
    end
  end

  private
  def setup
    self.status ||= 'initialized'
  end

end
