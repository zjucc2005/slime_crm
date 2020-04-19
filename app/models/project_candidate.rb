# encoding: utf-8
class ProjectCandidate < ApplicationRecord
  # ENUM
  CATEGORY = { :expert => '专家', :client => '客户' }.stringify_keys
  MARK = {
    :decline     => '拒绝',
    :unsuitable  => '不合适',
    :recommended => '已推荐',
    :interviewed => '已访谈',
    :contacting  => '联络中',
    :pending     => '待定'
  }.stringify_keys

  # Associations
  belongs_to :project, :class_name => 'Project'
  belongs_to :candidate, :class_name => 'Candidate'

  # Validations
  validates_inclusion_of :category, :in => CATEGORY.keys
  before_validation :setup, :on => :create

  # Scopes
  scope :expert, -> { where(category: 'expert') }
  scope :client, -> { where(category: 'client') }

  private
  def setup
    self.category ||= 'client'
    self.mark     ||= 'pending'
  end

end
