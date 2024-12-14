require 'set'

PREFIX = "test"
ROW_BOUND = 103 
COL_BOUND = 101

def extract_data
  data = []

  File.open("./#{PREFIX}_data.txt", "r") do |f|
    f.each_line.with_index do |line, idx|
       nums = line.scan(/-?\d+/).map(&:to_i)
       start_pos = [nums[1], nums[0]]
       velocity = [nums[3], nums[2]]
       data << [start_pos, velocity]
    end
    f.close
  end
  data  
end

DATA = extract_data


def get_coordinates(row_bound, col_bound, blinks = 100)
  coordinates = Hash.new(0)

  _data = DATA.map{|v| v.dup }
  _data.each do |d|
    start_pos, velocity = d 

    displacement_r = start_pos[0] + velocity[0] * blinks 
    displacement_c = start_pos[1] + velocity[1] * blinks  
  

    final_x = displacement_r > 0 ? displacement_r % row_bound : row_bound - (displacement_r.abs % row_bound)
    final_y = displacement_c > 0 ? displacement_c % col_bound : col_bound - (displacement_c.abs % col_bound)

    final_x = 0 if final_x == row_bound
    final_y = 0 if final_y == col_bound

    coord = "#{final_x},#{final_y}"

    coordinates[coord] += 1
  end

  coordinates
end


def sol1_math(row_bound, col_bound, blinks = 100)
  coordinates = get_coordinates(row_bound, col_bound, blinks)
  vals = []
  mid_row = row_bound / 2
  mid_col = col_bound / 2

  q1 = [[0, mid_row], [0, mid_col]]
  q2 = [[0, mid_row], [mid_col + 1, col_bound]]
  q3 = [[mid_row + 1, row_bound], [0, mid_col]]
  q4 = [[mid_row + 1, row_bound], [mid_col + 1, col_bound]]


  [q1, q2, q3, q4].each do |quadrant|
    st, ed = quadrant 
    s1, s2 = st 
    e1, e2 = ed 
    t_sum = 0

    while s1 < s2 
      t = e1
      while t < e2 
        coord = "#{s1},#{t}"
        t_sum += coordinates[coord] if coordinates[coord] > 0
        t += 1
      end
      s1 += 1
    end

    vals << t_sum
  end

  vals.inject(1, :*)
end


def validate_coordinates(coordinates, target,  &block) 
  target.each do |coor|
    r1, c1 = coor 
    x = coordinates["#{r1},#{c1}"]
    y = coordinates["#{r1 + 1},#{c1}"]
    z = coordinates["#{r1 + 2},#{c1}"]
    return false unless block.call([x, y, z])
  end

  true 
end

def solution2_v2(row_bound, col_bound, iteration = 0)
  while iteration < 9999 
    coordinates = get_coordinates(row_bound, col_bound, iteration)
    coordinates.each do |k, v|
      r, c = k.split(",").map(&:to_i)
      # check for trunk 

      v0 = [r, c - 1] # should not exist
      v1 = [r, c] # should exist
      v2 = [r, c + 1] # should exist
      v3 = [r, c + 2] # should exist
      v4 = [r, c + 3] # should not exist 


      desired_coordinates = [v1, v2, v3] 
      undesired_coordiates = [v0, v4]

      valid_combination = validate_coordinates(coordinates, desired_coordinates) do |coords| 
        coords.all?{|val| val > 0 } 
      end

      valid_combination &= validate_coordinates(coordinates, undesired_coordiates) do |coords| 
         coords.all?{|val| val == 0 } 
      end

      if valid_combination
        puts "ITERATION = #{iteration}"
       
        (0...row_bound).each do |row|
          str = ""
          (0...col_bound).each do |col|
            coord = "#{row},#{col}"
            str += coordinates[coord] > 0 ? "#" : "."
          end
          puts str
        end

         return iteration
      end
    end

    iteration += 1
  end

  -1
end


puts sol1_math(ROW_BOUND, COL_BOUND)
puts solution2_v2(ROW_BOUND, COL_BOUND, 0)