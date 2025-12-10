json.title "People"
json.ios_system_image "person.2"
json.rows users do |user|
  json.(user, :id, :name)
  json.url user_url(user)
end
