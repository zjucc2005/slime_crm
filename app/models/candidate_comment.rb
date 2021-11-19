# encoding: utf-8
class CandidateComment < ApplicationRecord
  CATEGORY = { general:  '备注', feedback: '项目反馈', contact:  '联系记录' }.stringify_keys

  # Associations
  belongs_to :creator, :class_name => 'User', :foreign_key => :created_by
  belongs_to :candidate, :class_name => 'Candidate'

  # Validations
  validates_presence_of :content
  validates_inclusion_of :category, in: CATEGORY.keys, allow_blank: true
  before_validation :setup, on: :create

  scope :feedback, lambda { where(category: 'feedback') }
  scope :contact,  lambda { where(category: 'contact') }

  # set is_top to true
  def topped
    if is_top?
      instances = candidate.comments.where(category: 'general', is_top: true).where.not(id: id)
      instances.map { |instance| instance.update!(is_top: false) }
    end
  end

  def activate!
    self.update!(is_active: true)
    instances = candidate.comments.feedback.where(is_active: true).where.not(id: id)
    instances.map { |instance| instance.update!(is_active: false) }
  end

  private

  def setup
    self.category ||= 'general'
  end

end
