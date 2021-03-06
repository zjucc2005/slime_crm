# encoding: utf-8
class LocationDatum < ApplicationRecord

  # Associations
  belongs_to :parent, :class_name => self.name, :optional => true
  has_many :children, :class_name => self.name, :foreign_key => :parent_id

  # Validations
  validates_presence_of :name, :level

  # LEVEL
  # 0 - country
  # 1 - province
  # 2 - city
  # 3 - district

  # Scopes
  scope :countries, -> { where(level: 0) }
  scope :provinces, -> { where(level: 1) }
  scope :cities,    -> { where(level: 2) }
  scope :districts, -> { where(level: 3) }

  DIRECT_CODE = %w[11 12 31 50 81 82]  # 直辖市/港澳

  class << self
    ##
    # import china location data
    def data_seed
      return nil if self.count > 0  # skip if data exists

      self.transaction do
        china     = self.countries.create!(name: '中国', code: 'cn')
        file_path = 'db/import/location_data.json'
        json      = JSON.parse File.open(file_path).read
        json.each do |code, name|
          province_code = code[0,2]
          city_code     = code[2,2]
          district_code = code[4,2]

          if city_code == '00'
            province = china.children.provinces.create!(name: name, code: code)
            if %w[11 12 31 50 81 82].include?(province_code)
              province.children.cities.create!(name: name, code: code)      # 直辖市/港澳特殊处理
            end
          elsif city_code == '90'
            province = self.provinces.where(code: "#{province_code}0000").first
            province.children.cities.create!(name: name, code: code)        # 省辖市特殊处理
          elsif district_code == '00'
            province = self.provinces.where(code: "#{province_code}0000").first
            province.children.cities.create!(name: name, code: code)
          else
            if %w[11 12 31 50 81 82].include?(province_code)
              city = self.cities.where(code: "#{province_code}0000").first  # 直辖市/港澳特殊处理
            else
              city = self.cities.where(code: "#{province_code}#{city_code}00").first
            end
            city.children.districts.create!(name: name, code: code)
          end
        end
      end
    end

    # mobile location api
    def mobile_location(num)
      url = "https://sp0.baidu.com/8aQDcjqpAAV3otqbppnN2DJv/api.php?resource_name=guishudi&query=#{num}"
      res = Utils::Api.get(url)
      if res.code == '200'
        data = JSON.parse Encoding::Converter.new('gbk','utf-8').convert(res.body)
        if data['data'].present?
          type = data['data'][0]['type']
          city = "#{data['data'][0]['prov']}#{data['data'][0]['city']}"
          [city, type]
        else
          []
        end
      else
        []
      end
    end
  end

end
