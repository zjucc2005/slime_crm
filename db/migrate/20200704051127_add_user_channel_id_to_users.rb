class AddUserChannelIdToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :user_channel_id, :bigint
    add_index  :users, :user_channel_id

    add_column :candidates, :user_channel_id, :bigint
    add_index  :candidates, :user_channel_id
    add_column :companies, :user_channel_id, :bigint
    add_index  :companies, :user_channel_id
    add_column :card_templates, :user_channel_id, :bigint
    add_index  :card_templates, :user_channel_id

    add_column :projects, :user_channel_id, :bigint
    add_index  :projects, :user_channel_id
    add_column :project_tasks, :user_channel_id, :bigint
    add_index  :project_tasks, :user_channel_id
    add_column :project_task_costs, :user_channel_id, :bigint
    add_index  :project_task_costs, :user_channel_id
  end
end
