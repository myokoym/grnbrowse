# class Grnbrowse::Web::App
#
# Copyright (C) 2016  Masafumi Yokoyama <myokoym@gmail.com>
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

require "grnbrowse"
require "sinatra/base"
require "sinatra/json"
require "sinatra/cross_origin"
require "sinatra/reloader"
require "haml"
require "padrino-helpers"
require "kaminari/sinatra"

module Grnbrowse
  module Web
    module PaginationProxy
      def limit_value
        page_size
      end

      def total_pages
        n_pages
      end
    end

    class App < Sinatra::Base
      I18n.load_path = Dir[File.join(settings.root, 'locales', '*.yml')]
      I18n.available_locales = [:ja, :en, :"ja-JP"]
      I18n.default_locale = :ja
      helpers Kaminari::Helpers::SinatraHelpers
      register Sinatra::CrossOrigin

      configure :development do
        register Sinatra::Reloader
      end

      #configure do
      #  @path = ENV["path"]
      #  @table_name = ENV["table_name"]
      #  @title_column = ENV["title_column"]
      #  @content_column = ENV["content_column"]
      #end

      get "/" do
        haml :index
      end

      get "/books/*" do
        id_or_key = params[:splat].first
        # workaround
        id_or_key.sub!(/http:\/(?!:[^\/])/, "http://")
        id_or_key.sub!(/https:\/(?!:[^\/])/, "https://")
        database = GroongaDatabase.new
        database.open
        table = Groonga[database.table_name]
        @book = table[id_or_key]
        haml :show
      end

      get "/search" do
        if params[:reset_params]
          params.reject! do |key, _value|
            key != "word"
          end
          redirect to('/search?' + params.to_param)
        end
        search_and_paginate
        haml :index
      end

      get "/search.json" do
        cross_origin
        search_and_paginate
        books = @paginated_books || @books
        json books.collect {|book| book.attributes }
      end

      helpers do
        def search_and_paginate
          if params[:word]
            words = params[:word].split(/[[:space:]]+/)
          else
            words = []
          end
          options ||= {}

          database = GroongaDatabase.new
          database.open
          searcher = GroongaSearcher.new
          @books = searcher.search(database, words, options)
          @snippet = searcher.snippet
          page = (params[:page] || 1).to_i
          size = (params[:n_per_page] || 20).to_i
          begin
            @paginated_books = @books.paginate([["_score", :desc]],
                                               page: page,
                                               size: size)
          rescue Groonga::TooLargePage
            params.delete(:page)
            @paginated_books = @books.paginate([["_score", :desc]],
                                               page: 1,
                                               size: size)
          end
          @paginated_books.extend(PaginationProxy)
          @paginated_books
        end

        def groonga_version
          Groonga::VERSION[0..2].join(".")
        end

        def rroonga_version
          Groonga::BINDINGS_VERSION.join(".")
        end

        def snippets
          snippet = Groonga::Snippet.new(width: 100,
                                         default_open_tag: "<span class=\"keyword\">",
                                         default_close_tag: "</span>",
                                         html_escape: true,
                                         normalize: true)
          words.each do |word|
            snippet.add_keyword(word)
          end

          snippet.execute(selected_books.first.content)
        end

        def page_title
          title = "Grnbrowse"
          if params[:word]
            title = "#{params[:word]} - #{title}"
          end
          title
        end
      end
    end
  end
end
