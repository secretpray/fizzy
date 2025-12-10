json.title "Boards"
json.ios_system_image "rectangle.on.rectangle"
json.rows boards do |board|
  json.(board, :id, :name)
  json.url board_url(board)
end
