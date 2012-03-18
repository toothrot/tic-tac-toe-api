require "rubygems"
require "sinatra"
$LOAD_PATH.push('lib')
require "tic-tac-toe"

module TicTacToe
  class App < Sinatra::Base
    enable :logging
    disable :show_exceptions
    set :dump_errors, true

    get "/" do
      markdown(:README)
    end

    get "/v1/games" do
      data = {:games => Game.find_all(params)}
      render_api_response(data)
    end

    get "/v1/games/:id" do
      game = Game.find(params[:id])
      if game
        render_api_response({:game => game})
      else
        render_api_error(404, "Could not find the game id \"#{params[:id]}\"")
      end
    end

    post "/v1/games" do
      game = Game.create(json_params)
      if game.errors.empty?
        data = {:game => game}
        render_api_response(data)
      else
        render_api_error(400, game.errors.full_messages.to_sentence)
      end
    end

    get "/v1/games/:game_id/actions" do
      data = {:actions => Action.find_all_by_game_id(params[:game_id])}
      render_api_response(data)
    end

    post "/v1/games/:game_id/actions" do
      create_params = json_params.merge("game_id" => params[:game_id])
      action = Action.create(create_params)
      if action.errors.empty?
        data = {:action => action}
        render_api_response(data)
      else
        render_api_error(400, action.errors.full_messages.to_sentence)
      end
    end

    error do
      render_api_error(500, env['sinatra.error'].inspect)
    end

    def render_api_error(code = 400, message = nil)
      status code
      render_api_response({
          :error => {
            :message => message || "An error has occurred",
            :code => code
          }
        })
    end

    def json_params
      Yajl.load(request.body)
    end

    def render_api_response(data)
      output_hash = 
        case data
        when Array
          data.map(&:to_hash)
        else
          data.to_hash
        end
      content_type "application/json"
      Yajl::Encoder.encode(output_hash)
    end
  end
end
