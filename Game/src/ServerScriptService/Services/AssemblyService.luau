-- Author: 4812571



local module = {}
local Assemblies = {}
local ObjectData = {}

module.isAssembled = function(Object)
	return not not ObjectData[Object]
end

module.isRoot = function(Object)
	return not not Assemblies[Object]
end

module.getRoot = function(Object)
	if not ObjectData[Object] then return nil end
	return ObjectData[Object].root
end

module.getAttachmentType = function(Object)
	if not module.isAssembled(Object) then return nil end
	return ObjectData[Object].attachmentType
end

module.getAttachments = function(Object)
	if module.isRoot(Object) then 
		return Assemblies[Object].attachments
	else	
		return {}
	end
end

module.Attach = function(Object, Root, AttachmentType)
	if not Assemblies[Root] then Assemblies[Root] = {attachments = {}} end
	ObjectData[Object] = {attachmentType = AttachmentType, root = Root}
	Assemblies[Root]["attachments"][Object] = true
end

module.SetAttachmentType = function(Object, AttachmentType)
	ObjectData[Object].attachmentType = AttachmentType
end


module.Clean = function(Object)
	if module.isRoot(Object) then
		Assemblies[Object] = nil
	else
		Assemblies[module.getRoot(Object)][Object] = false
		ObjectData[Object] = nil
	end
end


return module