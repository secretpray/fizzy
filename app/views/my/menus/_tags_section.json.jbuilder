json.title "Tags"
json.ios_system_image "tag"
json.rows tags do |tag|
  json.(tag, :id, :title)
  json.url cards_url(tag_ids: [ tag ])
end
