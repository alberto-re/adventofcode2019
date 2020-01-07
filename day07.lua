--- Day 7: Amplification Circuit ---

package.path = "../?.lua;" .. package.path
local common = require("common")

local IntCodeComputer = {}
IntCodeComputer.__index = IntCodeComputer

function IntCodeComputer:new(program, init_input)
  local o = {
    pos = 1,
    program = program,
    tokens = nil,
    input = {},
    output = nil,
    halted = false
  }
  if init_input then
    table.insert(o.input, init_input)
  end
  setmetatable(o, IntCodeComputer)
  self.__index = IntCodeComputer
  return o
end

function IntCodeComputer:tokenize()
  self.tokens = {}
  for token in string.gmatch(self.program, "([^,]+)") do
    table.insert(self.tokens, tonumber(token))
  end
end

function IntCodeComputer:cur_token()
  return self.tokens[self.pos]
end

function IntCodeComputer:more_tokens()
  return self.pos <= #self.tokens
end

function IntCodeComputer:advance(n)
  n = n or 1
  self.pos = self.pos + n
end

function IntCodeComputer:move(n)
  self.pos = n
end

function IntCodeComputer:parse_opcode()
  local token = self:cur_token()
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

function IntCodeComputer:get_parm(ordinal, modifier)
  modifier = modifier or 0
  if modifier == 0 then
    return self.tokens[self.tokens[self.pos + ordinal] + 1]
  else
    return self.tokens[self.pos + ordinal]
  end
end

function IntCodeComputer:set_parm(value, ordinal, modifier)
  modifier = modifier or 0
  if modifier == 0 then
    self.tokens[self.tokens[self.pos + ordinal] + 1] = value
  else
    self.tokens[self.pos + ordinal] = value
  end
end

function IntCodeComputer:is_halted()
  return self.halted
end

function IntCodeComputer:evaluate(input)

  if self.tokens == nil then
    self:tokenize()
  end

  table.insert(self.input, input)

  while self:more_tokens() do
    local opcode, mod1, mod2, mod3 = self:parse_opcode()
    if opcode == 1 or opcode == 2 then
      local left, right = self:get_parm(1, mod1), self:get_parm(2, mod2)
      local result
      if opcode == 1 then
        result = math.floor(left + right)
      else
        result = math.floor(left * right)
      end
      self:set_parm(result, 3, mod3)
      self:advance(4)
    elseif opcode == 3 then
      self:set_parm(table.remove(self.input, 1), 1)
      self:advance(2)
    elseif opcode == 4 then
      local output = self:get_parm(1, mod1)
      self:advance(2)
      return output
    elseif opcode == 5 then
      if self:get_parm(1, mod1) ~= 0 then
	      self:move(self:get_parm(2, mod2) + 1)
      else
	      self:advance(3)
      end
    elseif opcode == 6 then
      if self:get_parm(1, mod1) == 0 then
	      self:move(self:get_parm(2, mod2) + 1)
      else
	      self:advance(3)
      end
    elseif opcode == 7 then
      local left, right = self:get_parm(1, mod1), self:get_parm(2, mod2)
      if left < right then
	      self:set_parm(1, 3)
      else
	      self:set_parm(0, 3)
      end
      self:advance(4)
    elseif opcode == 8 then
      local left, right = self:get_parm(1, mod1), self:get_parm(2, mod2)
      if left == right then
	      self:set_parm(1, 3)
      else
	      self:set_parm(0, 3)
      end
      self:advance(4)
    elseif opcode == 99 then
      self.halted = true
      return
    else
      error(string.format("invalid opcode %d", opcode))
    end
  end
end

local computer = IntCodeComputer:new("99")
local output = computer:evaluate()
assert(output == nil)

computer = IntCodeComputer:new("3,0,4,0,99")
output = computer:evaluate(2)
assert(output == 2)

computer = IntCodeComputer:new("3,0,1002,0,3,0,4,0,99")
output = computer:evaluate(5)
assert(output == 15)

computer = IntCodeComputer:new("3,3,1105,-1,9,1101,0,0,12,4,12,99,1")
output = computer:evaluate(0)
assert(output == 0)

computer = IntCodeComputer:new("3,3,1105,-1,9,1101,0,0,12,4,12,99,1")
output = computer:evaluate(8)
assert(output == 1)

computer = IntCodeComputer:new("3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9")
output = computer:evaluate(0)
assert(output == 0)

computer = IntCodeComputer:new("3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9")
output = computer:evaluate(4)
assert(output == 1)

computer = IntCodeComputer:new("3,9,8,9,10,9,4,9,99,-1,8")
output = computer:evaluate(3)
assert(output == 0)

computer = IntCodeComputer:new("3,9,8,9,10,9,4,9,99,-1,8")
output = computer:evaluate(8)
assert(output == 1)

