require 'set'

PREFIX = "test"

$pos = [0,0]
$original_pos = [0, 0]
$dir = "up"
$combination = ""
$sol_count = 0;
$map = []

def extract_data
  data_matrix = []

  File.open("./#{PREFIX}_data.txt", "r") do |f|
    f.each_line.with_index do |line, idx|
      row = line.gsub("\n", "").split("")
      j_idx = row.find_index("^")
      
      if !j_idx.nil?
        $pos = [idx, j_idx] 
        $original_pos = [idx, j_idx]
      end

      data_matrix << row   
    end
    f.close
  end 

  data_matrix
end

MAP = extract_data
MAP_ROW_BOUND = MAP.length
MAP_COL_BOUND = MAP.first.length
DIRECTIONAL_SWAP = {
  "up" => "right",
  "right" => "down",
  "down" => "left",
  "left" => "up"
}

def deep_dupe(mainMap = MAP)
  map = []
  mainMap.each do |row|
    map << row.dup 
  end
  map
end


def reset_globals
  $pos = $original_pos.dup
  $dir = "up"
  $combination = ""
end


def evaluate_next_step(next_pos, inc = true)
  row = next_pos.first 
  col = next_pos.last

  if (row < 0 || row >= MAP_ROW_BOUND) || (col < 0 || col >= MAP_COL_BOUND)
    $sol_count+= 1 if inc
    $combination = ""
    return false 
  end


  value = $map[row][col]

  case value 
  when ".", "O"
    $sol_count+= 1 if inc
    $pos = next_pos 
    $map[$pos.first][$pos.last] = "X"
    $combination = "#{$pos.first},#{$pos.last},#{$dir}"
  when "#"
    $dir = DIRECTIONAL_SWAP[$dir]
    $combination = ""
  when "X" 
    $pos = next_pos 
    $combination = "#{$pos.first},#{$pos.last},#{$dir}"
  end 
  
  true
end  


def solution1 
  reset_globals
  $map = deep_dupe
  $map[$original_pos.first][$original_pos.last] = "X"
  in_progress = true 

  while in_progress
    next_pos = $pos 
  
    case $dir 
    when "up"
      next_pos = [next_pos.first - 1, next_pos.last]
    when "right"
      next_pos = [next_pos.first, next_pos.last + 1]  
    when "down"
      next_pos = [next_pos.first + 1, next_pos.last]
    when "left"
      next_pos = [next_pos.first, next_pos.last - 1]
    end

    in_progress = evaluate_next_step(next_pos)
  end
  
  $sol_count
end   
 

def solution2 
  $sol_count = 0
  mainMap = deep_dupe($map)

  mainMap = mainMap.map do |row|
    row.map {|val|  val == "X" ? "O" : val }
  end

  mainMap.each_with_index do |row, i|
    row.each_with_index do |val, j|
      if val == "O"
        reset_globals
        $map = deep_dupe(mainMap)

        $map[i][j] = "#"
        $map[$pos.first][$pos.last] = "X"
        directionComb = Set.new(["#{$pos.first},#{$pos.last},#{$dir}"])

        in_progress = true 

        while in_progress
          next_pos = $pos 
        
          case $dir 
          when "up"
            next_pos = [next_pos.first - 1, next_pos.last]
          when "right"
            next_pos = [next_pos.first, next_pos.last + 1]  
          when "down"
            next_pos = [next_pos.first + 1, next_pos.last]
          when "left"
            next_pos = [next_pos.first, next_pos.last - 1]
          end

          in_progress = evaluate_next_step(next_pos, false)

          if directionComb.include?($combination)
            $sol_count += 1
            break
          elsif $combination.length.positive?
            directionComb.add($combination)
          end
        end
      end 
    end
  end 

  $sol_count
end 


puts solution1
puts solution2


=begin
  Solution 1 is straightforward, we just move accordingly to our direction, and rotate as needed (made easy using a map to chain the directions).

  Solution 2 is an expansion of the first solution, and actually dependent on the first solution to be solved. I replaced the values of our path on the map
  with O because those are markers for relevant points to experiment adding a blocker to; We don't need to test everypoint, we just need to test the points
  we know our guard would definitely take. The 2nd thing to check for is whether we arrived to a previously visted point in the same direction, if so it means
  we are going to repeat the pattern, so you don't even have to check for path patterns. Even so it is still rather slow since it's an O(n*m) solution
=end