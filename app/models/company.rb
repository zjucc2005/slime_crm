# encoding: utf-8
class Company < ApplicationRecord
  # ENUM
  CATEGORY = { :normal => '普通', :client => '客户公司' }.stringify_keys

  # Associations
  belongs_to :owner, :class_name => 'User', :optional => true
  has_many :contracts, :class_name => 'Contract', :dependent => :destroy

  # Validations
  validates_inclusion_of :category, :in => CATEGORY.keys

  # Hooks
  before_validation :setup, :on => :create

  def is_client?
    category == 'client'
  end

  private
  def setup
    self.category ||= 'normal'
  end

end
