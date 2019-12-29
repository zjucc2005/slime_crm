# encoding: utf-8
class ProjectUser < ApplicationRecord

  # Associations
  belongs_to :in_project, :class_name => 'Project', :foreign_key => :project_id
  belongs_to :user, :class_name => 'User'

  # ENUM
  CATEGORY = {
      :pm => '项目经理',
      :pa => '项目助理'
  }.stringify_keys

  # Associations
  belongs_to :project, :class_name => 'Project'
  belongs_to :user, :class_name => 'User'

  # Validations
  validates_inclusion_of :category, :in => CATEGORY.keys

  # Scopes
  scope :pm, -> { where(category: 'pm') }
  scope :pa, -> { where(category: 'pa') }

end
