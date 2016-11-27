module Algo
  module Test
    class Time
      def self.runtime
        return 0 unless block_given?
        t = ::Time.now
        yield
        ::Time.now - t
      end
    end
  end
end
