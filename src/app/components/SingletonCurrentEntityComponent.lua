--
-- Author: Your Name
-- Date: 2017-07-04 17:38:39
-- 当前操作的entity，包括待建造、选中
--
local super = game.SingletonComponent
local SingletonCurrentEntityComponent = class("SingletonCurrentEntityComponent", super)
SingletonCurrentEntityComponent.entity = nil
SingletonCurrentEntityComponent.preEntity = nil

-- 切换entity
function SingletonCurrentEntityComponent:switch( entity )
	-- if self.entity and self.entity ~= entity then
	-- 	self:destroy()
	-- end
	self.preEntity = self.entity
	self.entity = entity
end

function SingletonCurrentEntityComponent:remove( entity )
	if self.entity == entity then
		self.entity = nil
	end
end

return SingletonCurrentEntityComponent