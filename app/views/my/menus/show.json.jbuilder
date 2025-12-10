json.quick_actions do
  json.child! { json.partial! "my/menus/home_action" }
  json.child! { json.partial! "my/menus/assigned_to_me_action" }
  json.child! { json.partial! "my/menus/added_by_me_action" }
end

json.sections do
  json.child! { json.partial! "my/menus/boards_section", boards: @boards }
  json.child! { json.partial! "my/menus/tags_section", tags: @tags }
  json.child! { json.partial! "my/menus/people_section", users: @users }
  json.child! { json.partial! "my/menus/accounts_section", accounts: Current.identity.accounts }
  json.child! { json.partial! "my/menus/settings_section" }
end
