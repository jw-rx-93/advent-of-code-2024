require 'set'
PREFIX = "test"

def extract_data
  data = []

  File.open("./#{PREFIX}_data.txt", "r") do |f|
    f.each_line do |line|
      chunks = line.gsub("\n", "").split("")
      data << chunks
    end
    f.close
  end

  data
end 


DATA = extract_data
$pos = Set.new([]) #to track positions where antinode is already created so we don't double count overlaps


def populate_ref_table 
  $ref = {} 
  DATA.each_with_index do |row, i|
    row.each_with_index do |val, j|
      next if val == "."
      $ref[val] = [] if !$ref[val] 
      $ref[val] << [i, j]
    end 
  end
end 

def validate_position(x, y, node_type)
  valid = false
  if x >= 0 && x < DATA.length && y >= 0 && y < DATA.first.length 
    val = DATA[x][y]
    valid = true 
    if val != node_type 
      $pos.add("#{x},#{y}")
    end
  end

  valid 
end 

def solution1
  populate_ref_table
  $ref.each do |node_type, nodes| 
    i = 0 
    while i < nodes.length 
      j = i + 1 # we want to check subsequent nodes because we already seen previous node, calculations were done
      curr_row, curr_col = nodes[i]

      while j < nodes.length
        row, col = nodes[j] 
        x_diff = row - curr_row
        y_diff = col - curr_col

        validate_position(curr_row + (-1*x_diff), curr_col + (-1*y_diff), node_type) 
        validate_position(row + x_diff, col + y_diff, node_type)

        j += 1
      end
      i += 1
    end
  end
  
  print $pos.to_a.length, "\n"
end 

def solution2
  populate_ref_table
  $ref.each do |node_type, nodes| 
    i = 0 
    while i < nodes.length 
      j = i + 1 # we want to check subsequent nodes because we already seen previous node, calculations were done
      curr_row, curr_col = nodes[i]

      if nodes.length > 0 
        nodes.each do |x, y|
          $pos.add("#{x},#{y}")
        end
      end

      while j < nodes.length
        row, col = nodes[j] 
        x_diff = row - curr_row
        y_diff = col - curr_col

        multiplier = 1 
        v1 = true
        v2 = true 

        while v1 || v2 
          v1 = validate_position(curr_row + (-1*multiplier*x_diff), curr_col + (-1*multiplier*y_diff), node_type) 
          v2 = validate_position(row +  multiplier*x_diff, col + multiplier*y_diff, node_type)
          multiplier += 1
        end


        j += 1
      end
      i += 1
    end
  end  
  print $pos.to_a.length, "\n"
end 

solution1
solution2


=begin
  While there are implications that this is some sort of matrix traveral problem, it really isn't. All you have to do is gather all the coordinates
  and do some math on the coordinates. 

  I used a set to keep track of the coordinates I seen in order to prevent double counting, but you could also just overwite the value 
  at the coordinate with something extra, and using a parsing to check so you can avoid the extra memory usage.
=end