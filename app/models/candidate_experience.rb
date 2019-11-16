# encoding: utf-8
class CandidateExperience < ApplicationRecord
  CATEGORIES = %w[work project education]

  # Associations
  belongs_to :candidate, :class_name => 'Candidate'

  # Validations
  validates_inclusion_of :category, :in => CATEGORIES
  validates_presence_of :started_at, :org_cn
end
