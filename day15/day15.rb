require 'benchmark'
require 'set'

PREFIX = "test"

def extract_data
  table = []
  start_pos = []
  File.open("#{PREFIX}_data.txt") do |f|
    f.each_line.with_index do |line, i| 
      line_chunks = line.gsub("\n", "").split("")
      
      if line.include?("@")
         j = line_chunks.index("@")
         start_pos = [i, j]
      end

      table << line_chunks
    end

    f.close
  end

  [table, start_pos]
end

def extract_instructions 
  instructions = ""
  File.open("#{PREFIX}_instructions.txt") do |f|
    f.each_line {|line| instructions += line.gsub("\n", "") }
    f.close 
  end
  instructions
end


DATA, START_POS = extract_data
INSTRUCTIONS = extract_instructions


def get_movement(dir)
  {
    "^" => [-1, 0],
    "<" => [0, -1],
    ">" => [0, 1],
    "v" => [1, 0]
  }[dir]
end

def update_chain_positions(_MAP, pos, dir)
  # recursively loop down to the last "O" to see if position is updateable
  y, x = dir 
  c_y, c_x = pos 
  n_y, n_x = [c_y + y, c_x + x]
  next_val =  _MAP[n_y][n_x]

  if next_val == "." 
    _MAP[c_y][c_x], _MAP[n_y][n_x] = _MAP[n_y][n_x], _MAP[c_y][c_x]
    return [n_y, n_x]
  elsif next_val == "O" || next_val == "[" || next_val == "]"
    new_O_pos = update_chain_positions(_MAP, [n_y, n_x], dir)
    if new_O_pos != [n_y, n_x]
      _MAP[c_y][c_x], _MAP[n_y][n_x] = _MAP[n_y][n_x], _MAP[c_y][c_x]
      return new_O_pos
    end
  end

  [c_y, c_x]
end

def solution1 
  # we need these for sol 2 later, 
  # so it's best not to manipulate the base data directly
  current_pos = START_POS.dup 
  _MAP = DATA.map{|row| row.dup }

  # we can skip instructions if a movement is denied 
  i = 0

  while i < INSTRUCTIONS.length
    dir = INSTRUCTIONS[i]    

    y, x = get_movement(dir)
    curr_y, curr_x = current_pos
    movement = false 

    next_y, next_x = [curr_y + y, curr_x + x]
    next_val = _MAP[next_y][next_x]
    # if next val == # we do nothing

    if next_val == "."
      _MAP[curr_y][curr_x], _MAP[next_y][next_x] = _MAP[next_y][next_x], _MAP[curr_y][curr_x]
      current_pos = [next_y, next_x]  
      movement = true 
    elsif next_val == "O"
      new_O_pos = update_chain_positions(_MAP, [next_y, next_x], [y, x])
      if [next_y, next_x] != new_O_pos
        _MAP[curr_y][curr_x], _MAP[next_y][next_x] = _MAP[next_y][next_x], _MAP[curr_y][curr_x]
        current_pos = [next_y, next_x]  
        movement = true 
      end 
    end

    i += 1
    i += 1 while !movement && i < INSTRUCTIONS.length && INSTRUCTIONS[i] == dir 
  end

  sum = 0
  _MAP.each_with_index do |r, i| 
    print r.join(""), "\n"
    r.each_with_index do |c, j|
      if c == "O"
        sum += ((100 * i) + j)
      end
    end
  end
  sum
end

def form_solution_2_map 
  _MAP = []
  start_pos = [0, 0]
  DATA.each_with_index do |row, i|
    new_row = []
    row.each do |val|
      case val 
      when "#", "."
        new_row.concat [val, val]
      when "@"
        start_pos = [i, new_row.length]
        new_row.concat [val, "."]
      when "O"
        new_row.concat ["[", "]"]
      end
    end
    _MAP << new_row
  end
  
  [_MAP, start_pos]
end


