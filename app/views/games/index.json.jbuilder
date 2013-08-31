json.array!(@games) do |game|
  json.extract! game, :user_one, :user_two
  json.url game_url(game, format: :json)
end
