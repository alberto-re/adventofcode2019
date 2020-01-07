--- Day 1: The Tyranny of the Rocket Equation ---

local function mass_fuel(mass)
  return mass // 3 - 2
end

assert(mass_fuel(12) == 2)
assert(mass_fuel(14) == 2)
assert(mass_fuel(1969) == 654)
assert(mass_fuel(100756) == 33583)

local function module_fuel(mass)
  local total_fuel = 0
  while mass_fuel(mass) > 0 do
    mass = mass_fuel(mass)
    total_fuel = total_fuel + mass
  end
  return total_fuel
end

assert(module_fuel(1969) == 966)
assert(module_fuel(100756) == 50346)

local function total_fuel(input)
  local total, total_with_fuel = 0, 0
  for mass in input do
    total = total + mass_fuel(mass)
    total_with_fuel = total_with_fuel + module_fuel(mass)
  end
  return math.floor(total), math.floor(total_with_fuel)
end

local function main()
  local f = io.open(os.getenv("PWD") .. "/input/day01.txt", "r")
  local total, total_with_fuel = total_fuel(f:lines())
  f:close()

  print("part 1:", total)
  print("part 2:", total_with_fuel)
end

main()