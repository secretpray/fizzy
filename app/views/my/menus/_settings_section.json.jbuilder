json.title "Settings"
json.ios_system_image "gearshape"
json.rows do
  json.child! do
    json.id "account_settings"
    json.name "Account Settings"
    json.ios_system_image "gearshape"
    json.url account_settings_url
  end
  json.child! do
    json.id "my_profile"
    json.name "My Profile"
    json.ios_system_image "person.circle"
    json.url user_url(Current.user)
  end
  json.child! do
    json.id "notifications"
    json.name "All Notifications"
    json.ios_system_image "bell"
    json.url notifications_url
  end
  json.child! do
    json.id "notification_settings"
    json.name "Notification Settings"
    json.ios_system_image "bell.badge"
    json.url notifications_settings_url
  end
  json.child! do
    json.id "sign_out"
    json.name "Sign Out"
    json.ios_system_image "rectangle.portrait.and.arrow.right"
    json.url session_url(script_name: nil)
  end
end
