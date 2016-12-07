# coding: utf-8
# -*- coding: utf-8 -*-

require_relative '../../test'
require_relative '../../../lib/data_structure/tree/tree'

module Algo
  module DataStructure
    class TreeTest
    end
  end
end

class Algo::DataStructure::TreeTest
  def initialize(cls: nil, argv: nil, num: nil)
    raise "#{cls.class} | #{cls.inspect}" unless cls.is_a?(Class) && cls < Algo::DataStructure::Tree
    raise "#{argv.class} | #{argv.inspect}" unless argv.is_a?(Hash)
    raise "#{num.class} | #{num.inspect}" unless num.is_a?(Integer) && num > 0

    super()
    @cls = cls
    @argv = argv
    @num = num

    @msg_search = ->(p) { '"search #{%s} returns #{tree.search(%s[0])}"' % [p, p] }
  end

  public

  def main(*args)
    raise "#{args}" unless args.reject(&->(m) { m.is_a?(Symbol) || m.is_a?(String) }).empty?
    if args.empty?
      args = [:del_max_min, :delete]
    else
      args.select!(&->(m) { methods.include?(m) })
    end
    puts '=' * 30
    args.each { |func| send(func) { puts '-' * 30 } }
    puts "pass: #{@cls.inspect}"
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
        ret = tree.public_send(main, *(args.is_a?(Proc) ? args.call(*_) : args))
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
    tree = @argv.empty? ? @cls.new : @cls.new(**@argv)
    run(@cases, tree, :insert, ->(p, *) { p },
        ->(p, *) { raise eval(@msg_search.call('p')) unless tree.search(p[0]).nil? },
        ->(p, *) { raise eval(@msg_search.call('p')) unless tree.search(p[0]).equal?(p[1]) },
        ->(*) { tree.check(@cases.size) if tree.respond_to?(:check) })
    yield if block_given?
    tree
  end

  def delete
    raise "#{@cls.instance_methods}" unless @cls.instance_methods.include?(:delete)
    tree = insert
    run(@cases, tree, :delete, ->(p, *) { p[0] },
        ->(p, *) { raise eval(@msg_search.call('p')) unless tree.search(p[0]).equal?(p[1]) },
        ->(p, *) { raise eval(@msg_search.call('p')) unless tree.search(p[0]).nil? },
        ->(*) { tree.check(0) if tree.respond_to?(:check) })
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
          ->(*) { tree.check(0) if tree.respond_to?(:check) })
      yield if block_given?
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  nil
  puts "done: #{__FILE__}"
end
