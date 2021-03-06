# encoding: utf-8
module Utils
  class Gllue

    VERSION = '1.0'
    # URL     = 'http://172.16.81.245'  # 局域网 IP
    URL     = Settings.gllue.url
    AES_KEY = Settings.gllue.aes_key
    AES_IV  = Settings.gllue.aes_iv
    EMAIL   = Settings.gllue.email

    DEFAULT_TIMESTAMP = '1900-01-01'  # 默认时间点, 用来代替空值

    # EXCEPT_IDS = [
    #   (159784..190159),  # 百度
    #   (190160..196072),  # 滴滴
    #   (196074..280603),  # 美团
    #   (403785..404751),  # 阿里
    #   (413668..628893)   # JD
    # ]
    IMPORTING_IDS = [
      1..159783,
      280604..403784,
      404752..413667,
      628894..9999999
    ]

    def initialize(g_data={}, created_by=nil, user_channel_id=nil)
      @g_data = g_data
      @created_by = created_by
      @user_channel_id = user_channel_id
    end

    def time_parse(str='2020-01')
      str.to_s.match(/^\d{4}-\d{2}/) ? Time.local(*str.split('-')) : nil
    end

    def clear_string(str)
      return nil if str.blank?
      str.gsub("\u0000", '')  # DEBUG: ArgumentError(string contains null byte)
    end

    def save
      return false if self.class.existed?(@g_data['id'])
      return false if @g_data['chineseName'].blank? && @g_data['englishName'].blank?
      # 数据对应存储逻辑, 涉及多个表, 事务处理
      ActiveRecord::Base.transaction do
        first_name, last_name = Candidate.name_split(@g_data['chineseName'].to_s.strip)
        last_name = @g_data['englishName'] if last_name.blank?  # 没有中文名的, 赋值英文名
        gender = case @g_data['gender']
                   when true  then 'male'
                   when false then 'female'
                   else nil
                 end
        cpt_match = @g_data['zhuanjiafeilv'].to_s.match(/\d+/)
        cpt = cpt_match ? cpt_match[0].to_i : 0
        if @g_data['gllueextinterview_willingness'].is_a?(Hash)
          is_available = case @g_data['gllueextinterview_willingness']['value']
                           when '是' then true
                           when '否' then false
                           else nil
                         end
        else
          is_available = nil  # 数据结构不符的, 默认为 待定
        end

        email_arr = []
        %w[email email1 email2].each do |field|
          email_arr << @g_data[field] if @g_data[field].present?
        end
        phone_arr = []
        %w[mobile mobile1 mobile2].each do |field|
          phone_arr << @g_data[field] if @g_data[field].present?
        end

        candidate = Candidate.expert.create!(
          data_source:   'api',
          data_channel:  'gllue',
          created_by:    @created_by,
          user_channel_id: @user_channel_id,
          first_name:    first_name,
          last_name:     last_name,
          nickname:      @g_data['englishName'],
          email:         email_arr[0],
          email1:        email_arr[1],
          phone:         phone_arr[0],
          phone1:        phone_arr[1],
          date_of_birth: @g_data['dateOfBirth'],
          gender:        gender,
          description:   @g_data['gllueextbkdetail'],
          is_available:  is_available,
          cpt:           cpt,
          currency:      'RMB',
          property:      { gllue_id: @g_data['id'] }
        )
        (@g_data['candidateexperience_set'] || []).each do |exp|
          candidate.experiences.work.create!(
            started_at:  time_parse(exp['start']) || DEFAULT_TIMESTAMP,
            ended_at:    time_parse(exp['end']),
            org_cn:      exp['client']['name'],
            title:       exp['title'],
            description: clear_string(exp['description'])
          )
        end
        (@g_data['candidateeducation_set'] || []).each do |exp|
          candidate.experiences.education.create!(
            started_at: time_parse(exp['start']) || DEFAULT_TIMESTAMP,
            ended_at:   time_parse(exp['end']),
            org_cn:     exp['school']
          ) if exp['start'].present? && exp['school'].present?
        end
        puts "-- create candidate succeeded, gllue_id: #{@g_data['id']}" unless Rails.env.production?
      end

      true  # return
    end

    class << self
      def version
        VERSION
      end

      # import candidate info from gllue system
      def import
        # find out max gllue_id imported
        max_gllue_id = Candidate.maximum("CAST(property->>'gllue_id' AS INTEGER)") || 0

        IMPORTING_IDS.each do |range|
          # calculate importing range
          if max_gllue_id < range.max
            import_range = [max_gllue_id + 1, range.min].max..range.max
          else
            next
          end
          import_by_range(import_range)
        end
      end

      def import_by_range(range=0..0, created_by=nil, user_channel_id=nil)
        # slice range per 1000
        limit = 1000
        range.step(limit).each do |i|
          _range_ = i..[i + limit - 1, range.max].min

          res = candidate_list(id_ge: _range_.min, id_le: _range_.max, per_page: limit)
          if res['list'].length == 0
            puts 'task finished'
            break
          end
          res['list'].sort_by{|gd| gd['id']}.each do |g_data|
            self.new(g_data, created_by, user_channel_id).save rescue nil
          end if res['list'].present?
          puts "#{Time.now} -- imported gllue_id range: #{_range_}"
        end
      end

      def existed?(gllue_id)
        Candidate.where("CAST(property->>'gllue_id' AS INTEGER) = ?", gllue_id).count > 0
      end

      # main method, options.keys => [page, per_page, id_ge, id_le]
      def candidate_list(options={})
        params = Array.new
        demand_keys = %w[zhuanjiafeilv
                         candidateexperience_set__start candidateexperience_set__end candidateexperience_set__description
                         candidateeducation_set__start candidateeducation_set__end candidateeducation_set__school].to_json
        gql = []
        gql << "id__gte=#{options[:id_ge]}" if options[:id_ge]
        gql << "id__lte=#{options[:id_le]}" if options[:id_le]
        gql << "#{options[:id_in].map{|id| "id=#{id}" }.join('|')}" if options[:id_in]

        params << "private_token=#{private_token}"
        params << "page=#{options[:page]}"
        params << "paginate_by=#{options[:per_page]}"
        params << "demandKeys=#{demand_keys}"
        params << "gql=#{CGI.escape(gql.join('&'))}"
        url = "#{URL}/rest/candidate/list?#{params.join('&')}"
        response = Api.get(url)
        if response.code == '200'
          res = JSON.parse response.body
          if res['status'] == false
            raise res['message']
          else
            res
          end
        else
          raise "http code: #{response.code}"
        end
      end

      # 最大有效时长5分钟
      def private_token
        timestamp = (Time.now.to_f * 1000).to_i
        text = "#{timestamp},#{EMAIL},"
        encrypt(text)
      end

      def encrypt(text)
        CGI.escape(Base64.strict_encode64(aes_encrypt(text)))
      end

      def decrypt(text)
        aes_decrypt(Base64.decode64(CGI.unescape(text)))
      end

      # AES-128-CBC 加密
      def aes_encrypt(text, key=AES_KEY, iv=AES_IV)
        cipher = OpenSSL::Cipher::AES.new(128, :CBC)
        cipher.encrypt
        cipher.key = key
        cipher.iv  = iv
        cipher.update(pad_text(text)) + cipher.final
      end

      # AES-128-CBC 解密
      def aes_decrypt(text, key=AES_KEY, iv=AES_IV)
        cipher = OpenSSL::Cipher::AES.new(128, :CBC)
        cipher.decrypt
        cipher.key = key
        cipher.iv  = iv
        cipher.update(text)
      end

      def pad_text(text, length=16)
        "#{text}#{' ' * (length - text.length % length)}"
      end

      # 刷邮箱3用临时脚本
      def update_email2
        limit = 1000
        range = 62200..158980  # gllue ids

        range.step(limit).each do |i|
          _range_ = i..[i + limit - 1, range.max].min

          res = candidate_list(id_ge: _range_.min, id_le: _range_.max, per_page: limit)
          res['list'].each do |g_data|
            candidate = Candidate.where("CAST(property->>'gllue_id' AS INTEGER) = ?", g_data['id']).first
            if candidate
              email_arr = []
              %w[email email1 email2].each do |field|
                email_arr << g_data[field] if g_data[field].present?
              end
              candidate.email = email_arr[0]
              candidate.email1 = email_arr[1]
              candidate.save!
            end
          end

          puts "#{Time.now} -- updated email: #{_range_}"
        end
      end
    end

  end
end