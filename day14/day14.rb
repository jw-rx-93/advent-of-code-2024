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



def solution2(row_bound, col_bound, iteration = 0)
  while iteration < 9999
    coordinates = get_coordinates(row_bound, col_bound, iteration)
    table = []
    (0...row_bound).each_with_index do |_, i|
      t = []
      (0...col_bound).each_with_index do |_, j|
        t.push(coordinates["#{i},#{j}"] > 0 ? "#" : ".")
      end
      table << t 
    end 


    table.each_with_index do |row, i|
      t = 0

      row.each_with_index do |v, j| 
        if v == "#"
          t += 1
        elsif t == 3
          # check row above
          # check bottom two 
          # we're checking for the trunk

          v0 = [i, j - 4]
          v1 = [i, j - 3]
          v2 = [i, j - 2]
          v3 = [i, j - 1]
          v4 = [i, j]

          if (i + 2) < table.length  && j >= 4
            str0 = ""
            str1 = ""
            str2 = "" 
            
            [v0, v1, v2, v3, v4].each do |coor|
              r, c = coor 
              str0 += table[r][c]
              str1 += table[r + 1][c]
              str2 += table[r + 2][c]
            end

            if str0 == ".###." && str0 == str1 && str0 == str2
              puts "ITERATION = #{iteration}"
              table.each { |row| puts row.join("") }
              return 
            end
          end

          t = 0 # cuz this only breaks if current isn't a #
        else 
          t = 0
        end 
      end
    end 

    iteration += 1
  end
end


puts sol1_math(ROW_BOUND, COL_BOUND)
puts solution2(ROW_BOUND, COL_BOUND, 8000)