def extract_data
  matrix = []

  File.open("./test_data.txt", "r") do |f|
    f.each_line do |line|
      chunks = line.split(" ")
      chunks = chunks.map(&:to_i)
      matrix << chunks
    end
    f.close
  end

  matrix
end

def sol_arr_proc(arr, &block)
  arr.each_with_index do |curr_num, idx|
      next if idx == 0
      prev_num = arr[idx - 1]
      bool = block.call(curr_num, prev_num)
      return idx if bool
  end
  -1  
end

def dec_or_inc?(arr)
  if arr[0] < arr[1]
    sol_arr_proc(arr) {|v1, v2| v1 <= v2 }
  else 
    sol_arr_proc(arr) {|v1, v2| v2 <= v1 }
  end 
end 

def safe_adjacent?(arr)
  arr.each_with_index do |curr_num, idx|
    next if idx == 0
    prev_num = arr[idx - 1]
    diff = (curr_num - prev_num).abs 
    return idx if diff > 3
  end

  -1
end 

def solution1
  data = extract_data
  good_report_count = 0
  data.each do |report|
    next unless dec_or_inc?(report) == -1
    next unless safe_adjacent?(report) == -1
    good_report_count += 1
  end 

  good_report_count
end


def create_removed_index_arr(array, skip_idx)
  new_arr = []
  array.each_with_index do |val, idx|
    next if idx == skip_idx
    new_arr << val 
  end 

  new_arr
end

def solution2
  data = extract_data 
  good_report_count = 0

  data.each do |report|
    idx = dec_or_inc?(report)
    if idx > -1 
      damped_report_2 = create_removed_index_arr(report, idx-1)
      next unless  dec_or_inc?(damped_report_2) == -1
    end 
    
    idx = safe_adjacent?(report)
    if idx > -1 
      damped_report_2 = create_removed_index_arr(report, idx - 1)
      next unless safe_adjacent?(damped_report_2) == -1
    end 

    good_report_count += 1
  end 

  good_report_count
end 


puts solution1
puts solution2

=begin
  Nothing special here, we just loop through the arrays to check for inc / dec patterns, 
  and then check whether the differences between the current value and the previous value is greater than 3.

  The only issue is, initially for solution 2, I used the dampener for both indices that are incompatible 
  and the count is alot higher than the solution. In my mind, we know the current number is imcompatible
  with a previous value, but we don't know which is the one with the problem, so it's best to check both, however it seems
  the solution only accepts the previous value for removal.
=end