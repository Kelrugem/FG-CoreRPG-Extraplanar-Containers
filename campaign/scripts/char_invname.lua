--
--	Please see the LICENSE.md file included with this distribution for attribution and copyright information.
--

-- luacheck: globals onDoubleClick onLoseFocus

function onDoubleClick()
	local nodeItem = window.getDatabaseNode()
	local sName = DB.getValue(nodeItem, 'name', '')
	if not ExtraplanarContainers.isAnyContainer(sName) then return false end

	local sNonIDName = DB.getValue(nodeItem, 'nonid_name', '')
	if not sName:match('%[%+%]%s+') then
		DB.setValue(nodeItem, 'name', 'string', '[+] ' .. sName)
		DB.setValue(nodeItem, 'nonid_name', 'string', '[+] ' .. sNonIDName)
	else
		DB.setValue(nodeItem, 'name', 'string', sName:gsub('%[%+%]%s+', ''))
		DB.setValue(nodeItem, 'nonid_name', 'string', sNonIDName:gsub('%[%+%]%s+', ''))
	end
	return true
end

function onLoseFocus()
	super.onLoseFocus()
	window.windowlist.updateContainers()
end

-- everything below here is responsible for setting the weight to red if the container is overfull

local tTooltips = { ['announcedW'] = 'weight', ['announcedC'] = 'weight', ['announcedV'] = 'volume' }

local function setWindowcontrolColors(node, bHighlight)
	local sTooltip = ''
	local sNodeName = DB.getName(node)
	if not tTooltips[sNodeName] then return end
	if bHighlight then
		sTooltip = string.format(Interface.getString('item_tooltip_overfull'), tTooltips[sNodeName])
	end

	for sNode, _ in pairs(tTooltips) do
		if sNodeName == sNode then
			window.weight.setTooltipText(sTooltip)
			if bHighlight then
				window.weight.setFrame("required", 7,5,7,5)
				break
			end
			window.weight.setFrame("fielddark", 7,5,7,5)
			break
		end
	end
end

local function onAnnounced(_, child)
	setWindowcontrolColors(child, true)
end

local function onUnannounced(source)
	setWindowcontrolColors(source, false)
end

function onInit()
	for sNodeName, _ in pairs(tTooltips) do
		local nodeWeightAnnounced = DB.getChild(window.getDatabaseNode(), sNodeName)
		if nodeWeightAnnounced then onAnnounced(nil, nodeWeightAnnounced) end
	end
	if super and super.onInit then super.onInit() end
	DB.addHandler(DB.getPath(window.getDatabaseNode()), 'onChildAdded', onAnnounced)
	DB.addHandler(DB.getPath(window.getDatabaseNode()) .. '.*', 'onDelete', onUnannounced)
end

function onClose()
	if super and super.onClose then super.onClose() end
	DB.removeHandler(DB.getPath(window.getDatabaseNode()), 'onChildAdded', onAnnounced)
	DB.removeHandler(DB.getPath(window.getDatabaseNode()) .. '.*', 'onDelete', onUnannounced)
end