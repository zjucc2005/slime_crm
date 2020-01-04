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
  validates_inclusion_of :category, :in => CATEGORY.keys
  validates_inclusion_of :status, :in => STATUS.keys

  before_validation :setup, :on => [:create, :update]
  # Scopes
  scope :interview, -> { where( category: 'interview') }


  private
  def setup
    self.status ||= 'ongoing'
    self.cpt    ||= self.candidate.cpt
    self.duration = ((ended_at - started_at) / 60.0).to_i
    self.fee      = cpt * (duration / 60.0).ceil
  end
end
