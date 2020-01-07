--- Day 4: Secure Container ---

local function min_max(str)
  local list = {}
  for substr in string.gmatch(str, "([^-]+)") do
    table.insert(list, substr)
  end
  assert(#list == 2)
  return tonumber(list[1]), tonumber(list[2])
end

assert(table.concat({ min_max("47-12") }) == table.concat({ 47, 12 }))
assert(table.concat({ min_max("248345-746315") }) == table.concat({ 248345, 746315 }))

local function adjacency_criteria(n)
  local prev
  for digit in string.gmatch(n, "%d") do
    if digit == prev then
      return true
    else
      prev = digit
    end
  end
  return false
end

assert(adjacency_criteria(111111))
assert(adjacency_criteria(223450))
assert(not adjacency_criteria(123789))

local function increasing_criteria(n)
  local prev
  for digit in string.gmatch(n, "%d") do
    if prev ~= nil and digit < prev then
      return false
    else
      prev = digit
    end
  end
  return true
end

assert(increasing_criteria(111111))
assert(increasing_criteria(123789))
assert(not increasing_criteria(223450))

local function adjacency_criteria_strict(n)
  local prev
  local repeating = 0
  for digit in string.gmatch(n, "%d") do
    if prev ~= nil then
      if digit == prev then
        repeating = repeating + 1
      else
        if repeating == 1 then
          return true
        else
          repeating = 0
        end
      end
    end
    prev = digit
  end
  if repeating == 1 then
    return true
  else
    return false
  end
end

assert(adjacency_criteria_strict(112233))
assert(adjacency_criteria_strict(111122))
assert(not adjacency_criteria_strict(123444))

local function count_passwords(min, max, strict)
  local n = 0
  for i = min, max do
    if (strict == nil and adjacency_criteria(i) or adjacency_criteria_strict(i)) and increasing_criteria(i) then
      n = n + 1
    end
  end
  return n
end

local function main()
  local f = io.open(os.getenv("PWD") .. "/input/day04.txt", "r")
  local input = f:read("*all")
  f:close()

  local min, max = min_max(input)

  print("part 1: " .. count_passwords(min, max))
  print("part 2: " .. count_passwords(min, max, "strict"))
end

main()
