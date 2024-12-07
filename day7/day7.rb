
require 'set'
PREFIX = "test"

def extract_data_keys
  data = []

  File.open("./#{PREFIX}_data.txt", "r") do |f|
    f.each_line do |line|
      chunks = line.gsub("\n", "").split(" ")
      chunks[0] = chunks[0].gsub(":", "")
      data << chunks.map(&:to_i)
    end
    f.close
  end

  data
end 



DATA =  extract_data_keys


def build_tree(dataset, currentNum, currentIdx, targetNum, concat = false)
  $stored.add(targetNum) if targetNum == currentNum  && currentIdx == dataset.length - 1
 
  next_index = currentIdx + 1
  return if next_index >= dataset.length 

  next_val = dataset[next_index]
  next_plus = currentNum + next_val
  next_mul = currentNum * next_val
  next_concat = (currentNum.to_s + next_val.to_s).to_i  if concat 
  
  #optimization block 
  stillPossible = dataset[next_index + 1].nil? || dataset[next_index + 1] == 1
  return if !stillPossible && (next_plus == targetNum || next_mul == targetNum || next_concat == targetNum) 
  #end

  build_tree(dataset, next_plus, currentIdx + 1, targetNum, concat) if next_plus <= targetNum
  build_tree(dataset, next_mul, currentIdx + 1, targetNum, concat) if next_mul <= targetNum
  build_tree(dataset, next_concat, currentIdx + 1, targetNum, concat) if concat && next_concat <= targetNum
end


# tree for combinations, and dfs
def solution1
  DATA.each do |dataset|
    target = dataset[0]
    build_tree(dataset, dataset[1], 1, target)
  end 

  $stored.to_a.inject(0, :+)
end 

def solution2 
 
  DATA.each do |dataset|
    target = dataset[0]
    build_tree(dataset, dataset[1], 1, target, true)
  end 

  $stored.to_a.inject(0, :+)
end


$stored = Set.new([])
puts solution1
$stored = Set.new([])
puts solution2

=begin
  Essentially the problem can be thought off as a tree with branches leading to next operation. So we can effectively permutate the solution.
  We have the option to do a dfs afterwards but it is not neccessary since we can just stored relevant numbers in a set when building the tree.

  We can do slight optimizations by adding conditions that make sense, for example, if you get your target sum, and if you are not at the end of your array,
  then you have to check if the remaining numbers are 1s otherwise it is not possible to solve. [This can be leveraged further if you are really good at math, 
  and implement a theorem proves that the remaining numbers are not valid]
=end
