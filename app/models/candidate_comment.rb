# encoding: utf-8
class CandidateComment < ApplicationRecord
  # Associations
  belongs_to :creator, :class_name => 'User', :foreign_key => :created_by
  belongs_to :candidate, :class_name => 'Candidate'

  # Validations
  validates_presence_of :content

  # set is_top to true
  def topped
    if self.is_top?
      top_comment = self.candidate.comments.where.not(id: self.id).where(is_top: true).first
      top_comment.update!(is_top: false) if top_comment
    end
  end
end
