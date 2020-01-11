# encoding: utf-8
class CandidateAccessLog < ApplicationRecord
  # Associations
  belongs_to :user, :class_name => 'User'
  belongs_to :candidate, :class_name => 'Candidate'

end
