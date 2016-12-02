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
  public

  def insert(key, value)
    @root = _insert(@root, key, value, up: ->(tree) { _balance(tree) })
    @root.color = false if @root.color
  end

  protected

  def _rotate_left(tree)
    unless tree.nil? && tree.right.nil?
      tree = super(tree)
      tree.color, tree.left.color = tree.left.color, tree.color
    end
    tree
  end

  def _rotate_right(tree)
    unless tree.nil? || tree.left.nil?
      tree = super(tree)
      tree.color, tree.right.color = tree.right.color, tree.color
    end
    tree
  end

  def _flip_color(tree)
    unless tree.nil? || tree.left.nil? || tree.right.nil?
      tree.color = !tree.color
      tree.left.color = !tree.left.color
      tree.right.color = !tree.right.color
    end
    tree
  end

  def _balance(tree)
    unless tree.nil?
      if tree.left && tree.left.color
        tree.left = _rotate_left(tree.left) if tree.left.right && tree.left.right.color
        tree = _rotate_right(tree) if tree.left.left && tree.left.left.color
      elsif tree.right && tree.right.color
        tree.right = _rotate_right(tree.right) if tree.right.left && tree.right.left.color
        tree = _rotate_left(tree) if tree.right.right && tree.right.right.color
      end
      tree = _flip_color(tree) if tree.left && tree.left.color && tree.right && tree.right.color
    end
    tree
  end

  def _make_left_red(tree)
    unless tree.nil? || tree.left.nil?
      raise "#{tree} | #{tree.left} | #{tree.right}" unless
          tree.color || tree.left.color || (tree.right && tree.right.color)
      return tree if tree.left.color || (tree.left.left && tree.left.left.color) ||
                     (tree.left.right && tree.left.right.color)
      raise "#{tree} | #{tree.left}" if tree.right.nil?
      if tree.color
        tree = _flip_color(tree)
        tree.right = _rotate_right(tree.right) if tree.right.left && tree.right.left.color
        if tree.right.right && tree.right.right.color
          tree = _rotate_left(tree)
          tree = _flip_color(tree)
        end
      else
        raise "#{tree} | #{tree.left} | #{tree.right}" unless tree.right.color
        tree = _rotate_left(tree)
      end
      raise "#{tree} | #{tree.left} | #{tree.right}" unless tree.left.color ||
                                                            (tree.left.left && tree.left.left.color) ||
                                                            (tree.left.right && tree.left.right.color)
    end
    tree
  end
end
