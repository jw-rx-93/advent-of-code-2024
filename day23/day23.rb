require 'set'


def extract_data
  h = Hash.new([])
  File.open("test_data.txt") do |f|
    f.each_line do |line|
      line = line.gsub("\n", "")
      chunks = line.split("-")
      if chunks.length > 0 
        h[chunks[0]] += [chunks[1]]
        h[chunks[1]] += [chunks[0]]
      end
    end
    f.close
  end
  h
end


def dfs_1(current_val, start_val, path, depth)
  values = $ref_table[current_val]

  if depth == 0
    # means we found a circular thingy
    $seen_paths << path.sort.join(",") if values.include?(start_val) 
    return 
  end

  values.each do |v|
    next if path.include?(v)
    t = path.dup 
    t << v
    dfs_1(v, start_val, t, depth - 1)
  end
end

def solution1
  $ref_table = extract_data
  $seen_paths = Set.new()

  $ref_table.each do |k, v|
    dfs_1(k, k, [k], 2)
  end
  # print $seen_paths, "\n"
  # print $seen_paths.length, "\n"

  count = 0 
  $seen_paths.each do |path|
    vals = path.split(",")
    count += 1 if vals.any?{|v| v.start_with?("t")}
  end
  count
end


def solution2
  $ref_table = extract_data

  valid_points = []
  patterns = Hash.new(0)

  $ref_table.each do |k, connections|
    matches = Set.new(connections + [k])
    freq = Hash.new()

    connections.each do |_k|
      sub_connections = $ref_table[_k]
      pattern = []
      sub_connections.each do |_connection|
        pattern << _connection  if matches.include?(_connection)
      end

      freq[pattern.length] ||= Set.new()
      pattern.each { |p| freq[pattern.length] << p }
    end

    _p = freq.to_a.sort_by{|p| p.last.size }.last 
    key = _p.last.to_a.sort.join(",")
    patterns[key] += 1
  end

  patterns.to_a.sort_by{|p| p.last }.last
end

# puts solution1
puts solution2


