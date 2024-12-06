require 'set'

PREFIX = "test"

def extract_data_keys
  keys = Hash.new()

  File.open("./#{PREFIX}_data_keys.txt", "r") do |f|
    f.each_line do |line|
      chunks = line.gsub("\n", "").split("|")
      keys[chunks[0].to_i] = Set.new() if !keys[chunks[0].to_i]
      keys[chunks[0].to_i].add(chunks[1].to_i)
    end
    f.close
  end

  keys
end 


def extract_data 
  data = []
  File.open("./#{PREFIX}_data.txt", "r") do |f|
    f.each_line do |line|
      chunks = line.gsub("\n", "").split(",")
      data << chunks.map(&:to_i)
    end
    f.close
  end

  data
end 

KEYS = extract_data_keys
DATA = extract_data


def solution1 
  sum = 0 

  DATA.each do |row|
    valid = true 
    row.each_with_index do |num, idx| 
      next_idx = idx + 1
      ref = KEYS[num]
      KEYS[num] = Set.new if !ref 

      while next_idx < row.length 
        next_num = row[next_idx]
        unless ref.include?(next_num)
          valid = false 
          break
        end
        next_idx += 1
      end 

      break if !valid
    end
    
    if valid 
      sum += row[(row.length - 1) / 2]
    end 
  end 

  sum
end 


def solution2
  sum = 0 

  DATA.each do |row|
    valid = true 
    fixed = false
    
    idx = 0 

    while idx < row.length 
      num = row[idx]
      next_idx = idx + 1
      ref = KEYS[num]
      KEYS[num] = Set.new if !ref 

      while next_idx < row.length 
        next_num = row[next_idx]
        unless ref.include?(next_num)
          valid = false 
          break
        end
        next_idx += 1
      end 

      if !valid
        # attempt to fix row, and 
        valid = true
        fixed = true
        row[next_idx], row[idx] = row[idx], row[next_idx]
      else 
        idx+=1
      end 
    end 

    
    if valid && fixed
      sum += row[(row.length - 1) / 2]
    end 
  end 

  sum
end

print solution1
print solution2

=begin
  Solving this is straight forward if we have lookup (hash) tables. In this case, by having a number referencing a set of number, as we interate through each number
  we can do O(1) operations to check whether a current number is aligned properly. So essentially we downgraded the problem to O(n) solution. There was no need to check previous numbers
  simply because if a previous number didn't aligned, it would'be meant the whole array is invalidated.

  For the 2nd solution, the function is still essentially the same, the only major difference is that we are looking for invalid arrays, and then trying to fix them. With the example 
  provided, do not assume 1 swap is enough to fix the array, we would have to keep retrying until it is valid; the reason we can keep retrying is because the problem implies that each
  array can be fixed meaning there is a combination that exist for each array. Effectively we are doing a permutation with the retries, but because we are dealing with a small
  finite data set per row, it is acceptable, and you might as well can considered it a constant  
=end