-- Author: 4812571

local AssemblyService = {}
local Assemblies = {}
local ObjectData = {}

function AssemblyService.isAssembled(Object)
	return not not ObjectData[Object]
end

function AssemblyService.isRoot(Object)
	return not not Assemblies[Object]
end

function AssemblyService.getRoot(Object)
	if not ObjectData[Object] then return nil end
	return ObjectData[Object].root
end

function AssemblyService.getAttachmentType(Object)
	if not AssemblyService.isAssembled(Object) then return nil end
	return ObjectData[Object].attachmentType
end

function AssemblyService.getAttachments(Object)
	if AssemblyService.isRoot(Object) then 
		return Assemblies[Object].attachments
	else	
		return {}
	end
end

function AssemblyService.Attach(Object, Root, AttachmentType)
	if not Assemblies[Root] then Assemblies[Root] = {attachments = {}} end
	ObjectData[Object] = {attachmentType = AttachmentType, root = Root}
	Assemblies[Root]["attachments"][Object] = true
end

function AssemblyService.SetAttachmentType(Object, AttachmentType)
	ObjectData[Object].attachmentType = AttachmentType
end

function AssemblyService.Clean(Object)
	if AssemblyService.isRoot(Object) then
		Assemblies[Object] = nil
	else
		Assemblies[AssemblyService.getRoot(Object)][Object] = false
		ObjectData[Object] = nil
	end
end

return AssemblyService