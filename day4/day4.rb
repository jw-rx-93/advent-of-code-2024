def extract_data
  matrix = []
  File.open("./test_data.txt", "r") do |f|
    f.each_line do |line|
      chunks = line.gsub("\n", "").split("")
      matrix << chunks
    end
    f.close
  end

  matrix
end

WORDS_MATRIX = extract_data
ROW_COUNT = WORDS_MATRIX.length 
COL_COUNT = WORDS_MATRIX[0].length 
 

def check_diagonal(row, col, r_op, c_op)
  chr1 = WORDS_MATRIX[row][col]
  word_count = 0
  r4 = row + (r_op == "+" ? 3 : -3)
  c4 = col + (c_op == "+" ? 3 : -3)


  # no point if the last char isn't an S or it is out of bound
  if r4 < ROW_COUNT && c4 < COL_COUNT && r4 >= 0 && c4 >= 0 
    chr4 = WORDS_MATRIX[r4][c4]
  
    if chr4 == "S"
      r2 = row + (r_op == "+" ? 1 : -1)
      c2 = col + (c_op == "+" ? 1 : -1)

      r3 = row + (r_op == "+" ? 2 : -2)
      c3 = col + (c_op == "+" ? 2 : -2)

      chr2 = WORDS_MATRIX[r2][c2]
      chr3 = WORDS_MATRIX[r3][c3]

      word_count += ((chr1 + chr2 + chr3 + chr4) == "XMAS" ? 1 : 0)
    end 
  end

  word_count
end 


def check_horizontal(row, col, c_op) 
  chr1 = WORDS_MATRIX[row][col]
  word_count = 0
  c4 = col + (c_op == "+" ? 3 : - 3)

  if c4 >= 0 &&  c4 < COL_COUNT 
    chr4 = WORDS_MATRIX[row][c4]
    if chr4 == "S"
      c2 = col + (c_op == "+" ? 1 : -1)
      c3 = col + (c_op == "+" ? 2 : -2)
      chr2 = WORDS_MATRIX[row][c2]
      chr3 = WORDS_MATRIX[row][c3]

      word_count += ((chr1 + chr2 + chr3 + chr4) == "XMAS" ? 1 : 0)
    end
  end 

  word_count
end 

def check_vertical(row, col, r_op)
  chr1 = WORDS_MATRIX[row][col]
  word_count = 0
  r4 = row + (r_op == "+" ? 3 : - 3)

  if r4 >= 0 && r4 < ROW_COUNT
    chr4 = WORDS_MATRIX[r4][col]

    if chr4 == "S"
      r2 = row + (r_op == "+" ? 1 : -1)
      r3 = row + (r_op == "+" ? 2 : -2)

      chr2 = WORDS_MATRIX[r2][col]
      chr3 = WORDS_MATRIX[r3][col]
      
      word_count += ((chr1 + chr2 + chr3 + chr4) == "XMAS" ? 1 : 0)
    end
  end 

  word_count
end 


def solution1 
  word_count = 0

  WORDS_MATRIX.each_with_index do |rows, i|
    rows.each_with_index do |val, j|
      # top left
      word_count += check_diagonal(i, j, "-", "-")
      # top right 
      word_count += check_diagonal(i, j, "-", "+")
      # bottom left
      word_count += check_diagonal(i, j, "+", "-")
      # bottom right
      word_count += check_diagonal(i, j, "+", "+")
      #left
      word_count += check_horizontal(i, j, "-")
      #right
      word_count += check_horizontal(i, j, "+")
      #top 
      word_count += check_vertical(i, j, "-")    
      #bottom
      word_count += check_vertical(i, j, "+")   
    end
  end

  word_count
end 



def solution2 
  word_count = 0

  WORDS_MATRIX.each_with_index do |rows, row|
    rows.each_with_index do |val, col|
      chr = WORDS_MATRIX[row][col]
      if chr == "A"
        r_top = row - 1
        r_bottom = row + 1

        c_left = col - 1
        c_right = col + 1

        c1 = ""
        c4 = ""
        
        c2 = ""
        c3 = ""

        #top left
        if r_top >= 0 && r_top < ROW_COUNT && c_left >=0  && c_left < COL_COUNT
          c1 = WORDS_MATRIX[r_top][c_left]
        end

        #top right
        if r_top >= 0 && r_top < ROW_COUNT && c_right >=0  && c_right < COL_COUNT
          c2 = WORDS_MATRIX[r_top][c_right]
        end

        # bottom left 
        if r_bottom >= 0 && r_bottom < ROW_COUNT && c_left >=0  && c_left < COL_COUNT
          c3 = WORDS_MATRIX[r_bottom][c_left]
        end

        # bottom right
        if r_bottom >= 0 && r_bottom < ROW_COUNT && c_right >=0  && c_right < COL_COUNT
          c4 = WORDS_MATRIX[r_bottom][c_right]
        end

        if ((c1 == "M" && c4  == "S") || (c1 == "S" && c4 == "M")) && ((c2 == "M" && c3  == "S") || (c2 == "S" && c3 == "M"))
          word_count += 1
        end 
      end
    end
  end

  word_count
end 


puts solution1
puts solution2


=begin
  Basic matrix traversal. For solution 1, you can slightly optimize it by always checking the last character first because there is no point
  if you cannot form XMAS.

  For part 1, I cannot say this is possible but I have a hunch that you can probably try to form paths like a graph when you see any of the characters 
  in XMAS to check if a whole word forms, and once that is done, you can store the combination based on the indices, such that you can skip checking if
  you already seen the combination. But that seems completely overdone for a word search of something with 4 letters, and might actually be more costly 
  in speed, definetely memory. 
=end
