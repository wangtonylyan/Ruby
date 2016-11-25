# require 'test/unit'
# require_relative '../../../lib/data_structure/tree/tree'
require_relative 'tree'
require_relative 'bst'

module Test
  class Time
    def self.runtime
      return 0 unless block_given?
      t = ::Time.now
      yield
      t = ::Time.now - t
    end
  end

  module DataStructure
    class TestTree
    end
    class TestBinarySearchTree < TestTree
    end
  end
end

class Test::DataStructure::TestTree
  def initialize(cls, args, num, check)
    raise "#{cls.class}, #{cls.inspect}" unless cls < ::DataStructure::Tree
    raise "#{num.class}, #{num.inspect}" unless num > 0
    raise "#{check.class}, #{check.inspect}" unless check.equal?(true) || check.equal?(false)
    raise "#{args.class}, #{args.inspect}" unless args.is_a?(Hash)
    super()
    @cls = cls
    @args = args
    @num = num
    @check = check ? :_check : :_check_

    @msg_search = ->(p) { '"search #{%s} return #{tree.search(%s[0])}"' % [p, p] }
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
    raise "#{cases.class}, #{cases.inspect}" unless cases.is_a?(Hash) && !cases.empty?
    raise "#{tree.class}, #{tree.inspect}" unless tree.is_a?(@cls)
    raise "#{main.class}, #{main.inspect}" unless main.is_a?(Symbol)
    raise "#{before.class}, #{before.inspect}" unless before.nil? || before.is_a?(Proc)
    raise "#{after.class}, #{after.inspect}" unless after.nil? || after.is_a?(Proc)
    raise "#{finish.class}, #{finish.inspect}" unless finish.nil? || finish.is_a?(Proc)
    raise "#{total.class}, #{total.inspect}" unless total.nil? || total.methods.include?(:<<)
    args = if args.is_a?(Proc) then args
           elsif args.is_a?(Array) then args
           elsif args.is_a?(Hash) then args.values
           end
    time = 0
    cases.each_with_index do |*_|
      org = before.call(*_) if before
      ret = nil
      time += Test::Time.runtime do
        ret = tree.public_send(main, *(args.is_a?(Proc) ? args.call(*_) : args),
                               &->(obj) { tree.send(@check, obj) if @check })
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
    msg = @msg_search.call('p')
    run(@cases, tree, :insert, ->(p, *_) { p },
        ->(p, *_) { raise eval(msg) unless tree.search(p[0]).nil? },
        ->(p, *_) { raise eval(msg) unless tree.search(p[0]).equal?(p[1]) },
        ->(*_) { tree.check(@cases.size) })
    tree
  end

  def delete
    raise "#{@cls.instance_methods}" unless @cls.instance_methods.include?(:delete)
    tree = insert
    msg = @msg_search.call('p')
    run(@cases, tree, :delete, ->(p, *_) { p[0] },
        ->(p, *_) { raise eval(msg) unless tree.search(p[0]).equal?(p[1]) },
        ->(p, *_) { raise eval(msg) unless tree.search(p[0]).nil? },
        ->(*_) { tree.check(0) })
    yield if block_given?
  end

  def del_max_min
    [[:max, :del_max], [:min, :del_min]].each do |get, del|
      raise "#{get.class}, #{get.inspect}" unless get.is_a?(Symbol)
      raise "#{del.class}, #{del.inspect}" unless del.is_a?(Symbol)
      raise "#{@cls.instance_methods}" unless @cls.instance_methods.include?(get)
      raise "#{@cls.instance_methods}" unless @cls.instance_methods.include?(del)
      tree = insert
      msg = @msg_search.call('o')
      run(@cases, tree, del, nil,
          ->(*_) { tree.send(get) },
          ->(*_, o, _) { raise eval(msg) unless tree.search(o[0]).nil? },
          ->(*_) { tree.check(0) })
      yield if block_given?
    end
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
end

class Test::DataStructure::TestBinarySearchTree
  def initialize(num: 1000, check: true, **args)
    super(::DataStructure::BinarySearchTree, args, num, check)
  end
end

if __FILE__ == $PROGRAM_NAME
  Test::DataStructure::TestBinarySearchTree.new.main
  puts 'done'
end
