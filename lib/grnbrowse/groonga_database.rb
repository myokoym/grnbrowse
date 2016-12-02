# class Grnbrowse::GroongaDatabase
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

require "groonga"

module Grnbrowse
  class GroongaDatabase
    attr_reader :table_name
    attr_reader :title_column
    attr_reader :content_column
    def initialize
      @database = nil
    end

    def open(encoding=:utf8)
      reset_context(encoding)
      p path = ENV["path"]
      @database = Groonga::Database.open(path)
      table_name = ENV["table_name"]
      title_column = ENV["title_column"]
      content_column = ENV["content_column"]
      @path = path
      @table_name = table_name
      @title_column = title_column
      @content_column = content_column
      #populate_schema(table_name, title_column, content_column)
      if block_given?
        begin
          yield(self)
        ensure
          close unless closed?
        end
      end
    end

    def close
      @database.close
      @database = nil
    end

    def closed?
      @database.nil? or @database.closed?
    end

    def table
      @table ||= Groonga[@table_name]
    end

    def db_path
      @database.path
    end

    private
    def reset_context(encoding)
      Groonga::Context.default_options = {:encoding => encoding}
      Groonga::Context.default = nil
    end

    def populate(path)
      @database = Groonga::Database.create(:path => path)
      populate_schema
    end

    def populate_schema(table_name, title_column, content_column)
      Groonga::Schema.define do |schema|
        schema.create_table(table_name,
                            :type => :hash) do |table|
          table.short_text(title_column)
          table.text(content_column)
        end

        schema.create_table("Terms",
                            :type => :patricia_trie,
                            :normalizer => "NormalizerAuto",
                            :default_tokenizer => "TokenBigram") do |table|
          table.index("#{table_name}.#{title_column}")
          table.index("#{table_name}.#{content_column}")
        end
      end
    end
  end
end
