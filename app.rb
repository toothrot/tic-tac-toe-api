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
      "Howdy"
    end

    get "/v1/games" do
      data = {:games => Game.find_all(params)}
      render_api_response(data)
    end

    get "/v1/games/:id" do
      data = {:game => Game.find(params[:id])}
      render_api_response(data)
    end

    post "/v1/games" do
      data = {:game => Game.create(json_params)}
      render_api_response(data)
    end

    get "/v1/games/:game_id/actions" do
      data = {:actions => Action.find_all_by_game_id(params[:game_id])}
      render_api_response(data)
    end

    post "/v1/games/:game_id/actions" do
      create_params = json_params.merge("game_id" => params[:game_id])
      action = Action.create(create_params)
      if action
        data = {:action => action}
        render_api_response(data)
      else
        render_api_error(400, "Bad request")
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
