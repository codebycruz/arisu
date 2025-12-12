local Element = require("arisu-app.ui.element")

---@class arisu.plugin.Text
---@field renderPlugin arisu.plugin.Render
local Text = {}
Text.__index = Text

---@param renderPlugin arisu.plugin.Render
function Text.new(renderPlugin) ---@return arisu.plugin.Text
	return setmetatable({ renderPlugin = renderPlugin }, Text)
end

---@param element arisu.Element
---@return arisu.Element
function Text:convertTextElements(element)
	if element.type == "text" then
		local fontManager = self.renderPlugin.sharedResources.fontManager
		assert(fontManager, "Font manager not initialized in render plugin")

		---@type string
		local value = element.userdata

		local fg = element.visualStyle.fg or { r = 0.0, g = 0.0, b = 0.0, a = 1.0 }

		local font = element.visualStyle.font or fontManager:getDefault()
		local fontBitmap = fontManager:getBitmap(font)
		local uvs = fontBitmap:getStringUVs(value)

		local children = {}
		for i = 1, #uvs do
			local quad = uvs[i]

			children[i] = Element.new("div"):withStyle({
				bg = fg,
				bgImage = font,
				bgImageUV = quad,
				width = { abs = quad.width },
				height = { abs = quad.height },
			})
		end

		-- INFO: This shouldn't cause any problems but who knows. maybe we'll use the old ui.
		element.type = "div"
		element.layoutStyle.direction = "row"
		element.children = children
		return element
	end

	if element.children then
		local newChildren = {}
		for _, child in ipairs(element.children) do
			table.insert(newChildren, self:convertTextElements(child))
		end

		element.children = newChildren
	end

	return element
end

return Text
