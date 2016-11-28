# coding: utf-8
# -*- coding: utf-8 -*-

require_relative 'tree'

module Algo
  module DataStructure
    class BinarySearchTree < Tree
      class Node < Tree::Node
      end
    end
    class SelfAdjustingBinarySearchTree < BinarySearchTree
    end
    class SelfBalancingBinarySearchTree < SelfAdjustingBinarySearchTree
    end
  end
end

class Algo::DataStructure::BinarySearchTree::Node
  attr_accessor :left, :right

  def initialize(key, value, left = nil, right = nil)
    super(key, value)
    @left = left
    @right = right
  end
end

class Algo::DataStructure::BinarySearchTree
  def initialize(find_up: nil, find_down: nil)
    raise "#{find_up.class} | #{find_up.inspect}" unless find_up.nil? || find_up.is_a?(Proc)
    raise "#{find_down.class} | #{find_down.inspect}" unless find_down.nil? || find_down.is_a?(Proc)
    super()
    @find_up = find_up if find_up
    @find_down = find_down if find_down
  end

  public

  def size
    _size(@root)
  end
  alias_method :length, :size

  def key(key)
    tree = _key(@root, key) and tree.value
  end
  alias_method :search, :key

  def max
    tree = _max(@root) and [tree.key, tree.value]
  end

  def min
    tree = _min(@root) and [tree.key, tree.value]
  end

  def insert(key, value)
    @root = _insert(@root, key, value)
  end

  def delete(key)
    @root = _delete(@root, key) if @root
  end

  def del_max
    @root = _del_max(@root) if @root
  end

  def del_min
    @root = _del_min(@root) if @root
  end

  protected

  def _size(tree)
    tree.nil? ? 0 : _size(tree.left) + _size(tree.right) + 1
  end

  def _key(tree, key, &blk)
    _find_iterative_(tree, ->(tree) { key < tree.key ? tree.left : tree.right },
                     ->(tree) { tree.key.equal?(key) }, &blk)
  end

  def _max(tree, &blk)
    _find_iterative_(tree, ->(tree) { tree.right }, ->(tree) { tree.right.nil? }, &blk)
  end

  def _min(tree, &blk)
    _find_iterative_(tree, ->(tree) { tree.left }, ->(tree) { tree.left.nil? }, &blk)
  end

  def _insert(tree, key, value, &blk)
    _find_recursive_(tree, key, value,
                     ->(tree, key, _) { key <=> tree.key },
                     ->(tree, _, value) { Node.new(tree.key, value, tree.left, tree.right) },
                     ->(_, key, value) { Node.new(key, value) }, &blk)
  end

  def _delete(tree, key, &blk)
    _find_recursive_(tree, key,
                     ->(tree, key) { key <=> tree.key },
                     ->(tree, _) do
                       return tree.right if tree.left.nil?
                       return tree.left if tree.right.nil?
                       m = _max(tree.left)
                       tree.key = m.key
                       tree.value = m.value
                       tree.left = _del_max(tree.left, &blk)
                       tree
                     end,
                     ->(_, _) { nil }, &blk)
  end

  def _del_max(tree, &blk)
    unless tree.nil?
      _find_recursive_(tree,
                       ->(tree) { tree.right.nil? ? 0 : 1 },
                       ->(tree) { tree.left },
                       ->(tree) { raise "#{tree.class} | #{tree}" }, &blk)
    end
  end

  def _del_min(tree, &blk)
    unless tree.nil?
      _find_recursive_(tree,
                       ->(tree) { tree.left.nil? ? 0 : -1 },
                       ->(tree) { tree.right },
                       ->(tree) { raise "#{tree.class} | #{tree}" }, &blk)
    end
  end

  protected

  def _find_iterative_(tree, *args, find_which, find_it)
    raise "#{tree.class} | #{tree}" unless tree.nil? || tree.class <= Node
    raise "#{find_which.class} | #{find_which.inspect}" unless find_which.is_a?(Proc)
    raise "#{find_it.class} | #{find_it.inspect}" unless find_it.is_a?(Proc)

    until tree.nil?
      @find_down.call(tree) if @find_down
      yield(tree, :down) if block_given?
      break if find_it.call(tree, *args)
      tree = find_which.call(tree, *args)
    end
    yield(tree, :up) if block_given? && tree
    @find_up.call(tree) if @find_up && tree
    tree
  end

  def _find_recursive_(tree, *args, find_which, find_it, find_nil)
    raise "#{tree.class} | #{tree}" unless tree.nil? || tree.class <= Node
    raise "#{find_which.class} | #{find_which.inspect}" unless find_which.is_a?(Proc)
    raise "#{find_it.class} | #{find_it.inspect}" unless find_it.is_a?(Proc)
    raise "#{find_nil.class} | #{find_nil.inspect}" unless find_nil.is_a?(Proc)

    if tree.nil?
      tree = find_nil.call(tree, *args)
    else
      @find_down.call(tree) if @find_down
      yield(tree, :down) if block_given?
      case find_which.call(tree, *args)
      when -1
        tree.left = _find_recursive_(tree.left, *args, find_which, find_it, find_nil)
      when 1
        tree.right = _find_recursive_(tree.right, *args, find_which, find_it, find_nil)
      when 0
        tree = find_it.call(tree, *args)
      else
        raise "#{find_which.call(tree, *args)} | #{tree} | #{args}"
      end
    end
    yield(tree, :up) if block_given? && tree
    @find_up.call(tree) if @find_up && tree
    tree
  end
end

class Algo::DataStructure::SelfAdjustingBinarySearchTree
  protected

  def _rotate_left_(tree)
    right = tree.right
    tree.right = right.left
    right.left = tree
    tree = right
  end

  def _rotate_right_(tree)
    left = tree.left
    tree.left = left.right
    left.right = tree
    tree = left
  end
end

class Algo::DataStructure::SelfBalancingBinarySearchTree
  def _balance_(_tree)
    raise
  end
end

if __FILE__ == $PROGRAM_NAME
  nil
  puts "done: #{__FILE__}"
end
