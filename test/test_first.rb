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
    assert_equal game_params['players'], data["players"]
  end
end
