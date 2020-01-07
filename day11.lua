--- Day 11: Space Police ---

local IntCodeComputer = {}
IntCodeComputer.__index = IntCodeComputer

function IntCodeComputer:new(program, init_input)
  local o = {
    pos = 1,
    program = program,
    tokens = nil,
    input = {},
    output = nil,
    halted = false,
    relative_base = 0,
    memory = {}
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
  modifier = tonumber(modifier) or 0
  if modifier == 0 then
    if self.tokens[self.pos + ordinal] + 1 <= #self.tokens then
      -- program
      return self.tokens[self.tokens[self.pos + ordinal] + 1]
    else
      -- memory
      if self.memory[self.tokens[self.pos + ordinal] + 1] == nil then
        return 0
      else
        return self.memory[self.tokens[self.pos + ordinal] + 1]
      end
    end
  elseif modifier == 1 then
    return self.tokens[self.pos + ordinal]
  elseif modifier == 2 then
    if self.tokens[self.pos + ordinal] + self.relative_base + 1 <= #self.tokens then
      -- program
      return self.tokens[self.tokens[self.pos + ordinal] + self.relative_base + 1]
    else
      -- memory
      if self.memory[self.tokens[self.pos + ordinal] + self.relative_base + 1] == nil then
        return 0
      else
        return self.memory[self.tokens[self.pos + ordinal] + self.relative_base + 1]
      end
    end
  else
    error("invalid modifier " .. modifier)
  end
end

function IntCodeComputer:set_parm(value, ordinal, modifier)
  modifier = tonumber(modifier) or 0
  if modifier == 0 then
    if self.tokens[self.pos + ordinal] + 1 <= #self.tokens then
      -- program
      self.tokens[self.tokens[self.pos + ordinal] + 1] = value
    else
      self.memory[self.tokens[self.pos + ordinal] + 1] = value
    end
  elseif modifier == 1 then
    self.tokens[self.pos + ordinal] = value
  elseif modifier == 2 then
    if self.tokens[self.pos + ordinal] + self.relative_base + 1 <= #self.tokens then
      -- program
      self.tokens[self.tokens[self.pos + ordinal] + self.relative_base + 1] = value
    else
      self.memory[self.tokens[self.pos + ordinal] + self.relative_base + 1] = value
    end
  else
    error("invalid modifier " .. modifier)
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
      self:set_parm(table.remove(self.input, 1), 1, mod1)
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
	      self:set_parm(1, 3, mod3)
      else
	      self:set_parm(0, 3, mod3)
      end
      self:advance(4)
    elseif opcode == 8 then
      local left, right = self:get_parm(1, mod1), self:get_parm(2, mod2)
      if left == right then
	      self:set_parm(1, 3, mod3)
      else
	      self:set_parm(0, 3, mod3)
      end
      self:advance(4)
    elseif opcode == 9 then
      self.relative_base = self.relative_base + self:get_parm(1, mod1)
      self:advance(2)
    elseif opcode == 99 then
      self.halted = true
      return
    else
      error(string.format("invalid opcode %d", opcode))
    end
  end
  self.halted = true
  return
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

computer = IntCodeComputer:new(
  "109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99")
output = {}
while not computer:is_halted() do
  local tmp = computer:evaluate()
  if tmp ~= nil then
    table.insert(output, tmp)
  end
end
assert(table.concat(output, ",") == "109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99")

computer = IntCodeComputer:new("1102,34915192,34915192,7,4,7,99,0")
output = computer:evaluate()
assert(output == 1219070632396864)

computer = IntCodeComputer:new("104,1125899906842624,99")
output = computer:evaluate()
assert(output == 1125899906842624)

local TURN_LEFT, TURN_RIGHT = 0, 1

local function turn_direction(current_direction, turn)
  if turn == TURN_LEFT then
    return (current_direction + 90) % 360
  else
    return (current_direction + 270) % 360
  end
end

assert(turn_direction(90, TURN_RIGHT) == 0)
assert(turn_direction(0, TURN_RIGHT) == 270)
assert(turn_direction(270, TURN_RIGHT) == 180)
assert(turn_direction(180, TURN_RIGHT) == 90)
assert(turn_direction(90, TURN_LEFT) == 180)
assert(turn_direction(180, TURN_LEFT) == 270)
assert(turn_direction(270, TURN_LEFT) == 0)
assert(turn_direction(0, TURN_LEFT) == 90)

local function move(x, y, direction)
  if direction == 90 then
    return x, y + 1
  elseif direction == 180 then
    return x - 1, y
  elseif direction == 270 then
    return x, y - 1
  else
    return x + 1, y
  end
end

local x1, y1 = move(0, 0, 90)
assert(x1 == 0 and y1 == 1)
x1, y1 = move(0, 0, 0)
assert(x1 == 1 and y1 == 0)
x1, y1 = move(0, 0, 180)
assert(x1 == -1 and y1 == 0)
x1, y1 = move(0, 0, 270)
assert(x1 == 0 and y1 == -1)

local function main()

  local f = io.open(os.getenv("PWD") .. "/input/day11.txt", "r")
  local program = f:read("*all")
  f:close()

  computer = IntCodeComputer:new(program)

  local region = {}
  local x, y = 0, 0
  local direction = 90

  repeat
    local current_panel_color = region[x .. " " .. y] == nil and 0 or region[x .. " " .. y]
    region[x .. " " .. y] = computer:evaluate(current_panel_color)
    local turn = computer:evaluate()
    direction = turn_direction(direction, turn)
    x, y = move(x, y, direction)
  until computer:is_halted()

  local panels_painted = 0
  for _, _ in pairs(region) do
    panels_painted = panels_painted + 1
  end

  print("part 1:", panels_painted)

  computer = IntCodeComputer:new(program)

  region = {}
  x, y = 0, 0
  direction = 90

  region[x .. " " .. y] = 1

  local sx, top, dx, bottom = 0, 0, 0, 0

  repeat
    local current_panel_color = region[x .. " " .. y] == nil and 0 or region[x .. " " .. y]
    region[x .. " " .. y] = computer:evaluate(current_panel_color)
    local turn = computer:evaluate()
    direction = turn_direction(direction, turn)
    x, y = move(x, y, direction)

    if x < sx then
      sx = x
    elseif x > dx then
      dx = x
    end

    if y < bottom then
      bottom = y
    elseif y > top then
      top = y
    end

  until computer:is_halted()

  print("part 2:")

  for a=top,bottom,-1 do
    for b=sx,dx do
      if region[b .. " " .. a] == 1 then
        io.write("#")
      else
        io.write(" ")
      end
    end
    io.write("\n")
  end
end

main()
