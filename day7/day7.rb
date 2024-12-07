
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

class TreeNode
  attr_accessor :num, :total, :next_plus, :next_mul, :next_concat

  def initialize(num)
    @num = num
    @next_plus = nil 
    @next_mul = nil
    @next_concat = nil
  end 
end 


def build_tree(dataset, currentNum, currentIdx, targetNum, concat = false)
  node = TreeNode.new(currentNum) 

  
  $stored.add(targetNum) if targetNum == currentNum  && currentIdx == dataset.length - 1
 
  next_index = currentIdx + 1
  return node if next_index >= dataset.length 

  next_val = dataset[next_index]
  next_plus = currentNum + next_val
  next_mul = currentNum * next_val
  next_concat = (currentNum.to_s + next_val.to_s).to_i  if concat 
  
  node.next_plus = build_tree(dataset, next_plus, currentIdx + 1, targetNum, concat)
  node.next_mul = build_tree(dataset, next_mul, currentIdx + 1, targetNum, concat)
  node.next_concat = build_tree(dataset, next_concat, currentIdx + 1, targetNum, concat) if concat

  node 
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
  Brute forcing using a tree. Essentially the problem can be thought off as a tree with branches leading to next operation. So we can effectively permutate the solution.
  We have the option to do a dfs afterwards but it is not neccessary since we can just stored relevant numbers in a set when building the tree.
end