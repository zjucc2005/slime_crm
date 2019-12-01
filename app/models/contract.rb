# encoding: utf-8
class Contract < ApplicationRecord

  # Associations
  belongs_to :owner, :class_name => 'User', :optional => true
  belongs_to :company, :class_name => 'Company'

end
