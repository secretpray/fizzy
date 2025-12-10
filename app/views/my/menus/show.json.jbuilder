json.quick_actions []

json.sections do
  json.child! { json.partial! "my/menus/boards_section", boards: @boards }
  json.child! { json.partial! "my/menus/tags_section", tags: @tags }
  json.child! { json.partial! "my/menus/people_section", users: @users }
  json.child! { json.partial! "my/menus/accounts_section", accounts: Current.identity.accounts }
  json.child! { json.partial! "my/menus/settings_section" }
end
