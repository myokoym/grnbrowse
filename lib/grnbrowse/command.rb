# class Grnbrowse::Command
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

require "thor"
require "launchy"
require "grnbrowse/version"
require "grnbrowse/groonga_database"
require "grnbrowse/groonga_searcher"
require "grnbrowse/web"

module Grnbrowse
  class Command < Thor
    map "-v" => :version

    attr_reader :database_dir

    def initialize(*args)
      super
      default_base_dir = File.join(File.expand_path("~"), ".grnbrowse")
      @base_dir = ENV["AOZORASEARCH_HOME"] || default_base_dir
      @database_dir = File.join(@base_dir, "db")
    end

    desc "version", "Show version number."
    def version
      puts Grnbrowse::VERSION
    end

    desc "start", "Start web server."
    option :silent, type: :boolean, desc: "Don't open in browser"
    def start(path, table_name, title_column, content_column)
      ENV["path"] = path
      ENV["table_name"] = table_name
      ENV["title_column"] = title_column
      ENV["content_column"] = content_column
      web_server_thread = Thread.new { Grnbrowse::Web::App.run! }
      Launchy.open("http://localhost:4567") unless options[:silent]
      web_server_thread.join
    end
  end
end
