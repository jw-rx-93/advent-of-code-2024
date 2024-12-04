DIGITS="0123456789"

def extract_data
  open("./test_data.txt").read.gsub(/\s+/, "") 
end 


def increment_indices(base)
  p1 = base 
  p2 = p1 + 1
  p3 = p1 + 2
  p4 = p1 + 3

  [p1, p2, p3, p4]
end

#sliding window solution
def solution1 
  data_str = extract_data
  
  p1, p2, p3, p4 = increment_indices(0)
  accum = 0

  while p4 < data_str.length 
    text = data_str[p1] + data_str[p2] + data_str[p3] + data_str[p4]

    if text == "mul("
      p5 = p4 + 1
      num1 = ""
      num2 = ""
      comma_found = false
      valid = true

      while p5 < data_str.length && data_str[p5] != ")"
        letter = data_str[p5]
     
        if letter == "," && !comma_found
          comma_found = true
        elsif DIGITS.include?(letter)
            !comma_found ? num1 += letter : num2 += letter 
        else
          valid = false
          break
        end
        p5 += 1
      end 

      accum += (num1.to_i * num2.to_i) if valid 
      p1, p2, p3, p4 = increment_indices(p5)
    
    else 
      p1, p2, p3, p4 = increment_indices(p1 + 1)
    end 

  end 

  accum
end


def solution2
  data_str = extract_data
  
  p1, p2, p3, p4 = increment_indices(0)
  accum = 0
  mul_mode = true

  while p4 < data_str.length 
    text = data_str[p1] + data_str[p2] + data_str[p3] + data_str[p4]

    if text == "mul("
      p5 = p4 + 1
      num1 = ""
      num2 = ""
      comma_found = false
      valid = true

      while p5 < data_str.length && data_str[p5] != ")"
        letter = data_str[p5]
     
        if letter == "," && !comma_found
          comma_found = true
        elsif DIGITS.include?(letter)
            !comma_found ? num1 += letter : num2 += letter 
        else
          valid = false
          break
        end
        p5 += 1
      end 

      accum += (num1.to_i * num2.to_i) if valid && mul_mode
      p1, p2, p3, p4 = increment_indices(p5)
    elsif text == "do()"
      p1, p2, p3, p4 = increment_indices(p4 + 1)
      mul_mode = true 
    elsif text == "don'"
      p1, p2, p3, p4 = increment_indices(p4 + 1)
      t2 = data_str[p1] + data_str[p2]+ data_str[p3]
      mul_mode = false if t2 == "t()"
    else 
       p1, p2, p3, p4 = increment_indices(p1 + 1)
    end 
  end 

  accum
end

puts solution1
puts solution2


=begin
 Not much to say. Classic sliding window algorithm. You only need a space of 4, since it encompensates what you need. The only except is don't(),
 but we can temporarily extend the window to check if that is the proper condition to trigger a multiply mode switch, and then proceed as per usual,
 evident by the small amount of changes in solution2.
=end
