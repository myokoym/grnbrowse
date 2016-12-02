# class Grnbrowse::GroongaSearcher
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

module Grnbrowse
  class GroongaSearcher
    attr_reader :snippet

    def search(database, words, options={})
      selected_books = select_books(database, words, options)

      @snippet = Groonga::Snippet.new(width: 100,
                                      default_open_tag: "<span class=\"keyword\">",
                                      default_close_tag: "</span>",
                                      html_escape: true,
                                      normalize: true)
      words.each do |word|
        @snippet.add_keyword(word)
      end

      order = options[:reverse] ? "ascending" : "descending"
      sorted_books = selected_books.sort([{
                                            :key => "_score",
                                            :order => order,
                                          }])

      sorted_books
    end

    private
    def select_books(database, words, options)
      selected_table = database.table.select do |record|
        conditions = []
        unless words.empty?
          match_target = record.match_target do |match_record|
              (match_record.index("Terms.#{database.table_name}_#{database.title_column}") * 10) |
              (match_record.index("Terms.#{database.table_name}_#{database.content_column}"))
          end
          full_text_search = words.collect {|word|
            match_target =~ word
          }.inject(&:&)
          conditions << full_text_search
        end
        conditions
      end
      selected_table
    end
  end
end
