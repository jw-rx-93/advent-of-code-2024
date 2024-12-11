require 'benchmark'
require 'set'

PREFIX = 'sample'

def extract_data  
  graph = []

  File.open("./#{PREFIX}_data.txt", "r") do |f|
    f.each_line do |line|
      chunks = line.gsub("\n", "").split("")
      chunks = chunks.map {|val| val == "." ? -1 : val.to_i}
      graph << chunks
    end
    f.close
  end

  graph  
end 

GRAPH = extract_data
ROW_BOUND = GRAPH.length 
COL_BOUND = GRAPH[0].length

class Node 
  attr_accessor :val, :visited, :score, :peaks
  def initialize(val)
    @val = val 
    @visited = false 
    @score = 0
    @peaks = []
  end
end 

def form_table 
  $graph = []
  $starting_pos = []

  GRAPH.each_with_index do |row, idx|
    temp = []
    row.each_with_index do |val, jdx|
      $starting_pos << [idx, jdx] if val == 0 
      node = Node.new(val)
      temp << node 
    end

    $graph << temp 
  end
end

def valid_node(n_idx, n_jdx, current_val)
  # i could OR it all but that's too messy to read
  return false if n_idx < 0 || n_idx >= ROW_BOUND 
  return false  if n_jdx < 0 || n_jdx >= COL_BOUND 
  return false  if $graph[n_idx][n_jdx].val != current_val + 1 
  true
end


def traverse_tree(idx, jdx)
  current_node = $graph[idx][jdx]

  return current_node.peaks if current_node.visited 
    
  current_node.visited = true 

  if current_node.val == 9 
    current_node.peaks = ["#{idx},#{jdx}"]
    return  ["#{idx},#{jdx}"]
  end


  peaks = []

  [[idx + 1, jdx], [idx - 1, jdx], [idx, jdx + 1], [idx, jdx - 1]].each do |pairs|
    peaks.concat(traverse_tree(pairs[0], pairs[1])) if valid_node(pairs[0], pairs[1], current_node.val)
  end
  
  current_node.peaks = peaks 
  peaks
end


def traverse_tree_2(idx, jdx)
  current_node = $graph[idx][jdx]

  return current_node.score if current_node.visited

  current_node.visited = true 

  if current_node.val == 9 
    current_node.score = 1
    return 1
  end

  score = 0

  [[idx + 1, jdx], [idx - 1, jdx], [idx, jdx + 1], [idx, jdx - 1]].each do |pairs|
    score += traverse_tree_2(pairs[0], pairs[1]) if valid_node(pairs[0], pairs[1], current_node.val)
  end

  current_node.score = score 
  score 
end


def solution1 
  form_table
  sum = 0
  $starting_pos.each do |pos| 
    idx, jdx = pos 
    peaks = traverse_tree(idx, jdx)
    t = Set.new(peaks).length
    sum += t
  end 

  sum
end 


def solution2
  form_table
  sum = 0
  $starting_pos.each do |pos| 
    idx, jdx = pos 
    score = traverse_tree_2(idx, jdx)
    sum += score
  end 

  sum
end


t = Benchmark.measure {
  print solution1 
  puts
}
puts t.real

t = Benchmark.measure {
  print solution2
  puts
}

puts t.real

=begin 
  Both are the same algorithm, just whatever we're storing for memoization is different
=end