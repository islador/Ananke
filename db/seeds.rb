# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

200.times{Whitelist.create(name: "Jack", standing: 5, entity_type: 1, source_type: 2, source_user: 2)}

#dev login
User.create(email: "luke.isla@gmail.com", password: "goblin1swatuy", password_confirmation: "goblin1swatuy", confirmed_at: Time.now, confirmation_sent_at: Time.now-50)
