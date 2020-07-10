# encoding: utf-8
class UserChannel < ApplicationRecord
  has_many :users, :class_name => 'User'

  validates_presence_of :name
  validates_uniqueness_of :name
end
