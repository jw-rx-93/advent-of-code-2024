PREFIX = "test"

def extract_data
  str = ""

  File.open("./#{PREFIX}_data.txt", "r") do |f|
    f.each_line do |line|
      str = line.gsub("\n", "")
    end
    f.close
  end

  str  
end 

DATA = extract_data
ITERATION_LIMIT = 75

def sol1_brute_force(str, iteration = 0)
  return str if iteration == ITERATION_LIMIT
  new_str = ""

  str.split(" ").each do |num_word|
    if num_word == "0"
      new_str += "1 "
    elsif num_word.length % 2 == 0
      s1 = num_word[0...num_word.length / 2].to_i.to_s
      s2 = num_word[(num_word.length/2)..].to_i.to_s
      new_str += "#{s1} #{s2} "
    else 
      new_str += "#{num_word.to_i * 2024} "
    end
  end

  sol1_brute_force(new_str.strip, iteration += 1)
end 

=begin 
 each number is like a node, each node can form more random number of nodes
 at difference depths there are set number of combinations, we just memoize the combinations for each depth
 for example 1 => d1 2024 => d2 =>  so forth
=end

  # we're treating the current number like it is depth 0
  # so we want to check ahead, if not then we can be as greedy as possible 
  # and start branching off at that depth
  # for example i am at a 1 again but I am at depth 8, I only need depth 8
  # memo_table is built backwards from depth

$memo_table = {}

def dfs(number, depth)
  return 1 if depth == 0
  return $memo_table[number][depth] if $memo_table[number] &&  $memo_table[number][depth]

  nodes = []
  if number == "0"
   nodes << "1"
  elsif number.length % 2 == 0
    nodes << number[0...number.length / 2].to_i.to_s
    nodes << number[(number.length/2)..].to_i.to_s
  else 
    nodes << "#{number.to_i * 2024}"
  end


  length = 0
  nodes.each { |num|length += dfs(num, depth - 1)}

  $memo_table[number] ||= {}
  $memo_table[number][depth] = length
  length
end 

def sol1(str)
  total = 0
  str.split(" ").each do |root|
    t = dfs(root, ITERATION_LIMIT)
    $memo_table[root][ITERATION_LIMIT] = t 
    total += t 
  end 
  total 
end 

# puts sol1_brute_force(DATA, 0).split(" ").length
# 233875

puts sol1(DATA)