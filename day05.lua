--- Day 5: Sunny with a Chance of Asteroids ---

local function tokenize(src)
  local program = {}
  for token in string.gmatch(src, "([^,]+)") do
    table.insert(program, tonumber(token))
  end
  return program
end

assert(table.concat(tokenize("1002,4,3,4,33")) == table.concat({ "1002", "4", "3", "4", "33" }))

local function parse_opcode(token)
  local opcode = tonumber(string.sub(token, -2, -1))
  local mod1, mod2, mod3 = 0, 0, 0

  local reversed_token = string.reverse(token)
  if string.len(reversed_token) > 2 then
    mod1 = tonumber(string.sub(reversed_token, 3, 3))
  end
  if string.len(reversed_token) > 3 then
    mod2 = string.sub(reversed_token, 4, 4)
  end
  if string.len(reversed_token) > 4 then
    mod3 = string.sub(reversed_token, 5, 5)
  end
  return opcode, mod1, mod2, mod3
end

assert(table.concat({ parse_opcode("1002") }) == table.concat({ 2, 0, 1, 0 }))
assert(table.concat({ parse_opcode("55") }) == table.concat({ 55, 0, 0, 0 }))
assert(table.concat({ parse_opcode("1111") }) == table.concat({ 11, 1, 1, 0 }))
assert(table.concat({ parse_opcode("1") }) == table.concat({ 1, 0, 0, 0 }))

local function evaluate(program, input)
  local tokens = tokenize(program)
  local output
  local pos = 1
  while pos <= #tokens do
    local opcode, mod1, mod2, mod3 = parse_opcode(tokens[pos])
    if opcode == 1 or opcode == 2 then
      local left, right
      if mod1 == 0 then
        left = tokens[tokens[pos + 1] + 1]
      else
        left = tokens[pos + 1]
      end
      if mod2 == 0 then
        right = tokens[tokens[pos + 2] + 1]
      else
        right = tokens[pos + 2]
      end
      local result
      if opcode == 1 then
        result = math.floor(left + right)
      else
        result = math.floor(left * right)
      end
      if mod3 == 0 then
        tokens[tokens[pos + 3] + 1] = result
      else
        tokens[pos + 3] = result
      end
      pos = pos + 4
    elseif opcode == 3 then
      tokens[tokens[pos + 1] + 1] = input
      pos = pos + 2
    elseif opcode == 4 then
      output = tokens[tokens[pos + 1] + 1]
      pos = pos + 2
    elseif opcode == 5 then
      local value_to_test
      if mod1 == 0 then
        value_to_test = tokens[tokens[pos + 1] + 1]
      else
        value_to_test = tokens[pos + 1]
      end
      if value_to_test ~= 0 then
        if mod2 == 0 then
          pos = tokens[tokens[pos + 2] + 1] + 1
        else
          pos = tokens[pos + 2] + 1
        end
      else
        pos = pos + 3
      end
    elseif opcode == 6 then
      local value_to_test
      if mod1 == 0 then
        value_to_test = tokens[tokens[pos + 1] + 1]
      else
        value_to_test = tokens[pos + 1]
      end
      if value_to_test == 0 then
        if mod2 == 0 then
          pos = tokens[tokens[pos + 2] + 1] + 1
        else
          pos = tokens[pos + 2] + 1
        end
      else
        pos = pos + 3
      end
    elseif opcode == 7 then
      local first, second
      if mod1 == 0 then
        first = tokens[tokens[pos + 1] + 1]
      else
        first = tokens[pos + 1]
      end
      if mod2 == 0 then
        second = tokens[tokens[pos + 2] + 1]
      else
        second = tokens[pos + 2]
      end
      if first < second then
        tokens[tokens[pos + 3] + 1] = 1
      else
        tokens[tokens[pos + 3] + 1] = 0
      end
      pos = pos + 4
    elseif opcode == 8 then
      local first, second
      if mod1 == 0 then
        first = tokens[tokens[pos + 1] + 1]
      else
        first = tokens[pos + 1]
      end
      if mod2 == 0 then
        second = tokens[tokens[pos + 2] + 1]
      else
        second = tokens[pos + 2]
      end
      if first == second then
        tokens[tokens[pos + 3] + 1] = 1
      else
        tokens[tokens[pos + 3] + 1] = 0
      end
      pos = pos + 4
    elseif opcode == 99 then
      return output
    else
      error(string.format("invalid opcode %d", opcode))
    end
  end
end

assert(evaluate("3,3,1105,-1,9,1101,0,0,12,4,12,99,1", 0) == 0)
assert(evaluate("3,3,1105,-1,9,1101,0,0,12,4,12,99,1", 8) == 1)
assert(evaluate("3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9", 0) == 0)
assert(evaluate("3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9", 4) == 1)
assert(evaluate("3,9,8,9,10,9,4,9,99,-1,8", 3) == 0)
assert(evaluate("3,9,8,9,10,9,4,9,99,-1,8", 8) == 1)
assert(evaluate("3,9,7,9,10,9,4,9,99,-1,8", 13) == 0)
assert(evaluate("3,9,7,9,10,9,4,9,99,-1,8", 3) == 1)

local function main()
  local f = io.open(os.getenv("PWD") .. "/input/day05.txt", "r")
  local input = f:read("*all")
  f:close()

  print("part 1: " .. evaluate(input, 1))
  print("part 2: " .. evaluate(input, 5))
end

main()
