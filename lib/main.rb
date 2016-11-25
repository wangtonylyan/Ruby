class Main
  # 外部对于对象属性的访问只能通过类中声明的方法
  # 以下函数声明的作用同样适用于类的内部
  # 例如对于定义了getter的属性，无需前缀@即可在类内部被访问
  attr_reader :attribute_access # getter
  attr_writer :attribute_access # setter
  attr_accessor :attribute_access # getter + setter

  public
  def attribute_access # getter
    @attribute_access
  end

  def attribute_access=(value) # setter
    @attribute_access = value
  end


  private

  def initialize
    @attribute_access = nil
  end


  def self.class_func
    # this is a class method
  end

  # self关联的是对象
  # 在类的内部调用方法时，使用self
  # 在类的内部访问属性时，使用@

  # 函数调用建议一定要加上括号
  # &&和||用于逻辑判断，and和or优先级很低，仅用于流程控制（类似于if和unless）
end

# 字符串尽量使用单引号
hash = {a: 1, b: 2} # 使用此格式进行声明
#hash.each_with_index do |[key, value], index|
#  puts key, value, index
#  end
