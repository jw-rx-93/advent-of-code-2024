require 'set'

NUMPAD = [
  [7, 8, 9],
  [4, 5, 6],
  [1, 2, 3],
  [nil, 0, 'A']
]

KEYPAD = [
  [nil, '^', 'A'],
  ["<", "v", ">"]
]

$num_pad = {}
$key_pad = {}

NUMPAD.each_with_index do |row, i|
  row.each_with_index { |val, j| $num_pad[val] = [i, j] }
end

KEYPAD.each_with_index do |row, i|
  row.each_with_index {|val, j| $key_pad[val] = [i, j]}
end

def extract_data
  prefix = !!ENV["TEST"] ? "test" : "sample"
  data = []
  File.open("#{prefix}_data.txt") do |f|
    f.each_line do |line|
      data = line.gsub("\n", "").split(",")
    end
    f.close
  end

  data
end

$displacement_memo = {}

def calculate_displacement_movements(coors)
  y, x = coors 
  key = "#{y}:#{x}"
  return $displacement_memo[key] if !!$displacement_memo[key]
  str = ""

  while y != 0
    str += (y < 0 ? '^' : 'v')
    y += (y < 0 ? 1 : -1)
  end

  while x != 0
    str += (x < 0 ? '<' : '>')
    x += (x < 0 ? 1 : -1)
  end

  v = str.split("").permutation.map(&:join)
  v = Set.new(v).to_a
  $displacement_memo[key] = v
  v
end

def legal_movement?(movement, coor, base)
  y, x = coor.dup
  illegal_coor = base ? [3, 0] : [0, 0]
  movement.split("").each do |dir|
    case dir 
    when "^"
      y -=1
    when "v"
      y += 1
    when ">"
      x += 1
    when "<"
      x -= 1
    end

    return false  if [y, x] == illegal_coor
  end

  true
end


def get_least_resistive_paths(arr)
  movement_hash = {}

  arr.each do |_code|
      p1, p2 = [0, 1]

      t_code = "A" + _code 

      total_displacement = 0

      while p2 < _code.length
        c1 = _code[p1]
        c2 = _code[p2]

        #manhattan distancing to calculate displacement of two keys,
        #which coincidentally is the movement count as well
        #so the less movements means better outcome

        y1, x1 = $key_pad[c1]
        y2, x2 = $key_pad[c2]

        total_displacement += (y2 - y1).abs + (x2 - x1).abs

        p1 += 1
        p2 += 1
      end  

      movement_hash[total_displacement] ||= []
      movement_hash[total_displacement] << _code
    end
    min_key = movement_hash.keys.min
    arr = movement_hash[min_key]
end



def code_dfs(code, index, curr_coor, base = false)
  return [[]] if index >= code.length 

  val = code[index]
  val = val.to_i if val != 'A'
  val_coor = $num_pad[val]

  displacement = [val_coor[0] - curr_coor[0], val_coor[1] - curr_coor[1]]    
  possible_routes = calculate_displacement_movements(displacement)
  #filter out illegal movements
  possible_routes = possible_routes.select {|val| legal_movement?(val, curr_coor, base)}

  res = []
  paths = get_least_resistive_paths(possible_routes)
  res << paths
  
  other_paths = code_dfs(code, index + 1, val_coor, base)
  other_paths.each do |_paths|
    res << _paths if _paths.length > 0
  end
  res
end

def dfs_memo(seq, depth)
  # puts seq
  return seq.length if depth == 0
  return $memo[seq][depth] if $memo[seq] && $memo[seq][depth]

  curr_coor = [0, 2] # this is A for keyboard, we'll assume we start off from an A
  new_sequences = []

  seq.split("").each do |char|
    val_coor = $key_pad[char]
    displacement = [val_coor[0] - curr_coor[0], val_coor[1] - curr_coor[1]]    
    possible_routes = calculate_displacement_movements(displacement)
    possible_routes = possible_routes.select {|val| legal_movement?(val, curr_coor, false)}
    paths = get_least_resistive_paths(possible_routes)

    new_sequences << paths 
    curr_coor = val_coor 
  end

  min_length = 0 
  new_sequences.each do |_seq|
     possible_lengths = []

    _seq.map{|v| v + "A" }.each do |_sub_seq|
      possible_lengths << dfs_memo(_sub_seq, depth - 1)  
    end

    min_length += possible_lengths.min
  end

  # print possible_lengths, "\n"

  $memo[seq] ||= {}
  $memo[seq][depth] = min_length
  min_length
end

def solution(depth)
  data = extract_data
  sum = 0

  $memo = {}

  data.each do |d|
     seq = code_dfs(d, 0, [3, 2], true)
     
     length = 0
     seq.each do |inner_seq|
        possible_lengths = []
        
        inner_seq.map{|v| v + "A" }.each do |_seq|
          possible_lengths << dfs_memo(_seq, depth)
        end

        length += possible_lengths.min 
     end

     puts length
     sum += (d.gsub("A", "").to_i * length)
  end

  sum
end


puts solution(25)
