# encoding: utf-8
class Industry < ApplicationRecord
  validates_presence_of :name
  validates_uniqueness_of :name

  before_validation :setup, :on => [:create, :update]

  def expert_count
    Candidate.expert.where(industry: name).count
  end

  private
  def setup
    self.name = name.try(:strip)
  end
end
