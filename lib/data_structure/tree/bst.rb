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
  def initialize(up: nil, down: nil)
    raise "#{up.class} | #{up.inspect}" unless up.nil? || up.is_a?(Proc)
    raise "#{down.class} | #{down.inspect}" unless down.nil? || down.is_a?(Proc)
    super()
    @up = up if up
    @down = down if down
  end

  public

  def size
    _size(@root)
  end

  def key(key, &blk)
    tree = _key(@root, key, &blk) and tree.value
  end
  alias_method :search, :key

  def max(&blk)
    tree = _max(@root, &blk) and [tree.key, tree.value]
  end

  def min(&blk)
    tree = _min(@root, &blk) and [tree.key, tree.value]
  end

  def insert(key, value)
    @root = _insert(@root, key, value)
  end

  def delete(key, &blk)
    @root = _delete(@root, key, &blk) if @root
  end

  def del_max(&blk)
    @root = _del_max(@root, &blk) if @root
  end

  def del_min(&blk)
    @root = _del_min(@root, &blk) if @root
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
                     ->(tree, _, value) do
                       tree.value = value
                       tree
                     end,
                     ->(_, key, value) { Node.new(key, value) }, &blk)
  end

  def _delete(tree, key, &blk)
    _find_recursive_(tree, key,
                     ->(tree, key) { key <=> tree.key },
                     ->(_, _) { nil },
                     ->(tree, _) do
                       return tree.right if tree.left.nil?
                       return tree.left if tree.right.nil?
                       m = _max(tree.left)
                       tree.key = m.key
                       tree.value = m.value
                       tree.left = _del_max(tree.left, &blk)
                       tree
                     end, &blk)
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

  private

  def _find_iterative_(tree, *args, find_which, find_it)
    raise "#{tree.class} | #{tree}" unless tree.nil? || tree.class <= Node
    raise "#{find_which.class} | #{find_which.inspect}" unless find_which.is_a?(Proc)
    raise "#{find_it.class} | #{find_it.inspect}" unless find_it.is_a?(Proc)

    until tree.nil?
      @down.call(tree) if @down
      yield tree if block_given?
      break if find_it.call(tree, *args)
      tree = find_which.call(tree, *args)
    end
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
    @up.call(tree) if @up && tree
    yield tree if block_given? && tree
    tree
  end
end

if __FILE__ == $PROGRAM_NAME
  nil
  puts "done: #{__FILE__}"
end
