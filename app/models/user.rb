# encoding: utf-8
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :validatable, :trackable

  # Associations
  has_many :candidates, :class_name => 'Candidate', :foreign_key => :created_by
  has_many :companies, :class_name => 'Company', :foreign_key => :created_by
  has_many :contracts, :class_name => 'Contract', :foreign_key => :created_by
  has_many :projects, :class_name => 'Project', :foreign_key => :created_by

  # validations
  validates_inclusion_of :role, :in => %w[su admin pm pa finance]
  validates_inclusion_of :status, :in => %w[active inactive]
  validates_presence_of :name_cn

  # Hooks
  before_validation :setup, :on => [:create, :update]

  # Scopes
  scope :active,   -> { where(status: 'active') }
  scope :inactive, -> { where(status: 'inactive') }
  scope :admin,    -> { where(role: 'admin') }
  scope :pm,       -> { where(role: 'pm') }
  scope :pa,       -> { where(role: 'pa') }
  scope :finance,  -> { where(role: 'finance') }


  ROLES = { :admin => '管理员', :pm => '项目经理', :pa => '项目助理', :finance => '财务' }.stringify_keys
  STATUS = { :active => '激活', :inactive => '未激活' }.stringify_keys

  def admin?
    role == 'admin'
  end

  def is_available_role?
    %w[pm pa finance].include?(role)  # admin role is unique
  end

  private
  def setup
    self.status ||= 'inactive'
    self.confirmed_at = (status == 'active' ? Time.now : nil)
  end
end
