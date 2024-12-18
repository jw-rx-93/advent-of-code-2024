PREFIX = "test"

def initalize_program
  File.open("#{PREFIX}_data.txt") do |f|
    f.each_line do |line|
      line = line.gsub(" ", "")
      if line.include?("A:")
        $registers['A'] = line.split(":").last.to_i
      elsif line.include?("B:")
        $registers['B'] = line.split(":").last.to_i
      elsif line.include?("C:")
        $registers['C'] = line.split(":").last.to_i
      elsif line.include?("Program:")
        $program = line.split(":").last
      end
    end
    f.close
  end

  print $registers, "\n"
  puts $program
end


def init_register
  $program = ""
  $registers = {
    'A' => 0,
    'B' => 0,
    'C' => 0,
  }
end

def get_operand_actual_value(val)
  case val 
  when 0..3
    return val 
  when 4 
    return $registers['A']
  when 5
    return $registers['B']
  when 6
    return $register['C']
  else
    return nil
  end
end

def solution1
  init_register
  initalize_program

  instructions = $program.split(",").map(&:to_i)
  results = []
  executed_instuctions = []
  i = 0
  
  # while loop is better here cuz instruction is going to extend

  while i < instructions.length    
      opcode = instructions[i]
      operand = instructions[i + 1]
      jumped = false

      combo = get_operand_actual_value(operand)

      unless combo && operand != 7
        i += 2
        next
      end

      case opcode 
      when 0, 'adv'
        numerator = $registers['A']
        denominator = 2 ** combo 
        $registers['A'] = numerator / denominator
      when 1, 'bxl'
        $registers['B'] = $registers['B'] ^ operand 
      when 2, 'bst'
        $registers['B'] = combo % 8 
      when 3, 'jnz'
        if $registers['A'] > 0 
          i = operand
          jumped = true
        end
      when 4, 'bxc'
        $registers['B'] = $registers['B'] ^ $registers['C']
      when 5, 'out'
       results << combo % 8
      when 6, 'bdv'
        numerator = $registers['A']
        denominator = 2 ** combo 
        $registers['B'] = (numerator / denominator)
      when 7, 'cdv'     
        numerator = $registers['A']
        denominator = 2 ** combo 
        $registers['C'] = (numerator / denominator) 
      end

      i += 2 unless jumped
  end

  print results.join(","), "\n"
end


def dfs(reg_a, instructions, index)
  if index < 0
    puts reg_a
    return
  end

  value = instructions[index]

  reg_a = reg_a * (2**3)
  next_numbers_to_check = []

  (reg_a..reg_a + 7).each do |a_val|
    # interpretation of my instructions
    # reg_a only changes towards the end so whatever gets calculated above 
    # is the initial value at the start of the new sequence 

     reg_b = a_val % 8
     reg_b = reg_b ^ 3 
     reg_c = a_val / (2 ** reg_b)
     reg_b = reg_b ^ 5
     reg_b = reg_b ^ reg_c 
     
     if reg_b % 8 == value 
       next_numbers_to_check << a_val
     end
  end


  next_numbers_to_check.each do |num|
    dfs(num, instructions, index - 1)
  end
end


def solution2
  init_register
  initalize_program

  instructions = $program.split(",").map(&:to_i)
  
  dfs(0, instructions, instructions.length - 1)
end

