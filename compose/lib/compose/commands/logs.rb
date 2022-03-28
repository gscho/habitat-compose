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
      end

      def exec
        if @follow
          File.open("../default/sup.log") do |log|
            log.extend(File::Tail)
            log.interval
            log.backward(@tail_lines) if @tail_lines
            log.tail do |line| 
              if @service_name.empty?
                print line
              elsif line =~ /#{@service_name}\./i
                print line
              end
            end
          end
        else
          File.readlines("../default/sup.log").each do |line|
            STDOUT.puts(line)
          end
        end
      end
    end
  end
end