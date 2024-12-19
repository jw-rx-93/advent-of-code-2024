require 'set'

def extract_data
  wordSet = Set.new([])
  patterns = []
  max_word_length = 0
  file_type = ENV['TEST'].nil? ? 'sample' : 'test'

  File.open("#{file_type}_data.txt") do |f|
    f.each_line do |line|
      chunks = line.gsub("\n", "").gsub(" ", "").split(",")
      if chunks.length > 1
        wordSet = Set.new(chunks)
        chunks.each do |word| 
           max_word_length = [word.length, max_word_length].max
        end
      elsif chunks.length == 1 && chunks[0].length > 0
        patterns << chunks.first
      end
    end
    f.close 
  end

  [wordSet, patterns, max_word_length]
end


def word_dfs(current_index, max_win_length, pattern, wordSet)
  return 0 if current_index > pattern.length 

  if ($use_viable && $viable) || pattern.length == current_index 
      $viable = true 
      return 1
  end

  possible_words = []
  window_pointer = current_index 


  while window_pointer < max_win_length + current_index
    word = pattern[current_index..window_pointer]
    if wordSet.include?(word)
      # + 1 because you want the next index as the new starting letter
      # since ur current one is valid
      possible_words << [word, window_pointer + 1]
    end
    window_pointer += 1
  end

  # print possible_words, "\n"
  count = 0
  possible_words.each do |word_pair|
    word, idx = word_pair 
    if !!$memo["#{word}-#{idx}"]
      count += $memo["#{word}-#{idx}"]
    else 
      total = word_dfs(idx, max_win_length, pattern, wordSet)
      $memo["#{word}-#{idx}"] = total 
      count += total
    end
  end
  
  count
end

def solution_1
  # store all words in a set
  # find the longest word 
  # use dfs to find possible combination based off root given 
  # each subsequent word node is identified with a window 
  # that matches the window substring with whatever is stored
  # in our words set
  # the found condition is that the start index is exactly the
  # length of the string
  # once found, we can terminate all other roots with a flag

  wordSet, patterns, max_length = extract_data
  count = 0
  patterns.each do |pattern|
    $viable = false
    $use_viable = true
    $memo = {}

    word_dfs(0, max_length, pattern, wordSet)
    count += 1 if $viable
  end

  count
end


def solution_2
  # store all words in a set
  # find the longest word 
  # use dfs to find possible combination based off root given 
  # each subsequent word node is identified with a window 
  # that matches the window substring with whatever is stored
  # in our words set
  # the found condition is that the start index is exactly the
  # length of the string
  # once found, we can terminate all other roots with a flag

  wordSet, patterns, max_length = extract_data
  count = 0
  patterns.each do |pattern|
    $viable = false
    $use_viable = false
    $memo = {}

    puts pattern
    total = word_dfs(0, max_length, pattern, wordSet)
    count += total
  end

  count
end


puts solution_1
puts solution_2