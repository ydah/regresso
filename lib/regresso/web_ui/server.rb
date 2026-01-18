# frozen_string_literal: true

require "sinatra/base"
require "json"
require "time"
require "regresso/web_ui/result_store"
require "regresso/web_ui/diff_formatter"

module Regresso
  # Web UI server and helpers.
  module WebUI
    # Sinatra-based Web UI server.
    class Server < Sinatra::Base
      set :public_folder, File.join(__dir__, "public")
      set :views, File.join(__dir__, "views")
      set :result_store, ResultStore.new

      get "/" do
        erb :index
      end

      get "/api/results" do
        content_type :json
        settings.result_store.list.to_json
      end

      get "/api/results/:id" do
        content_type :json
        result = settings.result_store.find(params[:id])
        halt 404, { error: "Not found" }.to_json unless result
        result.to_json
      end

      post "/api/results" do
        content_type :json
        data = JSON.parse(request.body.read)
        id = settings.result_store.store(data)
        status 201
        { id: id, status: "created" }.to_json
      end

      delete "/api/results/:id" do
        settings.result_store.delete(params[:id])
        status 204
      end

      get "/api/results/:id/diffs" do
        content_type :json
        result = settings.result_store.find(params[:id])
        halt 404, { error: "Not found" }.to_json unless result

        diffs = Array(result["diffs"])
        if params[:type]
          diffs = diffs.select { |diff| diff["type"] == params[:type] }
        end
        if params[:path]
          diffs = diffs.select { |diff| diff["path"].to_s.include?(params[:path]) }
        end

        mode = params[:format] == "html" ? :html : :plain
        formatter = DiffFormatter.new

        {
          diffs: diffs,
          formatted: formatter.format(diffs, mode: mode)
        }.to_json
      end
    end
  end
end
