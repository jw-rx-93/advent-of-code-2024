require 'set'

PREFIX = "sample"


def extract_data
  map = []
  start_pos = []
  end_pos = []

  File.open("#{PREFIX}_data.txt") do |f|
    f.each_line.with_index do |line, i|
      line_chunk = line.gsub("\n", "").split("")
      map.push(line_chunk)
      start_pos = [i, line_chunk.index("S")] if line.include?("S")
      end_pos = [i, line_chunk.index("E")] if line.include?("E")
    end

    f.close
  end

  [map, start_pos, end_pos]
end


MAP, START_POS, END_POS = extract_data
DIRECTIONS = {
  'n' => [-1, 0],
  's' => [1, 0],
  'e' => [0, 1],
  'w' => [0, -1]
}

def create_list_of_nodes
  # every node is actually 4 nodes because direction
  list_of_nodes = {}

  MAP.each_with_index do |row, i|
    row.each_with_index do |v, j|
      if ["S", "E", "."].include?(v)
        DIRECTIONS.keys.each do |dir|
          node = "#{i},#{j},#{dir}"
          list_of_nodes[node] = Float::INFINITY
        end
      end
    end
  end

  list_of_nodes
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

def get_score_increment(d1, d2)
  return 0 if d1 == d2 
  # oppossing direction two rotations to get to this point
  return 2000 if (d1 == "n" && d2 == "s") || (d1 == "w" && d2 == "e") || (d1 == "s" && d2 == "n") || (d1 == "e" && d2 == "w")
  
  # diff direction
  1000
end


def solution_1
  unvisited_nodes = create_list_of_nodes
  visited_nodes = {}

  start_pos_key = "#{START_POS[0]},#{START_POS[1]},e"

  # start point 0 weight 
  unvisited_nodes[start_pos_key] = 0 
  pseudo_pq = [start_pos_key]

  while pseudo_pq.length > 0 
    current_node = pseudo_pq.min_by{|node| unvisited_nodes[node] }
    pseudo_pq.delete(current_node)
    
    y, x, dir = current_node.split(",")
    next_nodes = get_next_nodes([y.to_i, x.to_i])

    next_nodes.each do |node| 
      next if unvisited_nodes[node].nil?

      _, _, n_dir = node.split(",")

      score = 1 + unvisited_nodes[current_node]
      score += get_score_increment(dir, n_dir)
      score = [score, unvisited_nodes[node]].min

      unvisited_nodes[node] = score
      pseudo_pq << node if unvisited_nodes[node]
    end

    visited_nodes[current_node] = unvisited_nodes[current_node]
    unvisited_nodes.delete(current_node)

    pseudo_pq = pseudo_pq.select{|node| unvisited_nodes[node] != nil }
  end

  min = Float::INFINITY
  DIRECTIONS.keys.each do |dir|
    key = "#{END_POS[0]},#{END_POS[1]},#{dir}"
    min = [min, visited_nodes[key]].min if visited_nodes[key]
  end

  [min, visited_nodes]
end

# solution_1

def dfs(current_pos, current_weight, current_path, dir)
  # path is no longer valid cuz it exceeds endpoint
  y, x = current_pos.map(&:to_i)
  undir_node = "#{y},#{x}"

  if MAP[y][x] == "E"
    current_path.each{|p| $paths_taken.add(p) }
    return 
  end

  return if MAP[y][x] == "#" || current_weight > $min_score  || current_weight > $all_min_scores[undir_node + ",#{dir}"]

  current_path << undir_node

  next_nodes = get_next_nodes([y, x])
  next_nodes.each do |next_node|
    _y, _x, _dir = next_node.split(",")
    _y = _y.to_i 
    _x = _x.to_i 

    next if MAP[_y][_x] == "#" # A bit redundant but w/e 
    weight = 1 + current_weight
    weight += get_score_increment(dir, _dir)

    dfs([_y, _x],  weight, current_path.dup, _dir)
  end
   
end

def solution_2
  $min_score, $all_min_scores = solution_1
  $paths_taken = Set.new([])

  dfs(START_POS.dup, 0, [], "e")

  return $paths_taken.to_a.length + 1 # no idea why I need a + 1, starting position should be accounted for 
end

puts solution_2


$all_min_scores.each do |node, val|
  y, x, _ = node.split(",")
  y = y.to_i 
  x = x.to_i 
  
  if ["S", "E", "."].include?(MAP[y][x])
    MAP[y][x] = val
  else
    MAP[y][x] = [MAP[y][x], val].min
  end
end

MAP.each do |row|
  print row.map{|v| (v == Float::INFINITY ? "INFINITY" : "#{v}      ")[0...5]}.join(" "), "\n"
end