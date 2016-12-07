# coding: utf-8
# -*- coding: utf-8 -*-

require_relative 'bst'
require_relative '../../../../lib/data_structure/tree/binary/rbt'

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
        # the following assertions cover the same cases as the black-height invariant
        raise "#{tree} | #{tree.left} | #{tree.right}" if tree.left && tree.left.color && tree.right && tree.right.color
        raise "#{tree} | #{tree.left} | #{tree.right}" if tree.left.nil? && !tree.right.color
        raise "#{tree} | #{tree.left} | #{tree.right}" if tree.right.nil? && !tree.left.color
        # black-height invariant: the left and right subtree should hold the same black-height.
        raise "#{left} != #{right}" unless left == right
        # Because this check method is called after each balance operation
        # and the 'tree' node will probably be modified by the next balance,
        # the meaning of the return value is not as intuitive as it appears to be.
        # First, due to the invariant that black-height is preserved in rotation operation,
        # the black-height of 'tree' is added by at most 1 only after its color has been flipped.
        # Therefore, if a red 'tree' doesn't count into the black-height for the first time,
        # after the next balance, if its parent is flipped, considering the most complicated scenario,
        # the 'tree' and its parent must then be black resulting in the increase of
        # the black-height of the parent, which takes both of them into count.
        # Second, whenever a new leaf is inserted as its parent's only child, its black-height should be 0,
        # otherwise the black-height of the left and right subtree of its parent would be 0 and 1.
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
  BinarySearchTreeTest.new(cls: RedBlackTree).main
  puts "done: #{__FILE__}"
end
