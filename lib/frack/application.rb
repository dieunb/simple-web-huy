module Frack 
  class Application
    class << self 
      attr_accessor :env

      def call(env)
      end
    end
  end
end