require 'set'
require_relative 'kanwei_heap' # copy of kanwei's algorithmn heap library, do this on ur own if you want to use a pq


DIRECTIONS = {
  'n' => [-1, 0],
  's' => [1, 0],
  'e' => [0, 1],
  'w' => [0, -1]
}



def extract_data(limit = nil)
  $cached_extraction ||= []

  prefix = !!ENV['TEST'] ? "test" : "sample"

  if $cached_extraction.length == 0 
    File.open("#{prefix}_data.txt") do |f|
      f.each_line do |line|
        chunks = line.gsub("\n","").split(",").reverse.join(",")
        $cached_extraction << chunks
      end
      f.close
    end
  end

  $coords = Set.new(limit ? $cached_extraction[0...limit] : $cached_extraction)
  $coords
end


def build_map(y, x)
  map = Array.new(y + 1) { Array.new(x + 1, ".") }

  (0..y).each do |r|
    (0..x).each do |c| 
      coord = "#{r},#{c}"
      map[r][c] = "#" if $coords.include?(coord)
    end
  end
  map
end

def get_next_nodes(pos)
  next_nodes = []
  y, x = pos
  DIRECTIONS.each do |dir, vector|
    vy, vx = vector 
    ny, nx = [y + vy, x + vx]

    next_nodes << "#{ny},#{nx},#{dir}"
  end

  next_nodes
end


def run_djk(y, x, map)
  visited_nodes = {}
  unvisited_nodes = {}

  map.each_with_index do |r, _y|
    r.each_with_index do |v, _x|
      # we use 4 directions because a 2d table graph is undirected
      %w(n s w e).each do |dir|
        unvisited_nodes["#{_y},#{_x},#{dir}"] = Float::INFINITY if v != "#"
      end
    end
  end

  pq = MinHeap.new([[0,  "#{0},#{0},s"]])

  unvisited_nodes["#{0},#{0},s"] = 0

  while pq.size > 0
    _, current_node = pq.min!

    next if unvisited_nodes[current_node].nil?

    _y, _x, dir = current_node.split(",")
    next_nodes = get_next_nodes([_y.to_i, _x.to_i])

    next_nodes.each do |node| 
      next if unvisited_nodes[node].nil?

      _, _, n_dir = node.split(",")

      score = 1 + unvisited_nodes[current_node]
      score = [score, unvisited_nodes[node]].min

      unvisited_nodes[node] = score
      pq.push([score, node]) if unvisited_nodes[node]
    end

    visited_nodes[current_node] = unvisited_nodes[current_node]
    unvisited_nodes.delete(current_node)
  end


  min = Float::INFINITY
  DIRECTIONS.keys.each do |dir|
    key = "#{y},#{x},#{dir}"
    min = [min, visited_nodes[key]].min if visited_nodes[key]
  end

  [min, visited_nodes]
end

def solution_1(y, x, byte_limit)
  extract_data(byte_limit)
  map = build_map(y, x)
  min, visited_nodes = run_djk(y, x, map)
  min
end

def calculate_path_taken(y, x, visited_nodes, map)
  path = Set.new()

  visited_nodes.each do |node, val|
    y, x, _ = node.split(",")
    y = y.to_i 
    x = x.to_i 
    map[y][x] = map[y][x] == "." ? val : [map[y][x], val].min
  end

  until y == 0 && x == 0 
    current_node = "#{y},#{x}"
    current_val = map[y][x]

    path.add(current_node)

    DIRECTIONS.values.each do |vector|
      vy, vx = vector 
      ny, nx = [y + vy, x + vx]

            
      next if ny < 0 || ny >= map.length 
      next if nx < 0 || nx >= map.first.length

      next_value = map[ny][nx]
      if next_value == current_val - 1 
        y = ny 
        x = nx 
        break 
      end 
    end
  end

  path
end


def solution_2(y, x, start)
  iteration = start
  extract_data() # preinitialize some global vars
  current_path = Set.new([])
  count = 0

  while iteration < $cached_extraction.length
    extract_data(iteration)
    map = build_map(y, x)

    # optimization block, basically, when we run a djkistra algo
    # we also can find the shortest path
    # with that, if the next indexes don't interfere with the shortest path
    # there is no need to check whether those indexes would block our path
    # only when something blocking the optimal path, would we readjust 
    # and continue the pattern

    new_index = $cached_extraction[iteration - 1]

    if current_path.length == 0 || current_path.include?(new_index)
      count, visited_nodes = run_djk(y, x, map)
      break if count == Float::INFINITY
      current_path = calculate_path_taken(y, x, visited_nodes, map)
      puts "#{iteration} => #{count}"
    else 
      puts "#{iteration} => #{count} => cached" 
    end

    iteration += 1
  end

  puts iteration
  $cached_extraction[iteration - 1].split(",").reverse.join(",")
end


t1 = !!ENV['TEST'] ? 70 : 6
t2 = !!ENV['TEST'] ? 1024 : 12
# solution_1(t1, t1, t2)

puts solution_2(t1, t1, t2 + 1)
