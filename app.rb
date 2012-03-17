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

    get "/v1/games/:id/actions" do
    end

    post "/v1/games/:id/actions" do
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
