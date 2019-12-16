# encoding: utf-8
class Project < ApplicationRecord

  # Associations
  belongs_to :creator, :class_name => 'User', :foreign_key => :created_by

  # Validations

end
