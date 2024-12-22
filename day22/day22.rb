
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
    local_freq = Hash.new(0)
    prev_val = num % 10
    seq = []

    2000.times do 
      v = run_math(v)
      curr_val = v % 10

      seq_val = curr_val - prev_val
      seq << seq_val
      seq.shift if seq.length > 4 

      # multiple same frequency can appear, but we want to take the one with the higest weight
      # this guarantees only unique sequences with the max values
      seq_key = seq.join(",")
      local_freq[seq_key] = curr_val if seq.length == 4 && local_freq[seq_key] == 0
      prev_val = curr_val
    end
    local_freq.each {|k, v| $frequency_table[k] += v }
  end

  $frequency_table.to_a.sort_by{|v| v.last}.last
end

# puts solution1

# print solution2
