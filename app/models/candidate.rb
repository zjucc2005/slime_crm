# encoding: utf-8
class Candidate < ApplicationRecord

  GENDER = { :male => '男', :female => '女' }.stringify_keys

  # Associations
  belongs_to :owner, :class_name => 'User'
  has_many :experiences, :class_name => 'CandidateExperience', :dependent => :destroy

  # Validations
  validates_inclusion_of :category, :in => %w[expert customer]
  validates_inclusion_of :data_source, :in => %w[manual excel plugin]
  validates_inclusion_of :gender, :in => GENDER.keys, :allow_nil => true
  validates_presence_of :name_cn, :city, :email, :phone
  validates_presence_of :is_available, :cpt

  # Hooks
  before_validation :setup, :on => :create


  private
  def setup
    self.category ||= 'expert'     # init category
    self.data_source ||= 'manual'  # init data_source
  end

end
