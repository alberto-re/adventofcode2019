--- Day 12: The N-Body Problem ---

package.path = "../?.lua;" .. package.path
local common = require("common")

local function extract_positions(str)
  local x, y, z = string.match(str, "<x=(-?%d+), y=(-?%d+), z=(-?%d+)>")
  return { x=tonumber(x), y=tonumber(y), z=tonumber(z) }
end

local function timestep(positions, velocities, memory)

  if memory["starting"] == nil then
    memory["starting"] = {}
    memory["starting"][1] = common.serialize(positions[1]) .. "_" .. common.serialize(velocities[1])
    memory["starting"][2] = common.serialize(positions[2]) .. "_" .. common.serialize(velocities[2])
    memory["starting"][3] = common.serialize(positions[3]) .. "_" .. common.serialize(velocities[3])
    memory["starting"][4] = common.serialize(positions[4]) .. "_" .. common.serialize(velocities[4])
  end

  if memory["steps"] == nil then
    memory["steps"] = 1
  else
    memory["steps"] = memory["steps"] + 1
  end

  for _, pair in ipairs({ {1, 2}, {1, 3}, {1, 4}, {2, 3}, {2, 4}, {3, 4} }) do
    for _, axis in ipairs({ "x", "y", "z" }) do
      if positions[pair[1]][axis] < positions[pair[2]][axis] then
        velocities[pair[1]][axis] = velocities[pair[1]][axis] + 1
        velocities[pair[2]][axis] = velocities[pair[2]][axis] - 1
      elseif positions[pair[1]][axis] > positions[pair[2]][axis] then
        velocities[pair[1]][axis] = velocities[pair[1]][axis] - 1
        velocities[pair[2]][axis] = velocities[pair[2]][axis] + 1
      end
    end
  end

  for idx, pos in ipairs(positions) do
    pos["x"] = pos["x"] + velocities[idx]["x"]
    pos["y"] = pos["y"] + velocities[idx]["y"]
    pos["z"] = pos["z"] + velocities[idx]["z"]

    if memory["period_" .. idx] == nil and
       common.serialize(positions[idx]) .. "_" .. common.serialize(velocities[1]) == memory["starting"][idx] then
      memory["period_" .. idx] = memory["steps"]
      print("found period for moon " .. idx .. " at step " .. memory["steps"])
      print("positions: " .. common.serialize(positions[idx]))
    end
  end

end

local positions = {
  extract_positions("<x=-1, y=0, z=2>"),
  extract_positions("<x=2, y=-10, z=-7>"),
  extract_positions("<x=4, y=-8, z=8>"),
  extract_positions("<x=3, y=5, z=-1>")
}

local velocities = { { x=0, y=0, z=0 }, { x=0, y=0, z=0 }, { x=0, y=0, z=0 }, { x=0, y=0, z=0 } }

local memory = {}

timestep(positions, velocities, memory)

assert(common.serialize(positions) == "{{x=2,y=-1,z=1},{x=3,y=-7,z=-4},{x=1,y=-7,z=5},{x=2,y=2,z=0}}")
assert(common.serialize(velocities) == "{{x=3,y=-1,z=-1},{x=1,y=3,z=3},{x=-3,y=1,z=-3},{x=-1,y=-3,z=1}}")

timestep(positions, velocities, memory)

assert(common.serialize(positions) == "{{x=5,y=-3,z=-1},{x=1,y=-2,z=2},{x=1,y=-4,z=-1},{x=1,y=-4,z=2}}")
assert(common.serialize(velocities) == "{{x=3,y=-2,z=-2},{x=-2,y=5,z=6},{x=0,y=3,z=-6},{x=-1,y=-6,z=2}}")

for _=1,8 do
  timestep(positions, velocities, memory)
end

assert(common.serialize(positions) == "{{x=2,y=1,z=-3},{x=1,y=-8,z=0},{x=3,y=-6,z=1},{x=2,y=0,z=4}}")
assert(common.serialize(velocities) == "{{x=-3,y=-2,z=1},{x=-1,y=1,z=3},{x=3,y=2,z=-3},{x=1,y=-1,z=-1}}")

local function total_energy(positions, velocities)
  local total = 0
  for idx, _ in ipairs(positions) do
    total = total +
      (math.abs(positions[idx]["x"]) + math.abs(positions[idx]["y"]) + math.abs(positions[idx]["z"])) *
      (math.abs(velocities[idx]["x"]) + math.abs(velocities[idx]["y"]) + math.abs(velocities[idx]["z"]))
  end
  return total
end

assert(total_energy(positions, velocities) == 179)

while memory["period_1"] == nil or memory["period_2"] == nil or
    memory["period_3"] == nil or memory["period_4"] == nil do
  timestep(positions, velocities, memory)
end

-- https://rosettacode.org/wiki/Least_common_multiple#Lua
local function gcd( m, n )
  while n ~= 0 do
      local q = m
      m = n
      n = q % n
  end
  return m
end

local function lcm( m, n )
  return ( m ~= 0 and n ~= 0 ) and m * n / gcd( m, n ) or 0
end

print(memory["period_1"], memory["period_2"], memory["period_3"], memory["period_4"])

local cycle = lcm(lcm(lcm(memory["period_1"], memory["period_2"]), memory["period_3"]), memory["period_4"])

assert(cycle == 2772)

local function main()
  local f = io.open(os.getenv("PWD") .. "/input/day12.txt", "r")
  local inputs = { f:read("*line"), f:read("*line"), f:read("*line"), f:read("*line") }
  f:close()

  positions = {}
  velocities = {}
  for _, input in ipairs(inputs) do
    table.insert(positions, extract_positions(input))
    table.insert(velocities, { x=0, y=0, z=0 })
  end

  local memory = {}
  for i=1,1000 do
    timestep(positions, velocities, memory)
  end

  print("part 1: " .. total_energy(positions, velocities))

  while memory["period_1"] == nil or memory["period_2"] == nil or memory["period_3"] == nil or memory["period_4"] == nil do
    timestep(positions, velocities, memory)
  end

  local cycle = lcm(lcm(lcm(memory["period_1"], memory["period_2"]), memory["period_3"]), memory["period_4"])

  print("part 2: " .. cycle)
end

main()
