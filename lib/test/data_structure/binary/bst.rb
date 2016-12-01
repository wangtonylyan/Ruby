# coding: utf-8
# -*- coding: utf-8 -*-

require_relative '../tree'
require_relative '../../../data_structure/tree/binary/bst'

module Algo
  module DataStructure
    class BinarySearchTree
      public

      def check(size)
        raise "#{_size(@root)} != #{size}" unless _size(@root) == size
      end

      protected

      def _check_root_(tree, left = 0, right = 0)
        return 0 if tree.nil?
        # check symmetric order property
        raise "#{tree} | #{tree.left}" unless tree.left.nil? || tree.left.key < tree.key
        raise "#{tree} | #{tree.right}" unless tree.right.nil? || tree.right.key > tree.key
        left + right + 1 # size
      end

      def _check_tree_(tree)
        unless tree.nil?
          # check size consistency
          left = _check_tree_(tree.left)
          right = _check_tree_(tree.right)
          raise "#{_size(tree)} != #{left + right + 1}" unless _size(tree) == left + right + 1
        end
        _check_root_(tree, left, right)
      end
    end

    class BinarySearchTreeTest < TreeTest
    end
  end
end

class Algo::DataStructure::BinarySearchTreeTest
  def initialize(cls: Algo::DataStructure::BinarySearchTree, num: 1000, check: false, **argv)
    raise "#{cls.class} | #{cls.inspect}" unless cls.is_a?(Class) && cls <= Algo::DataStructure::BinarySearchTree
    raise "#{argv.class} | #{argv.inspect}" unless argv.is_a?(Hash)
    raise "#{num.class} | #{num.inspect}" unless num.is_a?(Integer) && num > 0
    raise "#{check.class} | #{check.inspect}" unless check.instance_of?(TrueClass) || check.instance_of?(FalseClass)

    super(cls: cls, argv: argv, num: num)
    apply_check_method(check)
  end

  protected

  def apply_check_method(check)
    _check_ = check ? :_check_tree_ : :_check_root_
    raise "#{@cls.class} | #{@cls.inspect} | #{@cls.instance_methods}" unless @cls.instance_methods.include?(_check_)
    @cls.instance_eval do
      raise "#{self.class} | #{inspect} | #{instance_methods}" unless instance_methods.include?(:_call_)
      undef_method :_call_
      define_method :_call_ do |func, tree, *args, **argv|
        send(func, tree, *args, **argv) do |tree, _dir|
          send(_check_, tree)
        end
      end
      protected :_call_
    end
    raise "#{@cls.class} | #{@cls.inspect} | #{@cls.instance_methods}" unless
        @cls.instance_methods.include?(:_call_)
  end
end

if __FILE__ == $PROGRAM_NAME
  include Algo::DataStructure
  BinarySearchTreeTest.new.main
  puts "done: #{__FILE__}"
end
