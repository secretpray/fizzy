json.title "Accounts"
json.ios_system_image "building.2"
json.rows accounts do |account|
  json.(account, :id, :name, :slug)
  json.url landing_url(script_name: account.slug)
end
