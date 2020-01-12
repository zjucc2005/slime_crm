# encoding: utf-8
class CandidateAccessLog < ApplicationRecord
  # Associations
  belongs_to :user, :class_name => 'User'
  belongs_to :candidate, :class_name => 'Candidate'

  # Scopes
  scope :today, -> { where('created_at BETWEEN ? AND ?', Time.now.beginning_of_day, Time.now.end_of_day) }
end
