# encoding :utf-8
class ProjectRequirement < ApplicationRecord
  # ENUM
  STATUS = {
    :ongoing     => '进展中',
    :finished    => '已完成',
    :unfinished  => '未完成',
    # :cancelled   => '已取消'
  }.stringify_keys

  # Associations
  belongs_to :creator, :class_name => 'User', :foreign_key => :created_by
  belongs_to :project, :class_name => 'Project'

  # Validations
  validates_inclusion_of :status, :in => STATUS.keys

  before_validation :setup, :on => :create

  def can_edit?
    status == 'ongoing'
  end

  private
  def setup
    self.status ||= 'ongoing'
  end

end
