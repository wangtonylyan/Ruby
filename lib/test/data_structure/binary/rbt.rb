# coding: utf-8
# -*- coding: utf-8 -*-

require_relative 'bst'
require_relative '../../../data_structure/tree/binary/rbt'

module Algo
  module DataStructure
    class RedBlackTree
      public

      def check(*args)
        super(*args)
        raise "#{@root}" if @root && @root.color
      end

      protected

      def _check_root_(tree, left = 0, right = 0)
        super(tree, left, right)
        return 0 if tree.nil?
        raise "#{tree} | #{tree.left} | #{tree.right}" unless
            [tree.color ? 1 : 0,
             tree.left && tree.left.color ? 1 : 0,
             tree.right && tree.right.color ? 1 : 0].inject(0, :+) <= 1
        # 'tree' node dones't count, i.e. it's omitted, if its color is red
        # so that the left and right subtree of any nodes should hold the same black-height
        raise "#{left} != #{right}" unless left == right
        tree.color ? left : left + 1 # black-height
      end

      def _check_tree_(tree)
        unless tree.nil?
          left = _check_tree_(tree.left)
          right = _check_tree_(tree.right)
        end
        _check_root_(tree, left, right)
      end
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  include Algo::DataStructure
  BinarySearchTreeTest.new(cls: RedBlackTree).main(:insert)
  puts "done: #{__FILE__}"
end
