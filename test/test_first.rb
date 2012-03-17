require File.join(File.absolute_path(File.dirname(__FILE__)),'..','app')
require 'test/unit'
require 'rack/test'

ENV['RACK_ENV'] = 'test'

class TicTacToeTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    ::TicTacToe::App
  end

  def test_it_says_hello_world
    get '/'
    assert last_response.ok?
    assert_equal 'Howdy', last_response.body
  end

  def test_creating_a_game
    game_params = {'players' => [{'id' => "bob"}, {'id' => "sally"}]}
    post '/v1/games', Yajl.dump(game_params)
    assert last_response.ok?
    data = Yajl.load(last_response.body)
    assert_equal game_params['players'], data["game"]["players"]
  end

  def test_listing_games
    game_params = {'players' => [{'id' => "mike"}, {'id' => "sally"}]}
    post '/v1/games', Yajl.dump(game_params)
    assert last_response.ok?

    get '/v1/games'
    assert last_response.ok?
    data = Yajl.load(last_response.body)
    assert data.size > 0
    assert_equal 'mike', data['games'].first['players'].first['id']
  end

  def test_showing_a_game
    game_params = {'players' => [{'id' => "fred"}, {'id' => "sally"}]}
    post '/v1/games', Yajl.dump(game_params)
    assert last_response.ok?
    id = Yajl.load(last_response.body)["game"]["id"]

    get "/v1/games/#{id}"
    assert last_response.ok?
    data = Yajl.load(last_response.body)
    assert_equal 'fred', data['game']['players'].first['id']
  end

  def test_making_a_move
    game_params = {'players' => [{'id' => "bob"}, {'id' => "sally"}]}
    post '/v1/games', Yajl.dump(game_params)
    assert last_response.ok?
    id = Yajl.load(last_response.body)["game"]["id"]

    action_params = {'player' => 'bob', 'position' => 0}
    post "/v1/games/#{id}/actions", Yajl.dump(action_params)
    assert last_response.ok?
    data = Yajl.load(last_response.body)
    assert_equal 'bob', data['action']['player']
    assert_equal 0, data['action']['position']

    get "/v1/games/#{id}/actions"
    assert last_response.ok?
    data = Yajl.load(last_response.body)['actions'].last
    assert_equal 'bob', data['player']
    assert_equal 0, data['position']
  end

  def test_making_a_duplicate_move
    game_params = {'players' => [{'id' => "bob"}, {'id' => "sally"}]}
    post '/v1/games', Yajl.dump(game_params)
    assert last_response.ok?
    id = Yajl.load(last_response.body)["game"]["id"]

    action_params = {'player' => 'bob', 'position' => 0}
    post "/v1/games/#{id}/actions", Yajl.dump(action_params)
    assert last_response.ok?

    action_params = {'player' => 'sally', 'position' => 0}
    post "/v1/games/#{id}/actions", Yajl.dump(action_params)
    assert last_response.bad_request?
    error = Yajl.load(last_response.body)['error']
    assert_equal "Bad request", error["message"]
    assert_equal 400, error["code"]
  end

  def test_moving_with_a_bad_player
    game_params = {'players' => [{'id' => "bob"}, {'id' => "sally"}]}
    post '/v1/games', Yajl.dump(game_params)
    assert last_response.ok?
    id = Yajl.load(last_response.body)["game"]["id"]

    action_params = {'player' => 'frank', 'position' => 0}
    post "/v1/games/#{id}/actions", Yajl.dump(action_params)
    assert last_response.bad_request?
    error = Yajl.load(last_response.body)['error']
    assert_equal "Bad request", error["message"]
    assert_equal 400, error["code"]
  end

  def test_moving_out_of_order
    game_params = {'players' => [{'id' => "bob"}, {'id' => "sally"}]}
    post '/v1/games', Yajl.dump(game_params)
    assert last_response.ok?
    id = Yajl.load(last_response.body)["game"]["id"]

    action_params = {'player' => 'sally', 'position' => 0}
    post "/v1/games/#{id}/actions", Yajl.dump(action_params)
    assert last_response.bad_request?
    error = Yajl.load(last_response.body)['error']
    assert_equal "Bad request", error["message"]
    assert_equal 400, error["code"]
  end

  def test_winning
    game_params = {'players' => [{'id' => "sally"}, {'id' => "bob"}]}
    post '/v1/games', Yajl.dump(game_params)
    assert last_response.ok?
    id = Yajl.load(last_response.body)["game"]["id"]

    action_params = {'player' => 'sally', 'position' => 0}
    post "/v1/games/#{id}/actions", Yajl.dump(action_params)
    assert last_response.ok?

    action_params = {'player' => 'bob', 'position' => 3}
    post "/v1/games/#{id}/actions", Yajl.dump(action_params)
    assert last_response.ok?

    action_params = {'player' => 'sally', 'position' => 1}
    post "/v1/games/#{id}/actions", Yajl.dump(action_params)
    assert last_response.ok?

    action_params = {'player' => 'bob', 'position' => 4}
    post "/v1/games/#{id}/actions", Yajl.dump(action_params)
    assert last_response.ok?

    action_params = {'player' => 'sally', 'position' => 2}
    post "/v1/games/#{id}/actions", Yajl.dump(action_params)
    assert last_response.ok?

    get "/v1/games/#{id}"
    assert last_response.ok?
    assert_equal 'sally', Yajl.load(last_response.body)["game"]["winner"]
  end

  def test_game_board
    game_params = {'players' => [{'id' => "sally"}, {'id' => "bob"}]}
    post '/v1/games', Yajl.dump(game_params)
    assert last_response.ok?
    id = Yajl.load(last_response.body)["game"]["id"]

    action_params = {'player' => 'sally', 'position' => 0}
    post "/v1/games/#{id}/actions", Yajl.dump(action_params)
    assert last_response.ok?

    action_params = {'player' => 'bob', 'position' => 3}
    post "/v1/games/#{id}/actions", Yajl.dump(action_params)
    assert last_response.ok?

    action_params = {'player' => 'sally', 'position' => 1}
    post "/v1/games/#{id}/actions", Yajl.dump(action_params)
    assert last_response.ok?

    action_params = {'player' => 'bob', 'position' => 4}
    post "/v1/games/#{id}/actions", Yajl.dump(action_params)
    assert last_response.ok?

    action_params = {'player' => 'sally', 'position' => 2}
    post "/v1/games/#{id}/actions", Yajl.dump(action_params)
    assert last_response.ok?

    get "/v1/games/#{id}"
    assert last_response.ok?
    assert_equal ["sally", "sally", "sally", "bob", "bob", nil, nil, nil, nil],
      Yajl.load(last_response.body)["game"]["board"]
  end
end
