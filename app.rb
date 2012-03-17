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
      data = {:games => Game.find_all}
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
        status 400
      end
    end

    error do
      env['sinatra.error'].inspect
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
      Yajl::Encoder.encode(output_hash)
    end
  end
end
