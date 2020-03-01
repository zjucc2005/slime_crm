# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# import china location data
LocationDatum.data_seed

# create admin
User.create!(email: 'admin@test.com', password: '111111', role: 'admin', status: 'active',
             name_cn: '管理员', name_en: 'admin', date_of_employment: Time.now) unless User.exists?(role: 'admin')
User.create!(email: 'pm@test.com', password: '111111', role: 'pm', status: 'active',
             name_cn: '项目经理', name_en: 'pm', date_of_employment: Time.now, candidate_access_limit: 200) unless User.exists?(role: 'pm')
User.create!(email: 'pa@test.com', password: '111111', role: 'pa', status: 'active',
             name_cn: '项目助理', name_en: 'pa', date_of_employment: Time.now, candidate_access_limit: 200) unless User.exists?(role: 'pa')
User.create!(email: 'finance@test.com', password: '111111', role: 'finance', status: 'active',
             name_cn: '财务', name_en: 'finance', date_of_employment: Time.now, candidate_access_limit: 0) unless User.exists?(role: 'finance')

# create card template
CardTemplate.create!(name: '提示模板',
                     content: "[ID] {% uid %}\r\n[姓名] {% name %}\r\n[城市] {% city %}\r\n[电话] {% phone %}\r\n[背景说明] {% description %}\r\n[其他未知参数] {% unknown_words %}") unless CardTemplate.count > 0

# create banks
%w[中国工商银行 中国农业银行 中国银行 中国建设银行].each do |name|
  Bank.create!(name: name)
end
