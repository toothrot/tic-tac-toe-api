require File.join(File.absolute_path(File.dirname(__FILE__)),'..','app')
require 'test/unit'
require 'rack/test'

ENV['RACK_ENV'] = 'test'

class HelloWorldTest < Test::Unit::TestCase
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
end
