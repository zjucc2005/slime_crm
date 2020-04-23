# encoding: utf-8
module Utils
  class Gllue

    VERSION = '1.0'
    URL     = 'http://172.16.81.245'
    AES_KEY = 'e36258956d57846e'
    EMAIL   = 'eric.ling@atkins-associates.com'

    class << self
      def version
        VERSION
      end

      # main method
      def candidate_list(page=1, per_page=10)
        url = "#{URL}/rest/candidate/list"
        params = {
          :gllue_private_token => private_token,
          :paginate_by         => per_page,
          :page                => page,
          :gql                 => '',
        }
        Api.get(url, params)
      end

      def private_token
        Rails.cache.fetch('gllue_private_token', expires_in: 1.minute) do
          URI.encode Base64.strict_encode64(aes_encrypt(plain_text))
        end
      end

      # AES-128-CBC 加密
      def aes_encrypt(text)
        cipher = OpenSSL::Cipher::AES.new(128, :CBC)
        cipher.encrypt
        cipher.key = AES_KEY
        cipher.iv  = '0' * 16  # 初始矢量 IV
        cipher.update(pad_text(text))
      end

      # 明文字串
      def plain_text
        timestamp = (Time.now.to_f * 1000).to_i
        "#{timestamp},#{EMAIL},"
      end

      def pad_text(text, length=16)
        "#{text}#{' ' * (length - text.length % length)}"
      end
    end

  end
end