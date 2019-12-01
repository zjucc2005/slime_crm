# encoding: utf-8
class Contract < ApplicationRecord

  # Associations
  belongs_to :company, :class_name => 'Company'

end
