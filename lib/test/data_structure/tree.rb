# coding: utf-8
# -*- coding: utf-8 -*-

require_relative '../test'
require_relative '../../../lib/data_structure/tree/tree'
require_relative '../../../lib/data_structure/tree/bst'

module Algo
  module Test
    module DataStructure
      class TestTree
      end
      class TestBinarySearchTree < TestTree
      end
    end
  end
end

class Algo::Test::DataStructure::TestTree
  def initialize(cls, num = 1000, check = true, **args)
    raise "#{cls.class} | #{cls.inspect}" unless cls < Algo::DataStructure::Tree
    raise "#{num.class} | #{num.inspect}" unless num > 0
    raise "#{check.class} | #{check.inspect}" unless check.equal?(true) || check.equal?(false)
    raise "#{args.class} | #{args.inspect}" unless args.is_a?(Hash)
    super()
    @cls = cls
    @args = args
    @num = num
    @check = check ? (:_check if @cls.instance_methods.include?(:_check)) :
        (:_check_ if @cls.instance_methods.include?(:_check_))

    @msg_search = ->(p) { '"search #{%s} return #{tree.search(%s[0])}"' % [p, p] }
  end

  public

  def main(*args)
    args = [:del_max_min, :delete] if args.empty?
    puts '=' * 30
    args.each do |func|
      send(func, &-> { puts '-' * 30 })
    end
    puts '=' * 30
  end

  protected

  def create(num)
    cases = {}
    range = 0..(num * 100)
    1.upto(num) do
      r = rand(range)
      cases[r] = r + 1
    end
    puts "sample size: #{cases.size}"
    cases
  end

  def run(cases, tree, main, args, before, after, finish, total = nil)
    raise "#{cases.class} | #{cases.inspect}" unless cases.is_a?(Hash) && !cases.empty?
    raise "#{tree.class} | #{tree.inspect}" unless tree.instance_of?(@cls)
    raise "#{main.class} | #{main.inspect}" unless main.is_a?(Symbol)
    raise "#{args.class} | #{args.inspect}" unless args.nil? || args.is_a?(Proc) || args.is_a?(Array)
    raise "#{before.class} | #{before.inspect}" unless before.nil? || before.is_a?(Proc)
    raise "#{after.class} | #{after.inspect}" unless after.nil? || after.is_a?(Proc)
    raise "#{finish.class} | #{finish.inspect}" unless finish.nil? || finish.is_a?(Proc)
    raise "#{total.class} | #{total.inspect}" unless total.nil? || total.respond_to?(:<<)
    time = 0
    cases.each_with_index do |*_|
      org = before.call(*_) if before
      ret = nil
      time += Algo::Test::Time.runtime do
        ret = tree.public_send(main, *(args.is_a?(Proc) ? args.call(*_) : args),
                               &->(*_) { tree.send(@check, *_) if @check })
      end
      ret = after.call(*_, org, ret) if after
      total <<= ret if total
    end
    puts "#{main}: #{time * 1000}"
    finish.call(total) if finish
  end

  def insert
    raise "#{@cls.instance_methods}" unless @cls.instance_methods.include?(:insert)
    @cases = create(@num)
    tree = @cls.new(**@args)
    run(@cases, tree, :insert, ->(p, *) { p },
        ->(p, *) { raise eval(@msg_search.call('p')) unless tree.search(p[0]).nil? },
        ->(p, *) { raise eval(@msg_search.call('p')) unless tree.search(p[0]).equal?(p[1]) },
        ->(*) { tree.check(@cases.size) if tree.respond_to?(:check) })
    tree
  end

  def delete
    raise "#{@cls.instance_methods}" unless @cls.instance_methods.include?(:delete)
    tree = insert
    run(@cases, tree, :delete, ->(p, *) { p[0] },
        ->(p, *) { raise eval(@msg_search.call('p')) unless tree.search(p[0]).equal?(p[1]) },
        ->(p, *) { raise eval(@msg_search.call('p')) unless tree.search(p[0]).nil? },
        ->(*) { tree.check(0) if tree.methods.respond_to?(:check) })
    yield if block_given?
  end

  def del_max_min
    [[:max, :del_max], [:min, :del_min]].each do |get, del|
      raise "#{get.class} | #{get.inspect}" unless get.is_a?(Symbol)
      raise "#{del.class} | #{del.inspect}" unless del.is_a?(Symbol)
      raise "#{@cls.instance_methods}" unless @cls.instance_methods.include?(get)
      raise "#{@cls.instance_methods}" unless @cls.instance_methods.include?(del)
      tree = insert
      run(@cases, tree, del, nil,
          ->(*) { tree.send(get) },
          ->(*, o, _) { raise eval(@msg_search.call('o')) unless tree.search(o[0]).nil? },
          ->(*) { tree.check(0) if tree.methods.respond_to?(:check) })
      yield if block_given?
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  Algo::Test::DataStructure::TestTree.new(Algo::DataStructure::BinarySearchTree).main
  puts "done: #{__FILE__}"
end
