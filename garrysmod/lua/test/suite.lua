local assert = include "assert.lua"
local Suite = {}
local SuiteMT = { __index = Suite }

setmetatable(SuiteMT, {
  __call = function(self, ...)
    return self.new(...)
  end,
})

local function handler(err)
  return {
    err = debug.traceback(err, 2),
  }
end

local function call(fn)
  local ok, err = xpcall(fn, handler)

  return ok, err
end

function SuiteMT.new(name, parent)
  local self = setmetatable({}, SuiteMT)

  self.name = name
  self.parent = parent
  self.children = {}

  return self
end

function Suite:__tostring(self)
  return string.format("Suite (%s)", self.name)
end

function Suite:AddChild(name)
  local child = SuiteMT.new(name, self)
  table.insert(self.children, {
    child = child,
  })
  return child
end

function Suite:AddTest(name, func)
  table.insert(self.children, {
    type = "test",
    name = name,
    func = func
  })
end

function Suite:GenerateEnv()
  local env = setmetatable({
    describe = function(name, func)
      local suite = self:AddChild(name)
      suite:Generate(func)
    end,
    it = function(name, func)
      self:AddTest(name, func)
    end,
    assert = assert,
  }, { __index = getfenv(0) })

  return env
end

function Suite:Generate(func)
  setfenv(func, self:GenerateEnv())
  self.ok, self.err = call(func)
end

function Suite:Run()
  local results = {
    passed = 0,
    failed = self.ok and 0 or 1,
    name = self.name,
    ok = self.ok,
    err = self.err,
  }
  if ( results.ok ) then
    for _, test in ipairs(self.children) do
      if (test.func) then
        local ok, err = call(test.func)
        table.insert(results, {
          name = test.name,
          ok = ok,
          err = err,
        })

        results.ok = results.ok and ok
        local key = ok and "passed" or "failed"
        results[key] = results[key] + 1
      end

      if (test.child) then
        local childResults = test.child:Run()
        results.ok = results.ok and childResults.ok

        table.insert(results, childResults)

        results.passed = results.passed + childResults.passed
        results.failed = results.failed + childResults.failed
      end
    end
  end

  return results
end

return SuiteMT
