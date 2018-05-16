# frozen_string_literal: true

require_relative '../../command'
require_relative '../../modules/connection'
require 'tty-table'

module Lkr
  module Commands
    class Connection
      class Dialects < Lkr::Command
        include Lkr::Connection
        def initialize(options)
          super()
          @options = options
        end

        def execute(input: $stdin, output: $stdout)
          say_warning(@options) if @options[:debug]
          with_session do
            data = query_all_dialects(@options[:fields])
            begin
              say_ok "No dialects found"
              return nil
            end unless data && data.length > 0

            table_hash = Hash.new
            table_hash[:header] = data[0].to_attrs.keys unless @options[:plain]
            table_hash[:rows] = data.map do |row|
              row.to_attrs.values
            end
            table = TTY::Table.new(table_hash)
            alignments = data[0].to_attrs.keys.map do |k|
              (k =~ /id$/) ? :right : :left
            end
            output.puts table.render(if @options[:plain] then :basic else :ascii end, alignments: alignments) if table
          end
        end
      end
    end
  end
end