def validate_movement_possible(_MAP, left_pos, right_pos, dir)
  # for up and down for the brackets,
  # we need to do chain increments to see 
  # we ARE always looking at [] combination because we are treating both like single node
  t1 = _MAP[left_pos[0]][left_pos[1]]
  t2 = _MAP[right_pos[0]][right_pos[1]]

  return true if $coordinates.include?([left_pos, right_pos])

  $coordinates.add([left_pos, right_pos])

  y, x = dir
  y1, x1 = left_pos 
  y2, x2 = right_pos 


  n_y1, n_x1 = [y1 + y, x1 + x]
  n_y2, n_x2 = [y2 + y, x2 + x]

  v1 = _MAP[n_y1][n_x1]
  v2 = _MAP[n_y2][n_x2]
  t = true

  if v1 == "." && v2 == "."
    t = true 
  elsif v1 == "#" || v2 == "#"
    t = false 
  elsif v1 + v2 == "[]"
    t = validate_movement_possible(_MAP, [n_y1, n_x1], [n_y2, n_x2], dir) 
  elsif v1 + v2 == "]["  
    t = validate_movement_possible(_MAP, [n_y1, n_x1 - 1], [n_y1, n_x1], dir) && 
      validate_movement_possible(_MAP, [n_y2, n_x2], [n_y2, n_x2 + 1], dir)
  elsif v1 == "]"
    t = validate_movement_possible(_MAP, [n_y1, n_x1 - 1], [n_y1, n_x1], dir)
  elsif v2 == "["
    t = validate_movement_possible(_MAP, [n_y2, n_x2], [n_y2, n_x2 + 1], dir)
  end

end


def solution2 
  _MAP, current_pos = form_solution_2_map
  i = 0

  while i < INSTRUCTIONS.length
    dir = INSTRUCTIONS[i]    

    y, x = get_movement(dir)
    curr_y, curr_x = current_pos
    movement = false 

    next_y, next_x = [curr_y + y, curr_x + x]
    next_val = _MAP[next_y][next_x]
    # if next val == # we do nothing

    if next_val == "."
      _MAP[curr_y][curr_x], _MAP[next_y][next_x] = _MAP[next_y][next_x], _MAP[curr_y][curr_x]
      current_pos = [next_y, next_x]  
      movement = true 
    elsif ["[", "]"].include?(next_val) && ["<", ">"].include?(dir)
      new_O_pos = update_chain_positions(_MAP, [next_y, next_x], [y, x])
      if [next_y, next_x] != new_O_pos
        _MAP[curr_y][curr_x], _MAP[next_y][next_x] = _MAP[next_y][next_x], _MAP[curr_y][curr_x]
        current_pos = [next_y, next_x]  
        movement = true 
      end 
    elsif ["[", "]"].include?(next_val) # up and down has special rules to do overlapping
      $coordinates = Set.new([])
      left_coor = next_val == "[" ? [next_y, next_x] : [next_y, next_x - 1]
      right_coor = next_val == "[" ? [next_y, next_x + 1] : [next_y, next_x]

      is_possible = validate_movement_possible(_MAP, left_coor, right_coor, [y, x])

      if is_possible
        #sort by greatest or least depending on direction
        t = $coordinates.to_a
        t.sort_by!{|coord| coord[0][0]}
        t.reverse! if dir == "v" 

        t.each do |coor_pairs|
          p1, p2 = coor_pairs
          y1, x1 = p1 
          y2, x2 = p2 

          _MAP[y1][x1], _MAP[y1 + y][x1] = _MAP[y1 + y][x1], _MAP[y1][x1]
          _MAP[y2][x2], _MAP[y2 + y][x2] = _MAP[y2 + y][x2], _MAP[y2][x2]
        end

        _MAP[curr_y][curr_x], _MAP[next_y][next_x] = _MAP[next_y][next_x], _MAP[curr_y][curr_x]
        current_pos = [next_y, next_x]  
        movement = true 
      end
    end

    i += 1
    i += 1 while !movement && i < INSTRUCTIONS.length && INSTRUCTIONS[i] == dir 
  end

  sum = 0
  _MAP.each_with_index do |r, i| 
    print r.join(""), "\n"
    r.each_with_index do |c, j|
      if c == "["
        sum += ((100 * i) + j)
      end
    end
  end
  sum  
end



# t = Benchmark.measure { puts solution1 }
# puts t.real

puts solution2