PREFIX = "test"

def extract_data
  table = []

  File.open("./#{PREFIX}_data.txt", "r") do |f|
    t = []
    f.each_line.with_index do |line, idx|
      nums = line.scan(/\d+/).map(&:to_i)

      if line.include?("Button A")
        nums << 'A'
        t << nums 
      elsif line.include?("Button B")
        nums << 'B'
        t << nums 
      elsif line.include?("Prize")
        t << nums 
        table << t 
      else 
        t = []
      end
    end
    f.close
  end

  table
end 

DATA = extract_data
CORRECTION = 10000000000000 


def greedy_cal1(t1 , t2, x_max, y_max)
  clicks = {}

  x = x_max / t1[0]
  y = y_max / t1[1]

  accum_x = 0
  accum_y = 0

  if x > y
    accum_x = t1[0] * y
    accum_y = t1[1] * y
    clicks[t1[2]] = y
  else
    accum_x = t1[0] * x
    accum_y = t1[1] * x
    clicks[t1[2]] = x
  end

  clicks[t2[2]] = 0

  if clicks[t1[2]] > 100 
    diff = clicks[t1[2]] - 100
    clicks[t1[2]] = 100
    accum_x -= t1[0] * diff 
    accum_y -= t1[1] * diff
  end

  while (accum_x != x_max || accum_y != y_max) && clicks[t1[2]] <= 100 && clicks[t2[2]] <= 100
    projected_x = accum_x + t2[0]
    projected_y = accum_y + t2[1]
    
    if projected_x > x_max || projected_y > y_max 
      accum_x -= t1[0]
      accum_y -= t1[1]
      clicks[t1[2]] -= 1
    else 
      accum_x += t2[0]
      accum_y += t2[1]
      clicks[t2[2]] += 1
    end
  end
  
  return Float::INFINITY if clicks[t1[2]] > 100 || clicks[t2[2]] > 100
  total = clicks['A'] * 3 + clicks['B']
  total
end



def solution1
  total = 0
  DATA.each do |dataset|
    t1, t2, maxes = dataset
    d1 = greedy_cal1(t1, t2, maxes[0], maxes[1])
    total += d1 if d1 != Float::INFINITY
  end
  total
end



def solution2
  total = 0
  DATA.each do |dataset|
    t1, t2, maxes = dataset
    #linear algebra 
    a1, b1 = t1 
    a2, b2 = t2 
    m1, m2 = maxes 

    m1 += CORRECTION
    m2 += CORRECTION

    y_count = (a1 * m2 - b1 * m1).to_f / (a1 * b2 - b1 * a2)
    x_count = (m1 - a2 * y_count).to_f / a1

    if y_count.ceil == y_count && x_count.ceil == x_count
      total +=  x_count * 3 + y_count
    end
  end
  total
end

#puts solution
puts solution2
