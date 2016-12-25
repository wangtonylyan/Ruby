require_relative '../../lib/number/sort'

if __FILE__ == $PROGRAM_NAME
  [Algo::Number::Sort::BubbleSort.new,
   Algo::Number::Sort::SelectSort.new,
   Algo::Number::Sort::InsertSort.new].each do |obj|
    [obj.method(:iter!), obj.method(:recur!)].each do |func|
      0.upto(100).each do |_|
        lst = []
        0.upto(100).each do |_|
          lst <<= rand(10_000)
        end
        ret = lst.clone
        func.call(lst)
        raise "#{ret}" if ret == lst
        ret.sort!
        raise "#{func} | #{lst}" unless ret == lst
      end
    end
  end
  puts "done: #{__FILE__}"
end
