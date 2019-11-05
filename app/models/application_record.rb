class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  require 'carrierwave/orm/activerecord'
end
