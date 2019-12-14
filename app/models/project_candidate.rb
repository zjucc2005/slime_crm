# encoding: utf-8
class ProjectCandidate < ApplicationRecord

  # ENUM
  CATEGORY = {
      :client => '客户联系人'
  }.stringify_keys

  # Associations

  # Validations
  validates_inclusion_of :category, :in => CATEGORY.keys

  # Hooks
  before_validation :setup, :on => :create

  # Scopes
  scope :client, -> { where(category: 'client') }

  private
  def setup
    self.category ||= 'client'
  end

end
