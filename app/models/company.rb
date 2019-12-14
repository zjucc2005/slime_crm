# encoding: utf-8
class Company < ApplicationRecord
  # ENUM
  CATEGORY = { :normal => '普通', :client => '客户公司' }.stringify_keys

  # Associations
  belongs_to :creator, :class_name => 'User', :foreign_key => :created_by, :optional => true
  has_many :contracts, :class_name => 'Contract', :dependent => :destroy
  has_many :clients, :class_name => 'Candidate'

  # Validations
  validates_inclusion_of :category, :in => CATEGORY.keys

  # Hooks
  before_validation :setup, :on => :create

  def is_client?
    category == 'client'
  end

  private
  def setup
    self.category ||= 'client'
  end

end
