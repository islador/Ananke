# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

#dev login
User.create(email: "luke.isla@gmail.com", password: "goblin1swatuy", password_confirmation: "goblin1swatuy", confirmed_at: Time.now, confirmation_sent_at: Time.now-50)

#Demo Share
Share.create(name: "Sadistica Alliance", owner_id: User.first.id, active: true, user_limit: 50, grade: 2)

#Associate the dev with the demo share
ShareUser.create(share_id: Share.first.id, user_id: User.first.id, user_role: 0)

#Create a few whitelists
200.times{Whitelist.create(name: "Jack", standing: 5, entity_type: 1, source_type: 2, source_share_user: User.first.id, share_id: Share.first.id)}
