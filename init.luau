local Maid = {}
Maid.__index = Maid

export type MaidItem =
  { Destroy: (self: any) -> any }
  | RBXScriptConnection
  | Instance
  | Maid
  | thread
  | (() -> any)

export type Maid = { MaidItem } & typeof(setmetatable({}, Maid))

function Maid.new(): Maid return setmetatable({}, Maid) :: Maid end

function Maid.isMaid(value: any) return getmetatable(value) == Maid end

function Maid.add<T>(self: Maid, ...: T): ...T
  for _, item in ipairs({ ... }) do
    if self:has(item) then continue end
    table.insert(self, item)
  end
  return ...
end

function Maid.pop(self: Maid, item: MaidItem?)
  if item == nil then return end
  pcall(cleanup, item)
  for i = #self, 1, -1 do
    if self[i] == item then table.remove(self, i) end
  end
end

function Maid.has(self: Maid, item: MaidItem): boolean
  for _, value in ipairs(self) do
    if value == item then return true end
  end
  return false
end

function Maid.clear(self: Maid)
  for _, item in ipairs(self) do
    pcall(cleanup, item)
  end
  table.clear(self :: any)
end

function Maid.Destroy(self: Maid) self:clear() end

function cleanup(item: MaidItem)
  if type(item) == "thread" then
    task.cancel(item)
  elseif type(item) == "function" then
    pcall(item)
  elseif typeof(item) == "RBXScriptConnection" then
    item:Disconnect()
  else
    if typeof(item) == "Instance" and item:IsA("Tween") then item:Cancel() end
    item:Destroy()
    pcall(function() (item :: Instance).Parent = nil end)
  end
end

return Maid
