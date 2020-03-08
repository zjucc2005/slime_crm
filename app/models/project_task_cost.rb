# encoding: utf-8
class ProjectTaskCost < ApplicationRecord
  # ENUM
  CATEGORY = {
    :expert      => '专家费用',
    :recommend   => '推荐费用',
    :translation => '翻译费用',
    :others      => '其他费用'
  }.stringify_keys

  # Associations
  belongs_to :project_task, :class_name => 'ProjectTask'
end
