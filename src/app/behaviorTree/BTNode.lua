BTStatus = {ST_RUNNING = "running", ST_TRUE = "true", ST_FALSE = "false"}

local BTNode = class("BTNode")

BTNode.id = nil
BTNode.name = nil
BTNode.status = BTStatus.ST_TRUE
BTNode.active = false
BTNode.children = {}
BTNode.preconditions = {}
BTNode.tree = nil
BTNode.entity = nil
BTNode.method = nil
BTNode.level = 0

function BTNode:ctor( entity )
	self:init(entity)
end

function BTNode:init( entity )
	self.id = nil
	self.name = nil
	self.status = BTStatus.ST_RUNNING
	self.active = false
	self.children = {}
	self.preconditions = {}
	self.tree = nil
	self.entity = entity
	self.method = nil
	self.level = 0
end

function BTNode:load( tree, id )
	self.id = id
	self.name = tree[id].name
	self.tree = tree

	-- properties
	local data = tree[id]
	self:load_property(data)
end

function BTNode:load_property( data )
	for k, v in pairs(data.properties or {}) do
		if k == "method" then
			assert(self.method == nil, "not allow multi method in properties!")
			self.method = {target = v.target, method = v.method}
		elseif k == "precondition" then
			table.insert(self.preconditions, game.BTFactory.createNode(self.tree, v, self.entity))
		end
	end
end

function BTNode:enter( ... )
	
end

function BTNode:exit( ... )
	
end

function BTNode:tick( ... )
	-- print("BTNode tick")
	if self:evaluate() then
		return self:execute()
	end
	print(self:toString(), " evalute failed")
	return BTStatus.ST_FALSE
end

function BTNode:execute( ... )
	-- print("BTNode execute")
	if self.method then
		local target = self.method.target
		local method = self.method.method
		local aiComponent = game.EntityManager:getInstance():getComponent("AIComponent", self.entity)
		print("execute entity", self.entity)
		local r = game[target][method](self.entity, aiComponent.blackboard)
		print(self:toString(), " method ", method, " ", r)
		self.status = r
	end
	return self.status
end

-- 激活
function BTNode:activate( ... )
	-- print("BTNode activate")
	if self.active then
		return
	end
	for i,v in ipairs(self.preconditions) do
		v:activate()
		v:enter()
	end
	-- print("activate ", self:toString(), #self.children, self)
	for i,v in ipairs(self.children) do
		v:activate()
		v:enter()
	end
	self.active = true
	self:enter()
end

-- 评估是否可执行
function BTNode:evaluate( ... )
	-- print("BTNode evaluate")
	if not self.active then
		print(self:toString(), "evaluate not active")
		return false
	end
	for i,v in ipairs(self.preconditions) do
		-- print("precondition evaluate ", self:toString())
		if v:tick() ~= BTStatus.ST_TRUE then
			-- 失败后停止所有running子节点
			self:stop()
			return false
		end
	end

	return self:_evaluate()
end

-- 用于子节点的自定义评估
function BTNode:_evaluate( ... )
	return true
end

-- 停止running节点
function BTNode:stop( ... )
	if self.status == BTStatus.ST_RUNNING then
		self.status = BTStatus.ST_FALSE
		self:_stop()
	end
	for i,v in ipairs(self.children) do
		v:stop()
	end
end

function BTNode:_stop( ... )
	
end

function BTNode:clear( ... )
	for i,v in ipairs(self.preconditions) do
		v:clear()
		v:exit()
	end
	for i,v in ipairs(self.children) do
		v:clear()
		v:exit()
	end
	self.active = false
	self.status = BTStatus.ST_FALSE
end

function BTNode:toString( ... )
	return self.name
end


function BTNode:setStatus(value)
	self.status = value
end

function BTNode:getStatus()
	return self.status
end

function BTNode:setChildren(value)
	self.children = value
end

function BTNode:getChildren()
	return self.children
end

return BTNode