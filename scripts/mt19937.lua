-- credits to Zeh Matt, Donald Reynolds, and BlackBulletIV

local function bor(a,b)
    local p,c=1,0
    while a+b>0 do
        local ra,rb=a%2,b%2
        if ra+rb>0 then c=c+p end
        a,b,p=(a-ra)/2,(b-rb)/2,p*2
    end
    return c
end

local function bnot(n)
    local p,c=1,0
    while n>0 do
        local r=n%2
        if r<1 then c=c+p end
        n,p=(n-r)/2,p*2
    end
    return c
end

local function band(a,b)
    local p,c=1,0
    while a>0 and b>0 do
        local ra,rb=a%2,b%2
        if ra+rb>1 then c=c+p end
        a,b,p=(a-ra)/2,(b-rb)/2,p*2
    end
    return c
end

local function bxor(a,b)
    local p,c=1,0
    while a>0 and b>0 do
        local ra,rb=a%2,b%2
        if ra~=rb then c=c+p end
        a,b,p=(a-ra)/2,(b-rb)/2,p*2
    end
    if a<b then a=b end
    while a>0 do
        local ra=a%2
        if ra>0 then c=c+p end
        a,p=(a-ra)/2,p*2
    end
    return c
end

local function bnot(n)
    local p,c=1,0
    while n>0 do
        local r=n%2
        if r<1 then c=c+p end
        n,p=(n-r)/2,p*2
    end
    return c
end

local function lshift(x, by)
  return x * 2 ^ by
end

local function rshift(x, by)
  return math.floor(x / 2 ^ by)
end

local k_MTLength = 624
local k_BitMask32 = 0x00000000ffffffff
local k_BitPow31 = lshift(1, 31)

local function printhex(d)
	print(string.format("%08x", d))
end

local function mul(a, b, maxBits)

	local res = 0
	local negative = (a < 0 and b > 0) or (a > 0 and b < 0)

	a = math.abs(a)
	b = math.abs(b)

	for i = 0, maxBits - 1 do
		local mask = lshift(1, i)
		local bitV = band(b, mask)
		if bitV > 0 then
			res = res + (lshift(a, i))
		end
	end

	if negative then
		res = bnot(res) + 1
	end

	return res

end

local function add(a, b, maxBits)

	local res = 0
	local c = 0

	for i = 0, maxBits - 1 do
		local mask = lshift(1, i)
		local b1 = rshift(band(a, mask), i)
		local b2 = rshift(band(b, mask), i)
		local v = bxor(bxor(b1, b2), c)
		c = bor(bor(band(b2, c), band(b1, b2)), band(b1, c))
		res = bor(res, lshift(v, i))
	end

	return res

end


local mt19937_meta = {}

function mt19937_meta:init(seed)

	self.KeyTable = {}
	self.KeyTable[0] = 0
	self.State = 0
	self:seed(seed)

end

function mt19937_meta:seed(seed)

	self.KeyTable[0] = seed
	self.State = 0

	for i = 1, k_MTLength - 1 do
		local shift = rshift(self.KeyTable[i - 1], 30)
		local xored = bxor(self.KeyTable[i - 1], shift)
		local entry = add(mul(1812433253, xored, 32), i, 32)
		self.KeyTable[i] = entry
	end

end

function mt19937_meta:get(min, max)

	min = min or 1
	max = max or 0xFFFFFFFF

	if self.State == 0 then

		for i = 0, k_MTLength - 1 do
			local y = add(
				band(self.KeyTable[i], k_BitPow31),
				band(self.KeyTable[(i + 1) % k_MTLength], k_BitPow31 - 1),
				32)
			self.KeyTable[i] = bxor(self.KeyTable[(i + 397) % k_MTLength], rshift(y, 1));
			if y % 2 > 0 then
				self.KeyTable[i] = bxor(self.KeyTable[i], 2567483615)
			end
		end

	end

	local res = self.KeyTable[self.State]

	res = bxor(res, rshift(res, 11))
	res = bxor(res, band(lshift(res, 7), 0x000000009D2C5680))
	res = bxor(res, band(lshift(res, 15), 0x00000000EFC60000))
	res = bxor(res, rshift(res, 18))

	self.State = (self.State + 1) % k_MTLength

	return min + ((res % max) - min)

end

mt19937_meta.__index = mt19937_meta

function mt19937(seed)

	seed = seed or 0

	local new = {}
	setmetatable(new, mt19937_meta)

	new:init(seed)
	return new

end