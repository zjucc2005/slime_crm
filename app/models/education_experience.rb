# encoding: utf-8
class EducationExperience < ApplicationRecord
  # Associations
  belongs_to :candidate, :class_name => 'Candidate'

  # Validations
  validates_presence_of :started_at, :ended_at, :school, :major, :degree, :description

  DEGREES = {
    :college => '大专',
    :bachelor => '本科',
    :master => '硕士',
    :doctor => '博士',
    :postdoctoral => '博士后',
    :other => '其他'
  }.stringify_keys
end
