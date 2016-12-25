# coding: utf-8
# -*- coding: utf-8 -*-
# problem: sorting (into increasing order)
# solution:
# (a) comparison based
# insertion, shell, selection, bubble, quick, merge, heap
# 实际中推荐使用快速排序(随机访问，倾向数组)和合并排序(顺序访问，倾向链表)
# (b) non-comparison based
# counting, radix, bucket
# 思想就是建立被排序的数与其排序后的索引值之间的映射

module Algo
  module Number
    module Sort
      class BubbleSort
      end
      class SelectSort
      end
      class InsertSort
      end
    end
  end
end

module Algo::Number::Sort
  class BubbleSort
    def iter!(lst)
      for i in (lst.size - 1).downto(1) do
        swap = false
        for j in 0.upto(i - 1) do
          if lst[j] > lst[j + 1]
            lst[j], lst[j + 1] = lst[j + 1], lst[j]
            swap = true
          end
        end
        break unless swap
      end
      lst
    end

    def recur!(lst)
      def outer(lst, i)
        def inner(lst, i, j)
          if j < i - 1
            lst[j], lst[j + 1] = lst[j + 1], lst[j] if lst[j] > lst[j + 1]
            inner(lst, i, j + 1)
          end
        end
        if i > 0
          inner(lst, i, 0)
          lst[i - 1], lst[i] = lst[i], lst[i - 1] if lst[i - 1] > lst[i]
          outer(lst, i - 1)
        end
        lst
      end
      outer(lst, lst.size - 1)
    end
  end

  class SelectSort
    def iter!(lst)
      for i in 0.upto(lst.size - 2) do
        m = i
        for j in (i + 1).upto(lst.size - 1) do
          m = j if lst[j] < lst[m]
        end
        lst[i], lst[m] = lst[m], lst[i] unless i == m
      end
      lst
    end

    def recur!(lst)
      def outer(lst, i)
        def inner(lst, j)
          if j < lst.size - 1
            m = inner(lst, j + 1)
            j = m if lst[j] > lst[m]
          end
          j
        end
        if i < lst.size - 1
          m = inner(lst, i + 1)
          lst[i], lst[m] = lst[m], lst[i] if lst[i] > lst[m]
          outer(lst, i + 1)
        end
        lst
      end
      outer(lst, 0)
    end
  end

  class InsertSort
    def iter!(lst)
      for i in 0.upto(lst.size - 2) do
        t = lst[i + 1]
        j = i
        while j >= 0 && lst[j] > t
          lst[j + 1] = lst[j]
          j -= 1
        end
        lst[j + 1] = t
      end
      lst
    end

    def recur!(lst)
      def outer(lst, i)
        def inner(lst, t, j)
          if j >= 0 && lst[j] > t
            lst[j + 1] = lst[j]
            j = inner(lst, t, j - 1)
          end
          j
        end
        if i < lst.size - 1
          t = lst[i + 1]
          j = inner(lst, t, i)
          lst[j + 1] = t
          outer(lst, i + 1)
        end
        lst
      end
      outer(lst, 0)
    end
  end
end
