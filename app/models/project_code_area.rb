# frozen_string_literal: true

class ProjectCodeArea < ApplicationRecord
  validates_presence_of :name
  validates_uniqueness_of :name
  before_validation :setup, on: [:create, :update]

  private

  def setup
    self.name = name.try(:strip)
  end
end