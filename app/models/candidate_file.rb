# encoding: utf-8
class CandidateFile < ApplicationRecord

  CATEGORIES = ['原始简历', '推荐报告', '背景调查', '体检报告', 'Offer Letter']

  validates_presence_of :candidate_id, :file
  validates_inclusion_of :category, :in => CATEGORIES
  mount_uploader :file, FileUploader
end
