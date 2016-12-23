# coding: utf-8
# -*- coding: utf-8 -*-

require_relative '../tree'

module Algo
  module DataStructure
    class BinarySearchTree < Tree
      class Node < Tree::Node
      end

      def self.protected_decorator(*args)
        args.each do |func|
          raise "#{func.class} | #{func.inspect}" unless func.is_a?(Symbol) || func.is_a?(String)
          old_name = func.to_sym
          new_name = "_#{func}_".to_sym
          alias_method  new_name, old_name
          define_method old_name do |*args|
            send(:_call_, method(old_name), *args)
          end
          private old_name
          protected new_name
        end
      end

      def self.private_decorator(*args)
        args.each do |func|
          raise "#{func.class} | #{func.inspect}" unless func.is_a?(Symbol) || func.is_a?(String)
          old_name = func.to_sym
          new_name = "_#{func}_".to_sym
          alias_method  new_name, old_name
          define_method old_name do |*args|
            send(:_find_, old_name, *args)
          end
          private old_name, new_name
        end
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

  def length
    _length(@root)
  end

  def search(key)
    tree = _search(@root, key) and tree.value
  end

  def getmax
    tree = _getmax(@root) and [tree.key, tree.value]
  end

  def getmin
    tree = _getmin(@root) and [tree.key, tree.value]
  end

  def insert(key, value)
    @root = _insert(@root, key, value)
  end

  def delete(key)
    @root = _delete(@root, key) if @root
  end

  def delmax
    @root = _delmax(@root) if @root
  end

  def delmin
    @root = _delmin(@root) if @root
  end

  protected

  def _length(tree)
    tree.nil? ? 0 : _length(tree.left) + _length(tree.right) + 1
  end

  def _search(tree, key, down: nil, up: nil, &blk)
    _find_iter_(tree,
                find_which: ->(tree) { key < tree.key ? tree.left : tree.right },
                find_it:    ->(tree) { tree.key.equal?(key) },
                find_down: down, find_up: up, &blk)
  end

  def _getmax(tree, down: nil, up: nil, &blk)
    _find_iter_(tree,
                find_which: ->(tree) { tree.right },
                find_it:    ->(tree) { tree.right.nil? },
                find_down: down, find_up: up, &blk)
  end

  def _getmin(tree, down: nil, up: nil, &blk)
    _find_iter_(tree,
                find_which: ->(tree) { tree.left },
                find_it: ->(tree) { tree.left.nil? },
                find_down: down, find_up: up, &blk)
  end

  def _insert(tree, key, value, down: nil, up: nil, &blk)
    _find_recur_(tree, key, value,
                 find_which: ->(tree, key, _) { key <=> tree.key },
                 find_it:    ->(tree, _, value) { self.class::Node.new(tree.key, value, tree.left, tree.right) },
                 find_nil:   ->(_, key, value) { self.class::Node.new(key, value) },
                 find_down: down, find_up: up, &blk)
  end

  def _delete(tree, key, down: nil, up: nil, &blk)
    _find_recur_(tree, key,
                 find_which: ->(tree, key) { key <=> tree.key },
                 find_it:    ->(tree, _) do
                   return tree.right if tree.left.nil?
                   return tree.left if tree.right.nil?
                   m = _getmax(tree.left, &blk)
                   tree.key = m.key
                   tree.value = m.value
                   tree.left = _delmax(tree.left, down: down, up: up, &blk)
                   tree
                 end,
                 find_nil:   ->(_, _) { nil },
                 find_down: down, find_up: up, &blk)
  end

  def _delmax(tree, down: nil, up: nil, &blk)
    _find_recur_(tree,
                 find_which: ->(tree) { tree.right.nil? ? 0 : 1 },
                 find_it:    ->(tree) { tree.left },
                 find_nil:   ->(tree) { raise "#{tree.class} | #{tree}" },
                 find_down: down, find_up: up, &blk)
  end

  def _delmin(tree, down: nil, up: nil, &blk)
    _find_recur_(tree,
                 find_which: ->(tree) { tree.left.nil? ? 0 : -1 },
                 find_it:    ->(tree) { tree.right },
                 find_nil:   ->(tree) { raise "#{tree.class} | #{tree}" },
                 find_down: down, find_up: up, &blk)
  end

  protected_decorator :_search, :_getmax, :_getmin, :_insert, :_delete, :_delmax, :_delmin

  protected

  # a wrapper for the internal _xxx methods
  # This single entrance is reserved for the future modification by open class or inheritance.
  def _call_(func, tree, *args, **argv, &blk)
    raise "#{func.class} | #{func.inspect}" unless func.is_a?(Method)

    func.call(tree, *args, **argv, &blk)
  end

  # a wrapper for the internal _find_xxx_ methods
  # apply class-level functions as the block
  def _find_(func, tree, *args, **argv)
    raise "#{func.class} | #{func.inspect}" unless func.is_a?(Method)

    func.call(tree, *args, **argv) do |tree, dir|
      unless tree.nil?
        send(@augment_down, tree) if @augment_down && dir == :down
        send(@augment_up, tree) if @augment_up && dir == :up
        yield(tree, dir) if block_given?
      end
    end
  end

  def _find_iter_(tree, *args, find_which: nil, find_it: nil, find_down: nil, find_up: nil)
    raise "#{self.class::Node} | #{tree.class} | #{tree}" unless tree.nil? || tree.instance_of?(self.class::Node)
    raise "#{find_which.class} | #{find_which.inspect}" unless find_which.is_a?(Proc)
    raise "#{find_it.class} | #{find_it.inspect}" unless find_it.is_a?(Proc)
    raise "#{find_down.class} | #{find_down.inspect}" unless find_down.nil? || find_down.is_a?(Proc) ||
                                                             find_down.is_a?(Method)
    raise "#{find_up.class} | #{find_up.inspect}" unless find_up.nil? || find_up.is_a?(Proc) || find_up.is_a?(Method)

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

  def _find_recur_(tree, *args, find_which: nil, find_it: nil, find_nil: nil, find_down: nil, find_up: nil)
    raise "#{self.class::Node} | #{tree.class} | #{tree}" unless tree.nil? || tree.instance_of?(self.class::Node)
    raise "#{find_which.class} | #{find_which.inspect}" unless find_which.is_a?(Proc)
    raise "#{find_it.class} | #{find_it.inspect}" unless find_it.is_a?(Proc)
    raise "#{find_nil.class} | #{find_nil.inspect}" unless find_nil.is_a?(Proc)
    raise "#{find_down.class} | #{find_down.inspect}" unless find_down.nil? || find_down.is_a?(Proc) ||
                                                             find_down.is_a?(Method)
    raise "#{find_up.class} | #{find_up.inspect}" unless find_up.nil? || find_up.is_a?(Proc) || find_up.is_a?(Method)

    if tree.nil?
      tree = find_nil.call(tree, *args)
    else
      yield(tree, :down) if block_given?
      tree = find_down.call(tree) if find_down
      case find_which.call(tree, *args)
      when -1 then tree.left = _find_recur_(tree.left, *args, find_which: find_which, find_it: find_it,
                                                find_nil: find_nil, find_down: find_down, find_up: find_up)
      when 1 then tree.right = _find_recur_(tree.right, *args, find_which: find_which, find_it: find_it,
                                                find_nil: find_nil, find_down: find_down, find_up: find_up)
      when 0 then tree = find_it.call(tree, *args)
      else raise "#{find_which.call(tree, *args)} | #{tree} | #{args}"
      end
    end
    tree = find_up.call(tree) if find_up && tree
    yield(tree, :up) if block_given? && tree
    tree
  end

  private_decorator :_find_iter_, :_find_recur_
end

class Algo::DataStructure::SelfAdjustingBinarySearchTree
  protected

  def _rotate_left(tree)
    tree = _rotate_left_(tree) unless tree.nil? || tree.right.nil?
    tree
  end

  def _rotate_right(tree)
    tree = _rotate_right_(tree) unless tree.nil? || tree.left.nil?
    tree
  end

  def _rotate_left_(tree)
    right = tree.right
    tree.right = right.left
    right.left = tree
    right
  end

  def _rotate_right_(tree)
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
