# coding: utf-8
# -*- coding: utf-8 -*-

class Main
  # 外部对于对象属性的访问只能通过类中声明的方法
  # 以下函数声明的作用同样适用于类的内部
  # 例如对于定义了getter的属性，无需前缀@即可在类内部被访问
  attr_reader :attribute_access # getter
  attr_writer :attribute_access # setter
  attr_accessor :attribute_access # getter + setter

  public

  attr_reader :attribute_access

  attr_writer :attribute_access

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
hash = { a: 1, b: 2 } # 使用此格式进行声明
# hash.each_with_index do |[key, value], index|
#  puts key, value, index
#  end

# Array
# each, map, select (= filter), inject (= reduce)

# Range
# inclusive: .., exclusive: ...

# Block
# block的作用：循环，资源管理(file open, thread run)
# block中的返回尽量使用next，而不是return

# Module & Class
# 调用module中方法的方式与调用class中类方法的方式是完全一致的
# 因此，若没有类的成员需要维护，就可以用module代替class

# print, printf, sprintf
# puts to_s, p inspect

# Metaprogramming
# send, respond_to? (仅public method会返回true)
# is_a? (= kind_of?, check inheritance), instance_of?

# alias是与其定义处的函数所绑定的，并不随继承、重定义等而变化

# Method arguments
# 五种：regular argument, keyword argument, splat argument, double splat argument, block argument
# method_name(regular(= default value), *splat, &block)
# method_name(regular, keyword: default value, **splat, &block)
# regular argument是仅方法内部可见的局部变量，而不是keyword argument
# splat和double splat的作用是收集所有regular、keyword和block之外类型的传参
