require 'benchmark'
PREFIX = 'test'


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
  attr_accessor :val, :visited, :score

  def initialize(val)
    @val = val 
    @visited = false 
    @score = 0
  end
end 

def form_table 
  $graph = []
  $starting_pos = []
  $count = 0

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

$positions_to_clear = []

def traverse_tree(idx, jdx)
  current_node = $graph[idx][jdx]

  return if current_node.visited 

  current_node.visited = true 
  $positions_to_clear << [idx, jdx] 

  if current_node.val == 9 
    $count += 1 
    return
  end

  [[idx + 1, jdx], [idx - 1, jdx], [idx, jdx + 1], [idx, jdx - 1]].each do |pairs|
    traverse_tree(pairs[0], pairs[1]) if valid_node(pairs[0], pairs[1], current_node.val)
  end
end


def traverse_tree_2(idx, jdx)
  current_node = $graph[idx][jdx]


  return current_node.score if current_node.visited

  current_node.visited = true 

  if current_node.val == 9 
    $count += 1 
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
    traverse_tree(idx, jdx)

    while $positions_to_clear.length > 0
      i, j = $positions_to_clear.pop 
      $graph[i][j].visited = false
    end

    sum += $count
    $count = 0
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
  Simple DFS algorithm, the only differene is part1, we aren't looking for total unique paths, but number of different peaks,
  so can simple just skip any paths we already been to.

  For part two, it's a dfs with memoziation, much optimized than part 1 actually
=end