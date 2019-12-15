# encoding: utf-8
class Contract < ApplicationRecord

  # Associations
  belongs_to :creator, :class_name => 'User', :foreign_key => :created_by, :optional => true
  belongs_to :company, :class_name => 'Company'

  # Validations
  validates_presence_of :file, :started_at, :ended_at

  mount_uploader :file, FileUploader

  # Hooks
  before_validation :setup, :on => :create

  # Scopes
  scope :available, -> { where('started_at <= :now AND ended_at >= :now', { :now => Time.now }) }

  private
  def setup
    self.started_at ||= Time.now
  end

end
