module AccessesHelper
  def access_menu_tag(bucket, &)
    tag.menu class: [ "flex flex-column gap margin-none pad txt-medium", { "toggler--toggled": bucket.all_access? } ], data: {
      controller: "filter toggle-class",
      filter_active_class: "filter--active", filter_selected_class: "selected",
      toggle_class_toggle_class: "toggler--toggled" }, &
  end

  def access_toggles_for(users, selected:)
    render partial: "buckets/access_toggle",
      collection: users, as: :user,
      locals: { selected: selected },
      cached: ->(user) { [ user, selected ] }
  end
end
