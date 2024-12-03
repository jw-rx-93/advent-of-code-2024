def extract_data
  arr1 = []
  arr2 = []

  File.open("./test_data.txt", "r") do |f|
    f.each_line do |line|
      chunks = line.split(" ")
      arr1 << chunks.first.to_i 
      arr2 << chunks.last.to_i
    end
    f.close
  end

  [arr1, arr2]
end


def solution1
  arr1, arr2 = extract_data()
  arr1 = arr1.sort
  arr2 = arr2.sort

  sum = 0
  arr1.each_with_index do |val, idx|
    cmp_val = arr2[idx]

    if cmp_val != nil 
      diff = (val - cmp_val).abs 
      sum += diff
    end
  end

  sum
end

puts solution1()

def solution2()
  arr1, arr2 = extract_data()
  counterHash = Hash.new(0)

  arr2.each{|num| counterHash[num] += 1}
  sum = 0 
  arr1.each do |num|
    score = num * counterHash[num]
    sum += score
  end
  sum
end

puts solution2()

=begin Thoughts:
  With regards to basic sorting, the time complexity is always at nlogn since
  But you can try to use your own bucket sort approach by aligning your data samples with the indices, then compact the arrays.
  For the values at the indices themselves, just increment them to account for repeated values. Then using two index pointers,
  just move through the arrays and decrement the values at the indices to 0 before moving to the next index.
  Now you're time compexity is O(n). It's needlessly complicated to solve the data sample size tho.
=end