# coding: utf-8
# -*- coding: utf-8 -*-

require_relative 'bst'

module Algo
  module DataStructure
    class RedBlackTree < SelfBalancingBinarySearchTree
      class Node < SelfBalancingBinarySearchTree::Node
      end
    end
  end
end

class Algo::DataStructure::RedBlackTree::Node
  attr_accessor :color

  def initialize(key, value, left = nil, right = nil, color = true)
    super(key, value, left, right)
    @color = color
  end

  def to_s
    super + ", #{@color}"
  end
end

class Algo::DataStructure::RedBlackTree
  def initialize
    super(find_up: ->(tree) { _balance_(tree) })
  end

  public

  def insert(key, value)
    @root = _insert(@root, key, value)
    @root.color = false if @root.color
  end

  protected

  private

  def _rotate_left_(tree)
    unless tree.nil? && tree.right.nil?
      tree = super(tree)
      tree.color, tree.left.color = tree.left.color, tree.color
    end
    tree
  end

  def _rotate_right_(tree)
    unless tree.nil? || tree.left.nil?
      tree = super(tree)
      tree.color, tree.right.color = tree.right.color, tree.color
    end
    tree
  end

  def _flip_color_(tree)
    unless tree.nil? || tree.left.nil? || tree.right.nil?
      tree.color = !tree.color
      tree.left.color = !tree.left.color
      tree.right.color = !tree.right.color
    end
    tree
  end

  def _balance_(tree)
    if tree.left && tree.left.color
      tree.left = _rotate_left_(tree.left) if tree.left.right && tree.left.right.color
      tree = _rotate_right_(tree) if tree.left.left && tree.left.left.color
    elsif tree.right && tree.right.color
      tree.right = _rotate_right_(tree.right) if tree.right.left && tree.right.left.color
      tree = _rotate_left_(tree) if tree.right.right && tree.right.right.color
    end
    tree = _flip_color_(tree) if tree.left && tree.left.color && tree.right && tree.right.color
    tree
  end
end

if __FILE__ == $PROGRAM_NAME
  require_relative '../../test/data_structure/tree'
  include Algo::Test::DataStructure
  include Algo::DataStructure
  TestTree.new(RedBlackTree).main(:insert)
  puts "done: #{__FILE__}"
end
