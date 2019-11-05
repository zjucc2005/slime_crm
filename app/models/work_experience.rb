# encoding: utf-8
class WorkExperience < ApplicationRecord
  # Associations
  belongs_to :candidate, :class_name => 'Candidate'

  # Validations
  validates_presence_of :started_at, :ended_at, :company, :title, :description
end
