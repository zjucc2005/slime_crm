# encoding: utf-8
class CandidateComment < ApplicationRecord
  # Associations
  belongs_to :creator, :class_name => 'User', :foreign_key => :created_by
  belongs_to :candidate, :class_name => 'Candidate'

  # Validations
  validates_presence_of :content
end
