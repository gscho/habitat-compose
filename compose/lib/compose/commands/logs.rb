# frozen_string_literal: true

module Compose
  module Commands
    class Logs
      def initialize(opts = {})
        @service_name = opts["service_name"]
        @follow = opts["follow"]
        @tail_lines = if opts["tail"].downcase.eql?("all")
                        nil
                      else
                        opts["tail"].to_i
                      end
        @log_file = opts["log_file"]
      end

      def exec
        @follow ? follow_log : dump_log
      end

      def follow_log
        File.open(@log_file) do |log|
          log.extend(File::Tail)
          log.interval
          log.backward(@tail_lines) if @tail_lines
          log.tail do |line|
            print_log_line(line)
          end
        end
      end

      def dump_log
        File.readlines(@log_file).each do |line|
          print_log_line(line)
        end
      end

      def print_log_line(line)
        print line if @service_name.empty? || line =~ /#{@service_name}\./i
      end
    end
  end
end
