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
    @root = _call_(method(:_insert), @root, key, value, up: method(:_balance))
    @root.color = false if @root.color
  end

  def delete(key)
    if @root
      @root.color = true unless (@root.left && @root.left.color) || (@root.right && @root.right.color)
      @root = _call_(method(:_delete), @root, key,
                     down: ->(tree) do
                       case key <=> tree.key
                       when -1 then _make_left_red(tree)
                       when 1 then _make_right_red(tree)
                       else tree
                       end
                     end,
                     up: method(:_balance))
      @root.color = false if @root && @root.color
    end
  end

  def del_max
    if @root
      @root.color = true unless (@root.left && @root.left.color) || (@root.right && @root.right.color)
      @root = _call_(method(:_del_max), @root, down: method(:_make_right_red), up: method(:_balance))
      @root.color = false if @root && @root.color
    end
  end

  def del_min
    if @root
      @root.color = true unless (@root.left && @root.left.color) || (@root.right && @root.right.color)
      @root = _call_(method(:_del_min), @root, down: method(:_make_left_red), up: method(:_balance))
      @root.color = false if @root && @root.color
    end
  end

  protected

  def _delete(tree, key, down: nil, up: nil, &blk)
    _find_(method(:_find_recursive_), tree, key,
           find_which: ->(tree, key) { key <=> tree.key },
           find_it:    ->(tree, _) do
             if tree.left.nil?
               tree.right.color = tree.color if tree.right
               tree = tree.right
             elsif tree.right.nil?
               tree.left.color = tree.color if tree.left
               tree = tree.left
             else
               tree = _make_right_red(tree)
               if key != tree.key
                 tree = _delete(tree, key, down: down, up: up, &blk)
               else
                 m = _min(tree.right)
                 tree.key = m.key
                 tree.value = m.value
                 tree.right = _del_min(tree.right, down: down, up: up, &blk)
               end
             end
             tree
           end,
           find_nil:   ->(_, _) { nil },
           find_down: down, find_up: up, &blk)
  end

  def _del_max(tree, down: nil, up: nil, &blk)
    _find_(method(:_find_recursive_), tree,
           find_which: ->(tree) { tree.right.nil? ? 0 : 1 },
           find_it:    ->(tree) do
             tree.left.color = tree.color if tree.left
             tree.left
           end,
           find_nil:   ->(tree) { raise "#{tree.class} | #{tree}" },
           find_down: down, find_up: up, &blk)
  end

  def _del_min(tree, down: nil, up: nil, &blk)
    _find_(method(:_find_recursive_), tree,
           find_which: ->(tree) { tree.left.nil? ? 0 : -1 },
           find_it:    ->(tree) do
             tree.right.color = tree.color if tree.right
             tree.right
           end,
           find_nil:   ->(tree) { raise "#{tree.class} | #{tree}" },
           find_down: down, find_up: up, &blk)
  end

  protected

  def _rotate_left(tree)
    unless tree.nil? || tree.right.nil?
      tree = _rotate_left_(tree)
      tree.color, tree.left.color = tree.left.color, tree.color
    end
    tree
  end

  def _rotate_right(tree)
    unless tree.nil? || tree.left.nil?
      tree = _rotate_right_(tree)
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
      raise "#{tree} | #{tree.left}" if tree.right.nil? # black-height invariant
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

  def _make_right_red(tree)
    unless tree.nil? || tree.right.nil?
      raise "#{tree} | #{tree.left} | #{tree.right}" unless
          tree.color || (tree.left && tree.left.color) || tree.right.color
      return tree if tree.right.color || (tree.right.left && tree.right.left.color) ||
                     (tree.right.right && tree.right.right.color)
      raise "#{tree} | #{tree.right}" if tree.left.nil?
      if tree.color
        tree = _flip_color(tree)
        tree.left = _rotate_left(tree.left) if tree.left.right && tree.left.right.color
        if tree.left.left && tree.left.left.color
          tree = _rotate_right(tree)
          tree = _flip_color(tree)
        end
      else
        raise "#{tree} | #{tree.left} | #{tree.right}" unless tree.left.color
        tree = _rotate_right(tree)
      end
      raise "#{tree} | #{tree.left} | #{tree.right}" unless tree.right.color ||
                                                            (tree.right.left && tree.right.left.color) ||
                                                            (tree.right.right && tree.right.right.color)
    end
    tree
  end
end
