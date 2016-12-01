# coding: utf-8
# -*- coding: utf-8 -*-

module Algo
  module DataStructure
    class Tree
      class Node
      end
    end
  end
end

class Algo::DataStructure::Tree::Node
  attr_accessor :key, :value

  def initialize(key, value)
    super()
    @key = key
    @value = value
  end

  def to_s
    "key=#{@key}, value=#{@value}"
  end
end

class Algo::DataStructure::Tree
  def initialize
    super()
    @root = nil
  end

  def size
    raise
  end

  def search
    raise
  end

  def max
    raise
  end

  def min
    raise
  end

  def insert
    raise
  end

  def delete
    raise
  end

  def del_max
    raise
  end

  def del_min
    raise
  end
end
