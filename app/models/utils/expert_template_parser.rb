# encoding: utf-8
module Utils
  class ExpertTemplateParser
    # 解析专家导入模板

    attr_accessor :errors, :row, :created_by, :candidate_attr, :work_exp_attrs

    def initialize(row, created_by=nil, user_channel_id=nil)
      @row = row.map(&method(:cell_strip))
      @errors = []
      @created_by = created_by
      @user_channel_id = user_channel_id
      @candidate_attr = {}
      @work_exp_attrs = []
      set_candidate_attr
      set_work_exp_attrs
    end

    # 返回值 true/false
    def import
      if valid?
        # import code
        begin
          ActiveRecord::Base.transaction do
            candidate = Candidate.expert.create!(@candidate_attr)
            @work_exp_attrs.each do |exp_attr|
              candidate.experiences.work.create!(exp_attr)
            end
          end
          true  # return
        rescue Exception => e
          @errors << e.message
          false # return
        end
      else
        false # return
      end
    end

    # 返回值 true/false
    def valid?
      @errors.empty?
    end

    private
    def cell_strip(cell)
      String === cell ? cell.strip : cell
    end

    def set_candidate_attr
      name          = @row[0].to_s
      nickname      = @row[1]
      gender        = case @row[2] when '男' then 'male' when '女' then 'female' else nil end
      date_of_birth = row[3].to_time rescue nil
      phone         = @row[4]
      phone1        = @row[5]
      city          = @row[6]
      industry      = @row[7]
      email         = @row[8]
      email1        = @row[9]
      wechat        = @row[10]
      is_available  = case @row[11] when '是' then true when '否' then false else nil end
      cpt           = @row[12].to_f
      currency      = case @row[13].to_s.upcase when 'USD' then 'USD' else 'RMB' end
      description   = @row[14]

      # validates_presence_of - name, phone, city, industry, email
      @errors << '姓名不能为空' if name.blank?
      if phone.blank?
        @errors << '电话不能为空'
      elsif Candidate.expert.exists?(phone: phone) || Candidate.expert.exists?(phone1: phone)
        @errors << '电话已被使用'
      end
      @errors << '城市不能为空' if city.blank?
      @errors << '行业不能为空' if industry.blank?
      @errors << '邮箱不能为空' if email.blank?

      first_name, last_name = Candidate.name_split(name)
      @candidate_attr = {
        data_source: 'excel', data_channel: 'excel', created_by: @created_by, user_channel_id: @user_channel_id,
        first_name: first_name, last_name: last_name, nickname: nickname, gender: gender, date_of_birth: date_of_birth,
        phone: phone, phone1: phone1, city: city, industry: industry, email: email, email1: email1,
        wechat: wechat, is_available: is_available, cpt: cpt, currency: currency, description: description
      }
    end

    def set_work_exp_attrs
      [16, 23].each do |i|
        started_at  = @row[i].to_time rescue nil
        ended_at    = @row[i + 1].to_time rescue nil
        org_cn      = @row[i + 2]
        org_en      = @row[i + 3]
        title       = @row[i + 4]
        description = @row[i + 5]
        if started_at.present? && org_cn.present?
          @work_exp_attrs << { started_at: started_at, ended_at: ended_at, org_cn: org_cn, org_en: org_en,
                               title: title, description: description }
        end
      end
    end

  end
end