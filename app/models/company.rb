# encoding: utf-8
class Company < ApplicationRecord
  # ENUM
  CATEGORY = { :normal => '普通', :client => '客户公司' }.stringify_keys

  # Associations
  belongs_to :creator, :class_name => 'User', :foreign_key => :created_by, :optional => true
  has_many :contracts, :class_name => 'Contract', :dependent => :destroy
  has_many :candidates, :class_name => 'Candidate'

  # Validations
  validates_inclusion_of :category, :in => CATEGORY.keys
  validates_presence_of :name, :name_abbr, :city
  validates_uniqueness_of :name
  validates_length_of :name, :minimum => 8

  mount_uploader :compliance_file, FileUploader

  before_validation :setup, :on => :create

  # Scopes
  scope :client, -> { where(category: 'client') }
  scope :signed, -> { joins(:contracts).where('contracts.started_at <= :now AND contracts.ended_at >= :now', { :now => Time.now }).distinct }
  scope :not_signed, -> { joins(:contracts).where('contracts.started_at > :now AND contracts.ended_at < :now', { :now => Time.now }).distinct }

  # property fields
  %w[salesman check_project_code_blank check_project_code_dup].each do |k|
    define_method(:"#{k}"){ self.property[k] }
    define_method(:"#{k}="){ |v| self.property[k] = v }
  end

  def is_client?
    category == 'client'
  end

  # if is signed an available contract
  def is_signed?
    contracts.available.count > 0
  end

  def can_destroy?
    false  # 公司删除条件待确定
  end

  private
  def setup
    self.category ||= 'client'
    self.name = self.name.try(:strip)
  end

end
