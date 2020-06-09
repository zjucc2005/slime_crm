# encoding: utf-8
class ProjectUser < ApplicationRecord
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

  after_save do
    project.last_update
  end

  after_destroy do
    project.last_update
  end

  # Scopes
  scope :pm, -> { where(category: 'pm') }
  scope :pa, -> { where(category: 'pa') }

end
