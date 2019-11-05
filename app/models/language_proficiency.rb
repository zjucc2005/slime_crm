# encoding: utf-8
class LanguageProficiency < ApplicationRecord
  # Associations
  belongs_to :candidate, :class_name => 'Candidate'

  # Validations
  validates_presence_of :language, :level

  LEVELS = {
    :simple => '简易',
    :normal => '普通',
    :fluent => '流利',
    :mothertongue => '母语'
  }.stringify_keys
end
