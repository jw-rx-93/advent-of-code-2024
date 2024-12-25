require 'set'

def extract_data
  locks = []
  keys = []
  file_name = !!ENV['TEST'] ? 'test_data.txt' : 'sample_data.txt'
  File.open(file_name) do |f|
    temp = [0, 0, 0, 0, 0]
    prev_line = []

    f.each_line do |line|
      line_split = line.gsub("\n", "").split("")
      
      if line_split.length < 5
        prev_line.all?{|v| v == "."} ? locks.push(temp) : keys.push(temp)
        temp = [0, 0, 0, 0, 0]
        next 
      end 

      line_split.each_with_index { |v, idx| temp[idx] += 1 if v == "#" }
      prev_line = line_split
    end

    if temp.any?{|v| v > 0}
      prev_line.all?{|v| v == "."} ? locks.push(temp) : keys.push(temp)
    end

    f.close
  end

  [Set.new(keys).to_a, Set.new(locks).to_a]
end



def solution_1 
  keys, locks = extract_data  
  count = 0

  keys.each do |key|
    locks.each do |lock|
      weight = lock.map.with_index {|v, idx| v + key[idx] }
      count += 1 if weight.all?{|v| v < 8 } 
    end
  end

  count
end

puts solution_1