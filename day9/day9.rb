PREFIX = "test"

def extract_data
  data = ""

  File.open("./#{PREFIX}_data.txt", "r") do |f|
    f.each_line do |line|
      chunks = line.gsub("\n", "")
      data += chunks
    end
    f.close
  end

  data
end 

DATA = extract_data


def form_seqeunce
  id = 0
  iterator = 1
  sequence = []

  while iterator < DATA.length 
    prev_value = DATA[iterator-1]
    current_value = DATA[iterator]

    prev_value.to_i.times { sequence << id }
    current_value.to_i.times { sequence << "." }
    id += 1
    iterator += 2
  end

  if iterator == DATA.length 
    prev_value = DATA[iterator-1]
    prev_value.to_i.times { sequence << id }
  end

  sequence
end



def solution1
  sequence = form_seqeunce
  left = 0
  right = sequence.length - 1

  while left < right 
    left += 1 while sequence[left] != "." && left < right
    right -= 1 while sequence[right] == "." && right > left
    sequence[left], sequence[right] = sequence[right], sequence[left]
  end 

  idx = -1
  sequence.inject(0) do |accum, val|
    idx += 1
    accum += ((val == "." || val == "x") ? 0 : val * idx)
  end
end


def solution2_brute_force(sequence)
  # going backwards in sequence
  # get count of each number 

  # iterate for dots
  # check from the largest number in the backwards array to see if they can slot in
  # if so swap in, after swap is performed, removed said number from array
  # if there are remaining spaces, continue to check array to see if there is anything else

  collection = []

  # ruby can extend array like this, we're expected to have incremental id anyway
  sequence.each_with_index do |val, idx|
    next if val == "."
    collection[val] ||= [idx, 0]
    collection[val][1] += 1
  end

  idx = 0
  last_seen_num = sequence[0]

  while idx < sequence.length 
    val = sequence[idx]

    if val == "."
      dot_count = 0
      cpy_idx = idx 

      until cpy_idx == sequence.length  || sequence[cpy_idx] != "." 
        dot_count += 1 
        cpy_idx += 1
      end

      id = collection.length - 1   

      while id > last_seen_num && dot_count > 0
        count_pair = collection[id]

        if count_pair && count_pair[1] <= dot_count
          c_idx = count_pair[0]
          
          count_pair[1].times do 
            sequence[idx] = id 
            sequence[c_idx] = "x"
            idx += 1
            c_idx += 1
          end

          collection[id] = nil
          dot_count -= count_pair[1]  
        end
        
        id -= 1
      end

      idx = cpy_idx
    else 
      last_seen_num = val if val != "x"
      idx += 1
    end
  end

  idx = -1
  sequence.inject(0) do |accum, val|
    idx += 1
    accum += ((val == "." || val == "x") ? 0 : val * idx)
  end
end 



def solution2_queue(sequence)
  # preferably we have a PQ
  list_of_queues = []
  collection = []
    # ruby can extend array like this, we're expected to have incremental id anyway
  sequence.each_with_index do |val, idx|
    next if val == "."
    collection[val] ||= [idx, 0]
    collection[val][1] += 1
  end

  idx = 0
  while idx < sequence.length 
    if sequence[idx] == "."
      cpy_idx = idx 
      cpy_idx += 1 while sequence[cpy_idx] == "." && cpy_idx < sequence.length 
      list_of_queues[cpy_idx - idx] ||= []
      list_of_queues[cpy_idx - idx].push(idx)
      idx = cpy_idx
    else 
      idx += 1
    end
  end

  list_of_queues = list_of_queues.map{|val| val&.sort&.reverse }
  b_idx = collection.length - 1

  while b_idx > 0 
    c_idx, space = collection[b_idx]

    # we want to find the queue with the smallest index to dequeue value from
    min_idx = sequence.length 
    queue_idx = 0

    list_of_queues.each_with_index do |heap, _q_idx|
      next if heap.nil? || _q_idx < space
      # not really a heap cuz we don't have an implementation
      idx_of_block = heap.last 

      next if !idx_of_block

      if idx_of_block < min_idx 
        queue_idx = _q_idx 
        min_idx = idx_of_block
      end
    end

    if queue_idx > 0 && list_of_queues[queue_idx] 
      heap = list_of_queues[queue_idx]
      swap_idx = heap.pop 
      diff = 0

      diff = queue_idx - space if queue_idx > space 
       
      if c_idx > swap_idx
        until space == 0 
          sequence[swap_idx] = b_idx 
          sequence[c_idx] = "x"
          swap_idx += 1
          c_idx += 1
          space -= 1
        end
      end

      if diff > 0 && c_idx > swap_idx
        list_of_queues[diff] ||= []
        list_of_queues[diff].push(swap_idx)
        # we don't have to do this if we have a priority queue
        list_of_queues[diff] = list_of_queues[diff].sort.reverse
      end
    end

    b_idx -= 1
  end 


  idx = -1
  sequence.inject(0) do |accum, val|
    idx += 1
    accum += ((val == "." || val == "x") ? 0 : val * idx)
  end
end


print solution1 
puts
print solution2_queue(form_seqeunce)
puts


=begin
  sol 1 used a double pointer solution since that was rather inuitive, you just need to track numbers vs dots via left / right.
  sol 2 required a different appraoch since there is a priority to the numbers being replaced. Read the code comment for the idea.
  A priority queue perhaps can be used to optimize the algorithm
=end