computer = IntCodeComputer:new("3,9,7,9,10,9,4,9,99,-1,8")
output = computer:evaluate(13)
assert(output == 0)

computer = IntCodeComputer:new("3,9,7,9,10,9,4,9,99,-1,8")
output = computer:evaluate(3)
assert(output == 1)

computer = IntCodeComputer:new(
  "3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,1106,0,36,98,0,0,1002,21," ..
  "125,20,4,20,1105,1,46,104,999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99")
output = computer:evaluate(5)
assert(output == 999)

computer = IntCodeComputer:new(
  "3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,1106,0,36,98,0,0,1002,21," ..
  "125,20,4,20,1105,1,46,104,999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99")
output = computer:evaluate(8)
assert(output == 1000)

computer = IntCodeComputer:new(
  "3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,1106,0,36,98,0,0,1002,21," ..
  "125,20,4,20,1105,1,46,104,999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99")
output = computer:evaluate(54)
assert(output == 1001)

local function series(program, phase_seq)

  local amp = {}
  table.insert(amp, IntCodeComputer:new(program, phase_seq[1]))
  table.insert(amp, IntCodeComputer:new(program, phase_seq[2]))
  table.insert(amp, IntCodeComputer:new(program, phase_seq[3]))
  table.insert(amp, IntCodeComputer:new(program, phase_seq[4]))
  table.insert(amp, IntCodeComputer:new(program, phase_seq[5]))

  local io = 0
  for idx, _ in ipairs(phase_seq) do
    io = amp[idx]:evaluate(io)
  end
  return io
end

local program_1 = "3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0"
local phase_1 = { 4,3,2,1,0 }
assert(series(program_1, phase_1) == 43210)
local program_2 = "3,23,3,24,1002,24,10,24,1002,23,-1,23,101,5,23,23,1,24,23,23,4,23,99,0,0"
local phase_2 = { 0,1,2,3,4 }
assert(series(program_2, phase_2) == 54321)
local program_3 = "3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0"
local phase_3 = { 1,0,4,3,2 }
assert(series(program_3, phase_3) == 65210)

local function gen_permutations(elements)
  local perms = {}
  local function heap(k, array) -- heap's algorithm
    if k == 0 then
      table.insert(perms, { table.unpack(array) })
    else
      for i = 1, k do
        heap(k - 1, array)
        if k % 2 == 0 then
          array[i], array[k] = array[k], array[i]
        else
          array[1], array[k] = array[k], array[1]
        end
      end
    end
  end
  heap(#elements, elements)
  return perms
end

assert(common.serialize(gen_permutations({ 1, 2, 3 })) == "{{1,2,3},{2,1,3},{3,1,2},{1,3,2},{2,3,1},{3,2,1}}")

local function feedback_loop(program, phase_seq)

  local amp = {}
  table.insert(amp, IntCodeComputer:new(program, phase_seq[1]))
  table.insert(amp, IntCodeComputer:new(program, phase_seq[2]))
  table.insert(amp, IntCodeComputer:new(program, phase_seq[3]))
  table.insert(amp, IntCodeComputer:new(program, phase_seq[4]))
  table.insert(amp, IntCodeComputer:new(program, phase_seq[5]))

  local io = 0
  local last_output = nil
  while not amp[5]:is_halted() do
    for i=1,5 do
      io = amp[i]:evaluate(io)
      if i == 5 and io ~= nil then
        last_output = io
      end
    end
  end
  return last_output
end

local function compute_highest_signal(input)
  local highest_signal = 0
  for _, perm in pairs(gen_permutations({ 5, 6, 7, 8, 9 })) do
    local signal = feedback_loop(input, perm)
    if signal and signal > highest_signal then
      highest_signal = signal
    end
  end
  return highest_signal
end

assert(compute_highest_signal(
  "3,26,1001,26,-4,26,3,27,1002,27,2,27,1,27,26,27,4,27,1001,28,-1,28,1005,28,6,99,0,0,5") == 139629729)

assert(compute_highest_signal(
  "3,52,1001,52,-5,52,3,53,1,52,56,54,1007,54,5,55,1005,55,26,1001,54,-5,54,1105,1,12,1," ..
  "53,54,53,1008,54,0,55,1001,55,1,55,2,53,55,53,4,53,1001,56,-1,56,1005,56,6,99,0,0,0,0,10") == 18216)

local function main()
  local f = io.open(os.getenv("PWD") .. "/input/day07.txt", "r")
  local input = f:read("*all")
  f:close()

  local highest_signal = 0
  for _, perm in pairs(gen_permutations({ 0, 1, 2, 3, 4 })) do
    local signal = series(input, perm)
    if signal > highest_signal then
      highest_signal = signal
    end
  end

  print("part 1: " .. highest_signal)
  print("part 2: " .. compute_highest_signal(input))
end

main()
