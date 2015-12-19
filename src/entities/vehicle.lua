function ENTITY:Initialize()
	self.Passenger = {
		{x = 0, y = 0},
	}
end

function ENTITY:IsVehicle()
	return true
end

function ENTITY:IsUsable()
	return true
end

function ENTITY:GetDriver()
end

function ENTITY:SetDriver(Entity)
	self.Driver = Entity
end

function ENTITY:OnUse(Entity)
	if self.Driver == Entity then
		self:SetDriver(nil)
	elseif self.Entity == nil or not self.Entity:IsValid() then
		self:SetDriver(Entity)
	end
end

function ENTITY:GetPassenger(Index)
	local Passenger = self.Passenger[Index]
	if Passenger then
		return Passenger.Entity
	end
end

function ENTITY:SetPassenger(Index, Entity)
	local Passenger = self.Passenger[Index]
	if Passenger then
		Passenger.Entity = Entity
	end
end