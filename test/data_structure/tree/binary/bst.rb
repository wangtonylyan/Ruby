# coding: utf-8
# -*- coding: utf-8 -*-

require_relative '../tree'
require_relative '../../../../lib/data_structure/tree/binary/bst'

module Algo
  module DataStructure
    class BinarySearchTree
    end
    class BinarySearchTreeTest < TreeTest
    end
  end
end

module Algo::DataStructure
  class BinarySearchTree
    protected

    def check(size)
      raise "#{_length(@root)} != #{size}" unless _length(@root) == size
    end

    def check_root(tree, left = 0, right = 0)
      return 0 if tree.nil?
      # check symmetric order property
      raise "#{tree} | #{tree.left}" unless tree.left.nil? || tree.left.key < tree.key
      raise "#{tree} | #{tree.right}" unless tree.right.nil? || tree.right.key > tree.key
      left + right + 1 # size
    end

    def check_tree(tree)
      unless tree.nil?
        # check size consistency
        left = check_tree(tree.left)
        right = check_tree(tree.right)
        raise "#{_length(tree)} != #{left + right + 1}" unless _length(tree) == left + right + 1
      end
      check_root(tree, left, right)
    end

    protected

    def decorator(func, tree, *args, **argv, &blk)
      # stub
    end

    def self.decorate(*args)
      args.each do |func|
        raise "#{func.class} | #{func.inspect}" unless func.is_a?(Symbol) || func.is_a?(String)
        old_name = func.to_sym
        new_name = "_#{func}_".to_sym
        alias_method  new_name, old_name
        define_method old_name do |*args|
          method(:decorator).call(method(new_name), *args)
        end
        protected old_name, new_name
      end
    end
    decorate :_search, :_getmax, :_getmin, :_insert, :_delete, :_delmax, :_delmin
  end

  class BinarySearchTreeTest
    def initialize(cls: BinarySearchTree, num: 1000, check: false, **argv)
      raise "#{cls.class} | #{cls.inspect}" unless cls.is_a?(Class) && cls <= BinarySearchTree
      raise "#{argv.class} | #{argv.inspect}" unless argv.is_a?(Hash)
      raise "#{num.class} | #{num.inspect}" unless num.is_a?(Integer) && num > 0
      raise "#{check.class} | #{check.inspect}" unless check.instance_of?(TrueClass) || check.instance_of?(FalseClass)

      super(cls: cls, argv: argv, num: num)
      apply_check_method(check)
    end

    protected

    def apply_check_method(check)
      raise "#{@cls.class} | #{@cls.inspect} | #{@cls.instance_methods}" unless
          @cls.instance_methods.include?(:check_tree) && @cls.instance_methods.include?(:check_root) &&
          @cls.instance_methods.include?(:check)
      check_method = check ? :check_tree : :check_root
      @cls.instance_eval do
        raise "#{self.class} | #{inspect} | #{instance_methods}" unless instance_methods.include?(:decorator)
        define_method :decorator do |func, tree, *args, **argv|
          raise "#{func.class} | #{func.inspect}" unless func.is_a?(Method)
          raise if block_given?
          func.call(tree, *args, **argv) { |tree, dir| send(check_method, tree) if dir == :up }
        end
        private :decorator
      end
      raise "#{@cls.class} | #{@cls.inspect} | #{@cls.private_instance_methods}" unless
          @cls.private_instance_methods.include?(:decorator)
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  include Algo::DataStructure
  BinarySearchTreeTest.new.main
  puts "done: #{__FILE__}"
end
