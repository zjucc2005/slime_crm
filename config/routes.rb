# For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

Rails.application.routes.draw do
  devise_for :users

  root to: 'home#index'

  resource :api do
    post :createExpert
  end

  resources :users do
    post :admin_create,      on: :collection  # create users by admin
    get :edit_password,      on: :member
    put :edit_password,      on: :member

    get :my_account,         on: :collection
    get :edit_my_account,    on: :collection
    put :edit_my_account,    on: :collection
    get :edit_my_password,   on: :collection
    put :edit_my_password,   on: :collection
  end
  
  resources :candidates do
    put :update_is_available,  on: :member

    get :add_experience, on: :collection
    get :show_phone,     on: :member      # show candidate phone.js
    # get :card_template,  on: :collection
    get :gen_card,       on: :collection
    get :expert_template,on: :collection

    post :create_client, on: :collection
    get :edit_client,    on: :member
    put :update_client,  on: :member

    post :import_expert, on: :collection  # import experts with excel

    get :payment_infos,        on: :member
    get :new_payment_info,     on: :member
    post :create_payment_info, on: :member
    get :project_tasks,        on: :member
    get :comments,             on: :member

    get :expert_info_for_clipboard, on: :member
  end

  resources :candidate_payment_infos
  resources :candidate_comments

  resources :companies do
    get :new_contract,        on: :member
    get :new_client,          on: :member

    get :load_client_options, on: :member
  end

  resources :contracts

  resources :projects do
    get :add_users,   on: :collection   # 添加项目参与人
    put :add_users,   on: :collection
    get :add_experts, on: :collection   # 添加专家
    put :add_experts, on: :collection
    get :add_clients, on: :member       # 添加客户
    put :add_clients, on: :member
    get :add_project_task, on: :member
    put :add_project_task, on: :member
    get :add_project_requirement, on: :member
    put :add_project_requirement, on: :member

    delete :delete_user,   on: :member  # 删除项目参与人
    delete :delete_expert, on: :member  # 删除专家
    delete :delete_client, on: :member  # 删除客户

    put :start, on: :member
    put :close, on: :member
    put :reopen, on: :member

    get :experts,       on: :member
    get :project_tasks, on: :member
  end

  resources :project_requirements do
    put :finish,   on: :member
    put :unfinish, on: :member
  end

  resources :project_candidates do
    put :update_mark, on: :member
  end

  resources :project_tasks do
    get :get_base_price, on: :member  # 计算基础价格(实时)
    post :add_cost,      on: :member  # 添加支出信息
    delete :remove_cost, on: :member  # 删除支出信息

    put :cancel,         on: :member  # 取消任务
  end

  resources :finance do
    put :return_back, on: :member

    get :batch_update_charge_status,  on: :collection
    get :batch_update_payment_status, on: :collection
    get :export_finance_excel,        on: :collection
  end

  resources :location_data do
    get :autocomplete_city, on: :collection
  end
  resources :banks
  resources :industries
  resources :card_templates

  resources :statistics do
    get :current_month_count_infos,  on: :collection
    get :current_month_task_ranking, on: :collection
    get :unscheduled_projects,       on: :collection
    get :ongoing_project_tasks,      on: :collection

    get :finance_summary,            on: :collection
  end
end
