# encoding: utf-8
class Project < ApplicationRecord
  # ENUM
  STATUS = {
      :new       => '新项目',
      :ongoing   => '进展中',
      :finished  => '已结束',
      :cancelled => '已取消'
  }.stringify_keys

  # Associations
  belongs_to :creator, :class_name => 'User', :foreign_key => :created_by

  # Validations
  validates_presence_of :name, :code
  validates_uniqueness_of :code, :case_sensitive => false
  validates_inclusion_of :status, :in => STATUS.keys


end
