# coding: utf-8
# -*- coding: utf-8 -*-

require_relative '../tree'

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
  def initialize(augment_down: nil, augment_up: nil)
    raise "#{augment_down.class} | #{augment_down.inspect}" unless augment_down.nil? || augment_down.is_a?(Proc)
    raise "#{augment_up.class} | #{augment_up.inspect}" unless augment_up.nil? || augment_up.is_a?(Proc)

    super()
    @augment_down = augment_down if augment_down
    @augment_up = augment_up if augment_up
  end

  public

  def size
    _size(@root)
  end
  alias_method :length, :size

  def key(key)
    tree = _call_(:_key, @root, key) and tree.value
  end
  alias_method :search, :key

  def max
    tree = _call_(:_max, @root) and [tree.key, tree.value]
  end

  def min
    tree = _call_(:_min, @root) and [tree.key, tree.value]
  end

  def insert(key, value)
    @root = _call_(:_insert, @root, key, value)
  end

  def delete(key)
    @root = _call_(:_delete, @root, key) if @root
  end

  def del_max
    @root = _call_(:_del_max, @root) if @root
  end

  def del_min
    @root = _call_(:_del_min, @root) if @root
  end

  protected

  def _size(tree)
    tree.nil? ? 0 : _size(tree.left) + _size(tree.right) + 1
  end

  def _key(tree, key, down: nil, up: nil, &blk)
    _find_(:_find_iterative_, tree,
           find_which: ->(tree) { key < tree.key ? tree.left : tree.right },
           find_it:    ->(tree) { tree.key.equal?(key) },
           find_down: down, find_up: up, &blk)
  end

  def _max(tree, down: nil, up: nil, &blk)
    _find_(:_find_iterative_, tree,
           find_which: ->(tree) { tree.right },
           find_it:    ->(tree) { tree.right.nil? },
           find_down: down, find_up: up, &blk)
  end

  def _min(tree, down: nil, up: nil, &blk)
    _find_(:_find_iterative_, tree,
           find_which: ->(tree) { tree.left },
           find_it: ->(tree) { tree.left.nil? },
           find_down: down, find_up: up, &blk)
  end

  def _insert(tree, key, value, down: nil, up: nil, &blk)
    _find_(:_find_recursive_, tree, key, value,
           find_which: ->(tree, key, _) { key <=> tree.key },
           find_it:    ->(tree, _, value) { self.class::Node.new(tree.key, value, tree.left, tree.right) },
           find_nil:   ->(_, key, value) { self.class::Node.new(key, value) },
           find_down: down, find_up: up, &blk)
  end

  def _delete(tree, key, down: nil, up: nil, &blk)
    _find_(:_find_recursive_, tree, key,
           find_which: ->(tree, key) { key <=> tree.key },
           find_it:    ->(tree, _) do
             return tree.right if tree.left.nil?
             return tree.left if tree.right.nil?
             m = _max(tree.left, &blk)
             tree.key = m.key
             tree.value = m.value
             tree.left = _del_max(tree.left, down: down, up: up, &blk)
             tree
           end,
           find_nil:   ->(_, _) { nil },
           find_down: down, find_up: up, &blk)
  end

  def _del_max(tree, down: nil, up: nil, &blk)
    _find_(:_find_recursive_, tree,
           find_which: ->(tree) { tree.right.nil? ? 0 : 1 },
           find_it:    ->(tree) { tree.left },
           find_nil:   ->(tree) { raise "#{tree.class} | #{tree}" },
           find_down: down, find_up: up, &blk)
  end

  def _del_min(tree, down: nil, up: nil, &blk)
    _find_(:_find_recursive_, tree,
           find_which: ->(tree) { tree.left.nil? ? 0 : -1 },
           find_it:    ->(tree) { tree.right },
           find_nil:   ->(tree) { raise "#{tree.class} | #{tree}" },
           find_down: down, find_up: up, &blk)
  end

  protected

  def _call_(func, tree, *args, **argv, &blk)
    raise "#{protected_methods} | #{func.class} | #{func.inspect}" unless
        func.is_a?(Symbol) && protected_methods.include?(func)

    send(func, tree, *args, **argv, &blk)
  end

  def _find_(func, tree, *args, **argv)
    raise "#{func.class} | #{func.inspect}" unless
        func.is_a?(Symbol) && [:_find_iterative_, :_find_recursive_].include?(func)

    send(func, tree, *args, **argv) do |tree, dir|
      unless tree.nil?
        send(@augment_down, tree) if @augment_down && dir == :down
        send(@augment_up, tree) if @augment_up && dir == :up
        yield(tree, dir) if block_given?
      end
    end
  end

  def _find_iterative_(tree, *args, find_which: nil, find_it: nil, find_down: nil, find_up: nil)
    raise "#{self.class::Node} | #{tree.class} | #{tree}" unless tree.nil? || tree.instance_of?(self.class::Node)
    raise "#{find_which.class} | #{find_which.inspect}" unless find_which.is_a?(Proc)
    raise "#{find_it.class} | #{find_it.inspect}" unless find_it.is_a?(Proc)
    raise "#{find_down.class} | #{find_down.inspect}" unless find_down.nil? || find_down.is_a?(Proc)
    raise "#{find_up.class} | #{find_up.inspect}" unless find_up.nil? || find_up.is_a?(Proc)

    until tree.nil?
      yield(tree, :down) if block_given?
      tree = find_down.call(tree) if find_down
      break if find_it.call(tree, *args)
      tree = find_which.call(tree, *args)
    end
    tree = find_up.call(tree) if find_up && tree
    yield(tree, :up) if block_given? && tree
    tree
  end

  def _find_recursive_(tree, *args, find_which: nil, find_it: nil, find_nil: nil, find_down: nil, find_up: nil)
    raise "#{self.class::Node} | #{tree.class} | #{tree}" unless tree.nil? || tree.instance_of?(self.class::Node)
    raise "#{find_which.class} | #{find_which.inspect}" unless find_which.is_a?(Proc)
    raise "#{find_it.class} | #{find_it.inspect}" unless find_it.is_a?(Proc)
    raise "#{find_nil.class} | #{find_nil.inspect}" unless find_nil.is_a?(Proc)
    raise "#{find_down.class} | #{find_down.inspect}" unless find_down.nil? || find_down.is_a?(Proc)
    raise "#{find_up.class} | #{find_up.inspect}" unless find_up.nil? || find_up.is_a?(Proc)

    if tree.nil?
      tree = find_nil.call(tree, *args)
    else
      yield(tree, :down) if block_given?
      tree = find_down.call(tree) if find_down
      case find_which.call(tree, *args)
      when -1
        tree.left = _find_recursive_(tree.left, *args, find_which: find_which, find_it: find_it,
                                     find_nil: find_nil, find_down: find_down, find_up: find_up)
      when 1
        tree.right = _find_recursive_(tree.right, *args, find_which: find_which, find_it: find_it,
                                      find_nil: find_nil, find_down: find_down, find_up: find_up)
      when 0
        tree = find_it.call(tree, *args)
      else
        raise "#{find_which.call(tree, *args)} | #{tree} | #{args}"
      end
    end
    tree = find_up.call(tree) if find_up && tree
    yield(tree, :up) if block_given? && tree
    tree
  end
end

class Algo::DataStructure::SelfAdjustingBinarySearchTree
  protected

  def _rotate_left(tree)
    right = tree.right
    tree.right = right.left
    right.left = tree
    right
  end

  def _rotate_right(tree)
    left = tree.left
    tree.left = left.right
    left.right = tree
    left
  end
end

class Algo::DataStructure::SelfBalancingBinarySearchTree
  protected

  def _balance
    raise
  end
end
