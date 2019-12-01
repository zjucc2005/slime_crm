class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  require 'carrierwave/orm/activerecord'

  def uid(len=6)
    sprintf("%0#{len}d", id)
  end
end
