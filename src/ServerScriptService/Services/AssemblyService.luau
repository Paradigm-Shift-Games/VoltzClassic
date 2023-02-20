-- Author: 4812571

local module = {}
local Assemblies = {}
local ObjectData = {}

function module.isAssembled(Object)
	return not not ObjectData[Object]
end

function module.isRoot(Object)
	return not not Assemblies[Object]
end

function module.getRoot(Object)
	if not ObjectData[Object] then return nil end
	return ObjectData[Object].root
end

function module.getAttachmentType(Object)
	if not module.isAssembled(Object) then return nil end
	return ObjectData[Object].attachmentType
end

function module.getAttachments(Object)
	if module.isRoot(Object) then 
		return Assemblies[Object].attachments
	else	
		return {}
	end
end

function module.Attach(Object, Root, AttachmentType)
	if not Assemblies[Root] then Assemblies[Root] = {attachments = {}} end
	ObjectData[Object] = {attachmentType = AttachmentType, root = Root}
	Assemblies[Root]["attachments"][Object] = true
end

function module.SetAttachmentType(Object, AttachmentType)
	ObjectData[Object].attachmentType = AttachmentType
end

function module.Clean(Object)
	if module.isRoot(Object) then
		Assemblies[Object] = nil
	else
		Assemblies[module.getRoot(Object)][Object] = false
		ObjectData[Object] = nil
	end
end

return module