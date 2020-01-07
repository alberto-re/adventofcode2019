--- Day 2: 1202 Program Alarm ---

local function tokenize(src)
  local program = {}
  for token in string.gmatch(src, "([^,]+)") do
    table.insert(program, tonumber(token))
  end
  return program
end

assert(table.concat(tokenize("1002,4,3,4,33")) == table.concat({ 1002, 4, 3, 4, 33 }))

local function set_state(program, pos1, pos2)
  program[2] = pos1
  program[3] = pos2
end

local program_before = { 1002, 4, 3, 4, 33 }
local program_after = { 1002, 7, 21, 4, 33 }
set_state(program_before, 7, 21)
assert(table.concat(program_before) == table.concat(program_after))

local function evaluate(program)
  local pos = 1
  while pos <= #program do
    local opcode = program[pos]
    if opcode == 99 then
      break
    elseif opcode == 1 then
      local input1, input2, output = program[pos + 1] + 1, program[pos + 2] + 1, program[pos + 3] + 1
      program[output] = program[input1] + program[input2]
    elseif opcode == 2 then
      local input1, input2, output = program[pos + 1] + 1, program[pos + 2] + 1, program[pos + 3] + 1
      program[output] = program[input1] * program[input2]
    else
      error("invalid opcode " .. opcode)
    end
    pos = pos + 4
  end
  return math.floor(program[1])
end

assert(evaluate({ 1, 0, 0, 0, 99 }) == 2)
assert(evaluate({ 2, 3, 0, 3, 99 }) == 2)
assert(evaluate({ 2, 4, 4, 5, 99, 0 }) == 2)
assert(evaluate({ 1, 1, 1, 4, 99, 5, 6, 0, 99 }) == 30)

local function program_with_input(base_program, noun, verb)
  local program = {}
  for i = 1, #base_program do
    if i == 2 then
      table.insert(program, noun)
    elseif i == 3 then
      table.insert(program, verb)
    else
      table.insert(program, base_program[i])
    end
  end
  return program
end

assert(table.concat(program_with_input({ 1002, 4, 3, 4, 33 }, 7, 21)) == table.concat({ 1002, 7, 21, 4, 33 }))

local function find_program(src, target)
  local program = tokenize(src)
  for noun = 0,99,1 do
    for verb = 0,99,1 do
      local attempt = program_with_input(program, noun, verb)
      local result = evaluate(attempt)
      if result == target then
        return 100 * noun + verb
      end
    end
  end
end

local function main()
  local f = io.open(os.getenv("PWD") .. "/input/day02.txt", "r")
  local src = f:read("*all")
  f:close()

  local program = tokenize(src)
  set_state(program, 12, 2)

  print("part 1: " .. evaluate(program))
  print("part 2: " .. find_program(src, 19690720))
end

main()