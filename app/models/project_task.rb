# encoding: utf-8
class ProjectTask < ApplicationRecord
  # ENUM
  CATEGORY = { :interview => '访谈' }.stringify_keys
  STATUS = { :ongoing  => '进展中', :finished => '已结束', :cancelled => '已取消'}.stringify_keys
  INTERVIEW_FORM = {
    :'face-to-face' => '面谈',
    :'call'         => '电话',
    :'video-call'   => '视频通话',
    :'email'        => '邮件',
    :'others'       => '其他'
  }.stringify_keys

  # Associations
  belongs_to :creator, :class_name => 'User', :foreign_key => :created_by, :optional => true
  belongs_to :project, :class_name => 'Project'
  belongs_to :candidate, :class_name => 'Candidate'

  # Validations
  validates_presence_of :started_at
  validates_inclusion_of :category, :in => CATEGORY.keys
  validates_inclusion_of :status, :in => STATUS.keys
  validates_inclusion_of :interview_form, :in => INTERVIEW_FORM.keys

  before_validation :setup, :on => [:create, :update]
  # Scopes
  scope :interview, -> { where( category: 'interview') }

  # 当前执行中的合同(最新), 用于获取价格计算规则
  def active_contract
    project.company.contracts.available.order(:started_at => :desc).first
  end

  private
  def setup
    self.status ||= 'ongoing'  # init
  end
end
