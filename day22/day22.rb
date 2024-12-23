
require 'set'


def extract_data 
  data = []
  File.open("#{!!ENV["TEST"] ? "test" : "sample"}_data.txt") do |f|
    f.each_line do |line|
      data << line.gsub("\n", "").to_i
    end
    f.close
  end
  # print data, "\n"
  data
end

def run_math(num)
  num = num ^ (num * 64)
  num = num % 16777216

  num = num ^ (num / 32) 
  num = num % 16777216

  num = num ^ (num * 2048) 
  num = num % 16777216
end


def solution1
  data = extract_data
  sum = 0
  data.each do |num|
    v = num
    2000.times do
      v = run_math(v)
    end
    sum += v
  end

  sum
end

$frequency_table = Hash.new(0)

def solution2 
  data = extract_data

  data.each do |num|
    v = num 
    seen = Set.new
    prev_val = num % 10
    seq = [] # sliding window

    2000.times do 
      v = run_math(v)
      curr_val = v % 10

      seq_val = curr_val - prev_val
      seq << seq_val
      #ruby shift is optimized to be ~ O(1) on average, use a queue if you are using other lingos
      seq.shift if seq.length > 4 
      seq_key = seq.join(",")
      
      if seq.length == 4 && !seen.include?(seq_key)
        $frequency_table[seq_key] += curr_val
        seen << seq_key
      end

      prev_val = curr_val
    end
  
  end

  $frequency_table.to_a.sort_by{|v| v.last}.last
end

# puts solution1

print solution2
