-- Author: 4812571

-- StorageComponent Class
local StorageComponent = {}
StorageComponent.__index = StorageComponent

function StorageComponent:UpdateActivity()
	local network = self.network
	local eventComponent = network.eventComponent

	-- Update
	network.charged = self.charge > 0
end

function StorageComponent:Apply()
	
	local function SetBars(node, charge, storage)
		local fill = charge / storage
		for animator, _ in pairs(self.storageAnimators[node]) do animator:SetFill(fill) end
	end
	
	local function SetValues(node, charge)
		for replicator, _ in pairs(self.valueReplicators[node]) do replicator:SetValue(charge) end
	end
	
	local function Push(amount)
		local storagesCount = self.storageCount
		local toPush = amount
		
		-- Loop
		while true do
			local node = self.storageArray[self.insertionIndex]
			local capacity = node.storage - node.charge
			local pushing = math.min(capacity, toPush)
			toPush -= pushing
			node.charge += pushing
			if self.storageAnimators[node] then SetBars(node, node.charge, node.storage) end
			if self.valueReplicators[node] then SetValues(node, node.charge) end
			if pushing < capacity then break end -- Push Complete
			if self.insertionIndex == storagesCount then break end -- Out of storage
			self.insertionIndex += 1
		end
		
		self.extractionIndex = math.max(self.insertionIndex, self.extractionIndex)
	end
	
	local function Pull(amount)
		local toPull = amount
		
		-- Loop
		while true do
			local node = self.storageArray[self.extractionIndex]
			local charge = node.charge
			local pulling = math.min(charge, toPull)
			toPull -= pulling
			node.charge -= pulling
			if self.storageAnimators[node] then SetBars(node, node.charge, node.storage) end
			if self.valueReplicators[node] then SetValues(node, node.charge) end
			if pulling < charge then break end -- Push Complete
			if self.extractionIndex == 1 then break end -- Out of storage
			self.extractionIndex -= 1
		end
		self.insertionIndex = math.min(self.insertionIndex, self.extractionIndex)
	end
	
	local dCharge = math.abs(self.deltaCharge)
	local sign = math.sign(self.deltaCharge)
	
	if sign == 1 then Push(math.abs(self.deltaCharge)) end
	if sign == -1 then Pull(math.abs(self.deltaCharge)) end
	if sign ~= 0 then self.network.eventComponent:Fire("ChargeUpdated", self.charge, self.deltaCharge) end
	self.deltaCharge = 0
end

function StorageComponent:Push(amount)
	local capacity = (self.storage - self.charge)
	if capacity == 0 then return 0 end
	local flux = math.min(amount, capacity)
	self.charge += flux
	self.deltaCharge += flux
	if self.charge == self.storage then self.network.eventComponent:Fire("Filled") end
	
	return flux
end

function StorageComponent:Pull(amount)
	local charge = self.charge
	if charge == 0 then return 0 end
	local flux = math.min(amount, charge)
	self.charge -= flux
	self.deltaCharge -= flux
	if self.charge == 0 then self.network.eventComponent:Fire("Emptied") end
	
	return flux
end

function StorageComponent:AttachAnimator(chargeAnimator)
	if not self.storageAnimators[chargeAnimator.node] then self.storageAnimators[chargeAnimator.node] = {} end
	self.storageAnimators[chargeAnimator.node][chargeAnimator] = true
end

function StorageComponent:AttachReplicator(valueReplicator)
	if not self.valueReplicators[valueReplicator.node] then self.valueReplicators[valueReplicator.node] = {} end
	self.valueReplicators[valueReplicator.node][valueReplicator] = true
end

-- Service
local module = {}

function module.New(network, storageOrdered)
	local storageCount = #storageOrdered
	local insertionIndex, extractionIndex
	local storage, charge = 0, 0
	
	for _, v in ipairs(storageOrdered) do
		charge += v.charge or 0
		storage += v.storage or 0
	end
	
	for i = 1, storageCount, 1 do
		if storageOrdered[i].charge == storageOrdered[i].storage then continue end
		insertionIndex = i break
	end

	for i = storageCount, 1, -1 do
		if storageOrdered[i].charge == 0 then continue end
		extractionIndex = i break
	end
	
	local object = {
		network = network;
		storageArray = storageOrdered;
		storageCount = storageCount;
		storageAnimators = {};
		valueReplicators = {};
		insertionIndex =  insertionIndex or storageCount;
		extractionIndex = extractionIndex or 1;
		storage = storage;
		charge = charge;
		deltaCharge = 0;
	}
	
	return setmetatable(object, StorageComponent)
end

return module