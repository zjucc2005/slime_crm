# encoding: utf-8
class ProjectTask < ApplicationRecord
  # ENUM
  CATEGORY = { :interview => '访谈' }.stringify_keys
  STATUS = { :ongoing  => '进展中', :finished => '已结束'}.stringify_keys

  # Associations
  belongs_to :creator, :class_name => 'User', :foreign_key => :created_by, :optional => true
  belongs_to :project, :class_name => 'Project'
  belongs_to :candidate, :class_name => 'Candidate'

  # Validations
  validates_presence_of :started_at, :ended_at, :duration

  before_validation :setup, :on => :create

  private
  def setup
    self.category ||= 'interview'
    self.status ||= 'ongoing'
  end
end
