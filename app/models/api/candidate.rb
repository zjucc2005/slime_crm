# encoding: utf-8
class Api::Candidate
  class << self

    # 创建专家接口逻辑
    # Api::Candidate.create_expert(params)
    # 返回值 - { status: true/false, msg: 'xxx' }
    def create_expert(params, created_by=nil, user_channel_id=nil)
      begin
        # validate and construct params
        %w[last_name city phone email industry expert_rate currency work_experience].each do |field|
          raise "#{field} 不能为空" if params[field].blank?
        end
        date_of_birth = params['date_of_birth'].to_time rescue nil
        cpt           = params['expert_rate'].to_f
        currency      = case params['currency'].to_s.upcase when 'USD' then 'USD' else 'RMB' end
        phone         = params['phone'].to_s.gsub(/[^\d]/, '')
        raise 'phone 已被使用' if Candidate.expert.exists?(phone: phone) || Candidate.expert.exists?(phone1: phone)

        @candidate_attr = {
          data_source: 'plugin', data_channel: 'plugin', created_by: created_by, user_channel_id: user_channel_id,
          first_name: params['first_name'], last_name: params['last_name'], nickname: params['nickname'], gender: params['gender'],
          date_of_birth: date_of_birth, phone: phone, email: params['email'], wechat: params['wechat'],
          industry: params['industry'], description: params['description'], is_available: params['is_available'], cpt: cpt,
          currency: currency
        }
        @work_exp_attrs = []
        params['work_experience'].each_with_index do |exp_params, index|
          started_at  = exp_params['start'].to_time rescue nil
          ended_at    = exp_params['end'].to_time rescue nil
          org_cn      = exp_params['company']
          org_en      = exp_params['company_en']
          title       = exp_params['title']
          description = exp_params['description']
          raise "work_experience[#{index}].start 不能为空" if started_at.blank?
          raise "work_experience[#{index}].company 不能为空" if org_cn.blank?
          @work_exp_attrs << { started_at: started_at, ended_at: ended_at, org_cn: org_cn, org_en: org_en,
                              title: title, description: description }
        end

        # execute creation
        ActiveRecord::Base.transaction do
          candidate = Candidate.expert.create!(@candidate_attr)
          @work_exp_attrs.each do |exp_attr|
            candidate.experiences.work.create!(exp_attr)
          end
        end
        { status: true, msg: '创建成功' }
      rescue Exception => e
        { status: false, msg: e.message }
      end
    end
  end
end