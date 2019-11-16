# encoding: utf-8
class Candidate < ApplicationRecord
  # Associations
  has_many :experiences, :class_name => 'CandidateExperience', :dependent => :destroy

  # Validations
  validates_inclusion_of :category, :in => %w[expert customer]
  validates_inclusion_of :input_method, :in => %w[manual excel plugin]
  validates_inclusion_of :gender, :in => %w[mail female], :allow_nil => true
  validates_presence_of :name_cn
  validates_presence_of :source_channel, :created_by, :owner_id

end
