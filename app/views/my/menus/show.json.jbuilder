json.quick_actions []

json.sections do
  json.child! do
    json.title "Boards"
    json.ios_system_image "rectangle.on.rectangle"
    json.rows @boards do |board|
      json.(board, :id, :name)
      json.url board_url(board)
    end
  end

  json.child! do
    json.title "Tags"
    json.ios_system_image "tag"
    json.rows @tags do |tag|
      json.(tag, :id, :title)
      json.url cards_url(tag_ids: [ tag ])
    end
  end

  json.child! do
    json.title "People"
    json.ios_system_image "person.2"
    json.rows @users do |user|
      json.(user, :id, :name)
      json.url user_url(user)
    end
  end

  json.child! do
    json.title "Accounts"
    json.ios_system_image "building.2"
    json.rows Current.identity.accounts do |account|
      json.(account, :id, :name, :slug)
      json.url landing_url(script_name: account.slug)
    end
  end

  json.child! do
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
  end
end
