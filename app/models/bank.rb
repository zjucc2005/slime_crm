# encoding: utf-8
class Bank < ApplicationRecord
  validates_presence_of :name
  validates_uniqueness_of :name

  before_validation :setup, :on => [:create, :update]

  private
  def setup
    self.name = name.strip
  end
end
