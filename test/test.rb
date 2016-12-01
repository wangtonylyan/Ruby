# coding: utf-8
# -*- coding: utf-8 -*-

module Algo
  module Test
    module Time
      def self.runtime
        return 0 unless block_given?
        t = ::Time.now
        yield
        ::Time.now - t
      end
    end
  end
end
