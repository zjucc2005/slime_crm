# encoding: utf-8
class ProjectExperience < ApplicationRecord
  # Associations
  belongs_to :candidate, :class_name => 'Candidate'

  # Validations
  validates_presence_of :started_at, :ended_at, :name, :title, :description
end
