require 'set'
require 'benchmark'

PREFIX = "test"

class Node 
  attr_accessor :val, :visited, :edges

  def initialize(val)
    @val = val
    @visited = false
    @edges = Set.new()
  end
end 


def extract_data
  table = []

  File.open("./#{PREFIX}_data.txt", "r") do |f|
    f.each_line.with_index do |line, idx|
      row = []
      vals = line.gsub("\n", "").split("")
      vals.each_with_index do |val, jdx|
        val_node = Node.new(val)
        row << val_node
      end
      table << row 
    end
    f.close
  end

  table
end 

DATA = extract_data

def get_next_nodes(i, j)
  [
    [i + 1, j, 'top'],
    [i - 1, j, 'bottom'],
    [i, j + 1, 'right'],
    [i, j - 1, 'left' ]
  ]
end


def dfs1(val, i, j)
  node = DATA[i][j]
  return if node.visited 

  node.visited = true
  $count += 1 

  get_next_nodes(i, j).each do |pairs|
    n_idx, n_jdx = pairs
    if n_idx < 0 || n_idx == DATA.length || n_jdx < 0 || n_jdx == DATA[0].length || DATA[n_idx][n_jdx].val != val 
      $edges += 1
      next
    else 
      dfs1(val, n_idx, n_jdx)
    end
  end
end 



def solution1
  total = 0
  DATA.each_with_index do |nodes, idx|
    nodes.each_with_index do |node, jdx|
      if !node.visited
        $edges = 0
        $count = 0 
        dfs1(node.val, idx, jdx)
        total += $edges * $count
      end
    end 
  end

  total 
end



def remove_edges_from_nodes(val, i, j, edge, &block)
  return if i < 0 || i == DATA.length || j < 0 || j == DATA[0].length 
  node = DATA[i][j]

  return if DATA[i][j].val != val || !node.edges.include?(edge) 

  node.edges.delete(edge)
  n_idx, n_jdx = yield(i, j)
  remove_edges_from_nodes(val, n_idx, n_jdx, edge, &block)
end


def dfs3(val, i, j, prev_node)
    node = DATA[i][j]

    return if node.visited 
    $count += 1
    node.visited = true 


    node.edges.to_a.each do |edge|
      if edge == "left" || edge == "right"
        remove_edges_from_nodes(val, i + 1, j, edge) {|i,j|  [i + 1, j] }
        remove_edges_from_nodes(val, i - 1, j, edge)  {|i,j| [i - 1, j]}
      else 
        remove_edges_from_nodes(val, i, j + 1, edge)  {|i,j| [i, j + 1] }
        remove_edges_from_nodes(val, i, j - 1, edge) {|i,j| [i, j - 1]}
      end
    end


    get_next_nodes(i, j).each do |pairs|
      n_idx, n_jdx = pairs
      if n_idx < 0 || n_idx == DATA.length || n_jdx < 0 || n_jdx == DATA[0].length || DATA[n_idx][n_jdx].val != val 
        next
      else 
        dfs3(val, n_idx, n_jdx, node)
      end
    end

    $edges += node.edges.length
end


def solution3 
  total = 0

  # Mark all the edges 
  DATA.each_with_index do |nodes, i|
    nodes.each_with_index do |node, j|
        get_next_nodes(i, j).each do |pairs|
          n_idx, n_jdx, dir = pairs
          if n_idx < 0 || n_idx == DATA.length || n_jdx < 0 || n_jdx == DATA[0].length || DATA[n_idx][n_jdx].val != node.val 
            node.edges.add(dir)
          end
        end
    end
  end
  

  DATA.each_with_index do |nodes, idx|
    nodes.each_with_index do |node, jdx|
      if !node.visited 
        $count = 0 
        $edges = 0
        edges = dfs3(node.val, idx, jdx, nil)
        total += $edges * $count
      end
    end 
  end

  total
end

#puts solution1

t = Benchmark.measure do 
  puts solution3
end

puts t.real