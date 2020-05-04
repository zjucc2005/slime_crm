# encoding: utf-8
module Utils
  class Gllue

    VERSION = '1.0'
    # URL     = 'http://172.16.81.245'  # 局域网 IP
    URL     = 'http://116.62.206.67'
    AES_KEY = 'e36258956d57846e'
    AES_IV  = '0' * 16
    EMAIL   = 'eric.ling@atkins-associates.com'

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
      628894..999999
    ]

    def initialize(g_data={})
      @g_data = g_data
    end

    def time_parse(str='2020-01')
      str.to_s.match(/^\d{4}-\d{2}/) ? Time.local(*str.split('-')) : nil
    end

    def save
      return false if self.class.existed?(@g_data['id'])
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

        candidate = Candidate.expert.create!(
          data_source:   'api',
          first_name:    first_name,
          last_name:     last_name,
          nickname:      @g_data['englishName'],
          email:         @g_data['email'],
          email1:        @g_data['email1'],
          phone:         @g_data['mobile'],
          phone1:        @g_data['mobile1'],
          date_of_birth: @g_data['dateOfBirth'],
          gender:        gender,
          description:   @g_data['gllueextbkdetail'],
          is_available:  @g_data['gllueextinterview_willingness'],
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
            description: exp['description']
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

      def import_by_range(range=0..0)
        # slice range per 100
        limit = 100
        range.step(limit).each do |i|
          _range_ = i..[i + limit - 1, range.max].min

          res = candidate_list(id_ge: _range_.min, id_le: _range_.max, per_page: limit)
          res['list'].sort_by{|gd| gd['id']}.each do |g_data|
            self.new(g_data).save
          end if res['list'].present?
          puts "imported gllue_id range: #{_range_}"
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
        gql = "id__gte=#{options[:id_ge]}&id__lte=#{options[:id_le]}"

        params << "private_token=#{private_token}"
        params << "page=#{options[:page]}"
        params << "paginate_by=#{options[:per_page]}"
        params << "demandKeys=#{demand_keys}"
        params << "gql=#{CGI.escape(gql)}"
        url = "#{URL}/rest/candidate/list?#{params.join('&')}"
        res = Api.get(url)
        if res.code == '200'
          JSON.parse res.body
        else
          raise "http code: #{res.code}"
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
    end

  end
end