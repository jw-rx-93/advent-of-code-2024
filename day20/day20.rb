require 'set'
require_relative "../helpers"



DIRECTIONS = [
  [-1, 0],
  [1, 0],
  [0, 1],
  [0, -1]
]


def extract_data
  prefix = !!ENV['TEST'] ? "test" : "sample"
  $visitable_points ||= {}
  $replacable_blocks ||= []
  $start_point ||= []
  $end_point ||= []

  if $visitable_points.length == 0 
    File.open("#{prefix}_data.txt") do |f|
      f.each_line.with_index do |line, row|
        line_chunks = line.gsub("\n", "").split("")
        next if line_chunks.all?{|v| v == "#"}

        line_chunks.each_with_index do |v, col|
          next if col == 0 || col == line_chunks.length - 1
          coord = "#{row},#{col}"
          if v == "." || v == "S" || v == "E"
            $visitable_points[coord] = 0
            $start_point = [row, col] if v == "S"
            $end_point = [row, col] if v == "E"
          else
            $replacable_blocks << coord
          end
        end
      end

      f.close
    end
  end

  [$visitable_points, $replacable_blocks, $start_point, $end_point]
end


def find_known_path_measurement
  queue = Queue.new()
  visited_points = Set.new([])
  distance = 0
  path = []

  queue << $start_point

  while queue.length > 0
    y, x = queue.pop
    path << [y, x]
    visited_points << "#{y},#{x}"
    $visitable_points["#{y},#{x}"] = distance

    DIRECTIONS.each do |vector|
      vy, vx = vector
      next_y, next_x = [y + vy, x + vx]
      next_coor = "#{next_y},#{next_x}"
      queue << [next_y, next_x] if !!$visitable_points[next_coor] && !visited_points.include?(next_coor)
    end

    distance += 1
  end

  max_distance = $visitable_points["#{$end_point.first},#{$end_point.last}"]
  $visitable_points.each{ |k, v| $visitable_points[k] = max_distance - v }
  [max_distance, path]
end

# we only have 1 path to start with
# we can the known path and set the distance of each block to the end point
# when a cheat block is introduced, we want to bfs to that block first, and accumulate distance
# once that distance is known, we can keep looping until we hit the End point of one of the original
# blocks which has a stored distance from point E 
# not all blocks are cheatable. If they aren't connected to a "." or "E" or "S", then it's not a reachable block
# also ignore all edge blocks

def solution_1
  extract_data
  
  #first bfs to measure distance of points from the endpoint, there is no forking
  max_distance, _ = find_known_path_measurement
  counter = Hash.new(0)


  # you don't even need to do dfs for these because you already know the distances of the adjacent blocks if there are any
  # for it to be a short cut there has to be two points where it is connected if this is slotted in
  $replacable_blocks.each do |cheat_coor|
    y, x = cheat_coor.split(",").map(&:to_i)
    next_nodes = []

    # the one with the greatest distance from end point is always the visited node
    # while the other 1 or 2 are the next possible nodes 
    # we just choose the min among them
    DIRECTIONS.each do |vector|
      vy, vx = vector
      ny, nx = [y + vy, x + vx]
      next_coor = "#{ny},#{nx}"
      next_nodes << next_coor if !!$visitable_points[next_coor]
    end

    next unless next_nodes.length > 1

    next_nodes_val = next_nodes.map{|coor| $visitable_points[coor]}.sort 
    max_val = next_nodes_val.pop 
    target = next_nodes_val.map{|v| max_distance - max_val + v  }.min
    counter[max_distance - target - 2] += 1 
  end

  count = 0
  counter.to_a.sort_by{|p| p[0]}.each do |p|
    k, v = p
    next if k == 0
    puts "There are #{v} that saves #{k} picoseconds"
    if k >= 100 
      count += v
    end
  end

  count
end

# puts solution_1

def solution_2
  extract_data
  max_distance, path = find_known_path_measurement
  counter = Hash.new(0)

  # sp and ep with the same distance are the same cheat
  # in otherwords it doesn't matter how many steps it takes
  # + 15 steps to 0,0 and 3,3 is the same as like 3 steps

  # also keep track of start,endpoint,count because these are teh same cheat
  # each node has a 20 possiblitlies how many count left for the cheat, 
  # and possible end points with said count, we can memoize this 

  counter = Hash.new(0)
  $replacable_blocks_set = Set.new($replacable_blocks)
  $memo = {} # => root => { depth => possible_outcomes }


  path.each do |start_coor|
    # cheats only start if we're connected to a # block
    # we're going to test every adjacent # block 
    # and do a dfs for them to see if they ever reach an endpoint "."
    y, x = start_coor


    queue = Queue.new
    t_queue = Queue.new 
    _visited = Set.new(["#{y},#{x}"])

    DIRECTIONS.each do |vector|
      vy, vx = vector
      ny, nx = [y + vy, x + vx]
      queue << [ny, nx] if $replacable_blocks_set.include?("#{ny},#{nx}") || !!$visitable_points["#{ny},#{nx}"]
    end

    depth = 1
    possible_endpoints = 0
    
    while queue.length > 0 && depth <= 20
      while queue.length > 0 
        _y, _x = queue.pop 
        coord = "#{_y},#{_x}"
        
        next if _visited.include?(coord) 
        
        if !!$visitable_points["#{_y},#{_x}"] 
          sp_dist = $visitable_points["#{y},#{x}"]
          ep_dist = $visitable_points["#{_y},#{_x}"]

          total_distance = (max_distance - sp_dist) + ep_dist + depth
          if total_distance < max_distance
            counter[max_distance - total_distance] += 1 
            possible_endpoints += 1
          end
        end


        _visited << coord 

        DIRECTIONS.each do |vector|
          vy, vx = vector
          ny, nx = [_y + vy, _x + vx]
          _coord = "#{ny},#{nx}"

          next if _visited.include?(_coord)
          t_queue << [ny, nx] if $replacable_blocks_set.include?(_coord) || !!$visitable_points[_coord] 
        end
      end

    
      queue << t_queue.pop  while t_queue.length > 0 
      depth += 1
    end
  end

  count = 0
  counter.to_a.sort_by{|p| p[0]}.each do |p|
    k, v = p

    next if k == 0
    if k >= (!!ENV['TEST'] ? 100 : 50)
      puts "There are #{v} that saves #{k} picoseconds"
      count += v
    end
  end

  count
end

puts solution_2