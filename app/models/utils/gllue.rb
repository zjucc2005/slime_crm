# encoding: utf-8
module Utils
  class Gllue

    VERSION = '1.0'
    # URL     = 'http://172.16.81.245'  # 局域网 IP
    URL     = 'http://116.62.206.67'
    AES_KEY = 'e36258956d57846e'
    AES_IV  = '0' * 16
    EMAIL   = 'eric.ling@atkins-associates.com'

    class << self
      def version
        VERSION
      end

      # main method
      def candidate_list(options={})
        page     = options[:page]
        per_page = options[:per_page]
        url = "#{URL}/rest/candidate/list?private_token=#{private_token}&paginate_by=#{per_page}&page=#{page}"
        Api.get(url)
      end

      # 最大有效时长5分钟, 本地缓存1分钟重新获取
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