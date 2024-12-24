
require 'benchmark'
require 'set'

def extract_data
    codes = {}
    operations = []
    file_name = !!ENV['TEST'] ? "test_data.txt" : "sample_data.txt"
    File.open(file_name) do |f|
      f.each_line do |line|
        line = line.gsub("\n", "").gsub("->", "")
        next if line.length == 0

        if line.include?(":")
          line = line.gsub(":", "")
          split_line = line.split(" ")
          codes[split_line[0]] = split_line[1].to_i
        else
          split_line = line.split(" ")
          # code1, code2, operation, and code3
          operations << [split_line[0], split_line[2], split_line[1], split_line.last]
        end
      end
      f.close
    end

  [codes, operations]
end


def solution_1
  codes, operations = extract_data
  queue = Queue.new 
  operations.each {|op| queue << op }
  i = 0
  while queue.size > 0
    v1, v2, op, v3 = queue.pop 
  
    if codes[v1].nil? || codes[v2].nil?
      queue << [v1, v2, op, v3]
      next
    else 
      print [codes[v1], codes[v2]], "\n"
      case op 
      when 'AND'
        cal = codes[v1] & codes[v2] 
      when 'OR'
        cal = codes[v1] | codes[v2]
      when 'XOR'
        cal = codes[v1] ^ codes[v2] 
      end 
     
      codes[v3] = cal
    end
    
    i+= 1
  end

  bin_str = ""
  x_str = ""
  y_str = ""

  codes.to_a.sort.each do |arr|
    k, v = arr 
    print "#{k} => #{v}\n"
    bin_str += v.to_s if k.start_with?("z")
    if k.start_with?("x")
      _k = "y" + k.gsub("x", "")
      _v = codes[_k]
      x_str += v.to_s 
      y_str += _v.to_s
    end
  end

  actual_binary = (x_str.reverse.to_i(2) + y_str.reverse.to_i(2)).to_s(2)
  bin_str = bin_str.reverse
  # puts actual_binary
  # puts bin_str

  t = actual_binary.length - 1
  mismatches = []
  actual_binary.split("").each_with_index do |v, i|

    if v != bin_str[i]
      # print "[#{v},#{bin_str[i]}] => z#{t - i}\n"
      key = (t-i).to_s 
      key = "0" + key if key.length == 1 
      mismatches << ("z" + key)
    end
  end

  # print mismatches, "\n"
  [bin_str.to_i(2), mismatches]
end


def handle_and_xor_sets(x, dataset = nil) 
  
  and_gates = []
  xor_gates = []

  _paths = $paths[x]
  _, _, op1, v1 = _paths[0]
  _, _, op2, v2 = _paths[1]

  print _paths[0], "\n"
  print _paths[1], "\n"

  $fault_gates << dataset || _paths[0] if op1 != "AND" && op1 != "XOR"
  $fault_gates << dataset || _paths[1] if op2 != "AND" && op2 != "XOR"
    
  [op1, op2].each_with_index do |op, idx|
    if op == "AND"
      and_gates << _paths[idx]
    elsif op == "XOR"
      xor_gates <<  _paths[idx]
    end
  end 

  [and_gates, xor_gates]
end


def handle_and_gates(and_gates)
  or_gates = []
  while and_gates.length > 0
    dataset = and_gates.pop 
    _paths = $paths[dataset.last]
    _, _, op1, _ = _paths[0]

    #first set of AND gates only connects to an OR operation
    if op1 != "OR"
      $fault_gates << dataset 
    else 
      or_gates << _paths[0]
    end
  end

  or_gates
end

def solution_2
  codes, operations = extract_data
  $paths = Hash.new([])

  operations.each do |dataset|
    v1, v2, op, v3 = dataset
    $paths[v1] += [dataset]
    $paths[v2] += [dataset]
  end

  $fault_gates = Set.new
  and_gates = []
  xor_gates = []

  # handles the x, y starting points, they must result in xor and and
  # except for x00, y00, those are unique
  codes.keys.select{|v| v.start_with?("x")}.each do |x|
    _and_gates, _xor_gates = handle_and_xor_sets(x)
    and_gates.concat(_and_gates)
    xor_gates.concat(_xor_gates)
  end
 
  t_xor_gates = []
  # first series of xor gates only ends up with xors and ands (again)
  while xor_gates.length > 0
    dataset = xor_gates.pop 
    _and_gates, _xor_gates = handle_and_xor_sets(dataset.last, dataset)
    t_xor_gates.concat(_xor_gates)
    and_gates.concat(_and_gates)
  end

  while t_xor_gates.length > 0 
    dataset = t_xor_gates.pop
    $fault_gates << dataset if !dataset.last.include?("z")
  end

  # and gates always only get up with ORs
  or_gates = handle_and_gates(and_gates)

  while or_gates.length > 0
    dataset = or_gates.pop 
    _paths = $paths[dataset.last]
    _, _, op1, v1 = _paths[0]
    _, _, op2, v2 = _paths[1]
    
    $fault_gates << dataset if op1 != "AND" && op1 != "XOR"
    $fault_gates << dataset if op2 != "AND" && op2 != "XOR"
  end

  print $fault_gates
  print $fault_gates.to_a.compact.select{|d| d.last != "z00" && d.last != "z45" && d.first != "y00" && d.last != "x00"}
  .map{|d| d.last }.sort.join(",")
end

t = Benchmark.measure do 
  puts solution_2
end 

puts t.real
