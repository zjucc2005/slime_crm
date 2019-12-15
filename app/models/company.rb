# encoding: utf-8
class Company < ApplicationRecord
  # ENUM
  CATEGORY = { :normal => '普通', :client => '客户公司' }.stringify_keys

  # Associations
  belongs_to :creator, :class_name => 'User', :foreign_key => :created_by, :optional => true
  has_many :contracts, :class_name => 'Contract', :dependent => :destroy
  has_many :seats, :class_name => 'Candidate'

  # Validations
  validates_inclusion_of :category, :in => CATEGORY.keys
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_length_of :name, :minimum => 10

  # Hooks
  before_validation :setup, :on => :create

  # Scopes
  scope :client, -> { where(category: 'client') }

  def is_client?
    category == 'client'
  end

  # if is signed an available contract
  def is_signed?
    contracts.available.count > 0
  end

  private
  def setup
    self.category ||= 'client'
    self.name = self.name.try(:strip)
  end

end
