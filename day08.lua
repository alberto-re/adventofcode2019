--- Day 8: Space Image Format ---

package.path = "../?.lua;" .. package.path
local common = require("common")

local SpaceImageDecoder = {}

function SpaceImageDecoder:new(rows, cols)
  local o = {
    rows = rows or 1,
    cols = cols or 1,
    layers = {},
    fewest_zero_layer = nil,
    final_image = {}
  }
  setmetatable(o, SpaceImageDecoder)
  self.__index = SpaceImageDecoder
  return o
end

function SpaceImageDecoder:decode(image)
  local n_layers = #image // (self.rows * self.cols)

  for _=1,n_layers do
    table.insert(self.layers, {})
  end

  for i=1,self.rows do
    table.insert(self.final_image, {})
    for _=1,self.cols do
      table.insert(self.final_image[i], "2")
    end
  end

  local layer = 1
  local fewest_zero = nil

  while layer <= n_layers do
    local zero_count = 0
    for i=1,self.rows do
      table.insert(self.layers[layer], {})
      for j=1,self.cols do
        local offset = ((layer - 1) * self.rows * self.cols) + j + (i - 1) * self.cols
        local digit = image:sub(offset, offset)
        table.insert(self.layers[layer][i], digit)
        if digit == "0" then
          zero_count = zero_count + 1
          if self.final_image[i][j] == "2" then
            self.final_image[i][j] = "0"
          end
        elseif digit == "1" then
          if self.final_image[i][j] == "2" then
            self.final_image[i][j] = "1"
          end
        end
      end
    end
    if fewest_zero == nil or zero_count < fewest_zero then
      fewest_zero = zero_count
      self.fewest_zero_layer = layer
    end
    layer = layer + 1
  end
end

function SpaceImageDecoder:integrity_code()
  local one_count, two_count = 0, 0
  for i=1,self.rows do
    for j=1,self.cols do
      if self.layers[self.fewest_zero_layer][i][j] == "1" then
        one_count = one_count + 1
      elseif self.layers[self.fewest_zero_layer][i][j] == "2" then
        two_count = two_count + 1
      end
    end
  end
  return one_count * two_count
end

function SpaceImageDecoder:print_final_image()
  for i=1,self.rows do
    for j=1,self.cols do
      if self.final_image[i][j] == "0" then
        io.write("O")
      else
        io.write(" ")
      end
    end
    io.write("\n")
  end
end

local decoder = SpaceImageDecoder:new(2, 3)
decoder:decode("123456789012")
assert(common.serialize(decoder.layers) == "{{{1,2,3},{4,5,6}},{{7,8,9},{0,1,2}}}")
assert(decoder:integrity_code() == 1)

decoder = SpaceImageDecoder:new(2, 2)
decoder:decode("0222112222120000")
assert(common.serialize(decoder.layers) == "{{{0,2},{2,2}},{{1,1},{2,2}},{{2,2},{1,2}},{{0,0},{0,0}}}")
assert(decoder:integrity_code() == 4)

decoder = SpaceImageDecoder:new(3, 2)
decoder:decode("011021002220112101")
assert(decoder:integrity_code() == 4)
assert(common.serialize(decoder.layers) == "{{{0,1},{1,0},{2,1}},{{0,0},{2,2},{2,0}},{{1,1},{2,1},{0,1}}}")

local function main()
  local f = io.open(os.getenv("PWD") .. "/input/day08.txt", "r")
  local image = f:read("*line")
  f:close()

  decoder = SpaceImageDecoder:new(6, 25)
  decoder:decode(image)
  print("part 1: " .. decoder:integrity_code())
  print("part 2:")
  decoder:print_final_image()
end

main()
