require 'pp'

module Rakwik
  module Test
    class Application
      def call(env)
        puts
        pp env
        env
      end
    end
  end
end
