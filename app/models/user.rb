# encoding: utf-8
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :validatable

  # Associations
  has_many :candidates, :class_name => 'Candidate', :foreign_key => :created_by
  has_many :companies, :class_name => 'Company', :foreign_key => :created_by
  has_many :contracts, :class_name => 'Contract', :foreign_key => :created_by
  has_many :projects, :class_name => 'Project', :foreign_key => :created_by

  # validations
  validates_inclusion_of :role, :in => %w[su admin consultant]
  validates_presence_of :name_cn


  ROLES = { :admin => '管理员', :consultant => '顾问' }.stringify_keys
  STATUS = { :active => '在职', :inactive => '离职' }.stringify_keys


end
