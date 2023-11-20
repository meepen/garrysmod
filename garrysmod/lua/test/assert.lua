local assert = {}

function assert.Equals(a, b)
  if (a ~= b) then
    error(string.format("Expected %q, got %q", tostring(a), tostring(b)), 2)
  end
end

function assert.IsTruthy(a, reason)
  if (not a) then
    error(reason or "expected value to be truthful", 2)
  end
end

function assert.IsFalsy(a, reason)
  if (a) then
    error(reason or "expected value to be falsy", 2)
  end
end

function assert.IsNil(a)
  if (a ~= nil) then
    error(string.format("Expected nil, got %q", tostring(a)), 2)
  end
end

setmetatable(assert, {
  __call = function(self, ...)
    return self.IsTruthy(...)
  end,
})

return assert