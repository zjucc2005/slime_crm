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
User.create!(email: 'admin@dev.com', password: '111111', role: 'admin', status: 'active',
             name_cn: '管理员', name_en: 'admin', date_of_employment: Time.now) unless User.exists?(role: 'admin')
