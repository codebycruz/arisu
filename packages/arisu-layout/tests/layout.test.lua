local test = require("lde-test")
local Layout = require("arisu-layout.layout")
local Element = require("arisu-layout.element")

-- helpers
---@param w number
---@param h number
---@param extra table?
local function makeChild(w, h, extra)
	local l = Layout.new()
	l.width = w
	l.height = h
	if extra then
		for k, v in pairs(extra) do l[k] = v end
	end
	return l
end

-- ────────────────────────────────────────────────────────────────
-- Layout.new defaults
-- ────────────────────────────────────────────────────────────────

test.it("Layout.new has rel=1.0 width and height by default", function()
	local l = Layout.new()
	test.match(l.width, { rel = 1.0 })
	test.match(l.height, { rel = 1.0 })
end)

test.it("Layout.new defaults to row direction", function()
	local l = Layout.new()
	test.equal(l.direction, "row")
end)

test.it("Layout.new defaults to static position", function()
	local l = Layout.new()
	test.equal(l.position, "static")
end)

test.it("Layout.new has zero zIndex by default", function()
	local l = Layout.new()
	test.equal(l.zIndex, 0)
end)

-- ────────────────────────────────────────────────────────────────
-- Basic sizing
-- ────────────────────────────────────────────────────────────────

test.it("rel=1.0 fills parent", function()
	local l = Layout.new()
	local r = l:solve(400, 300)
	test.equal(r.width, 400)
	test.equal(r.height, 300)
end)

test.it("rel=0.5 is half of parent", function()
	local l = Layout.new()
	l.width = { rel = 0.5 }
	l.height = { rel = 0.5 }
	local r = l:solve(400, 300)
	test.equal(r.width, 200)
	test.equal(r.height, 150)
end)

test.it("abs size is fixed regardless of parent", function()
	local l = Layout.new()
	l.width = { abs = 120 }
	l.height = { abs = 80 }
	local r = l:solve(400, 300)
	test.equal(r.width, 120)
	test.equal(r.height, 80)
end)

test.it("auto width fills available parent space", function()
	local l = Layout.new()
	l.width = "auto"
	l.height = { abs = 50 }
	local r = l:solve(400, 300)
	test.equal(r.width, 400)
end)

test.it("solve result has visible=true for normal elements", function()
	local r = Layout.new():solve(100, 100)
	test.equal(r.visible, true)
end)

test.it("solve result origin is (0,0) with no margin", function()
	local r = Layout.new():solve(100, 100)
	test.equal(r.x, 0)
	test.equal(r.y, 0)
end)

-- ────────────────────────────────────────────────────────────────
-- Visibility
-- ────────────────────────────────────────────────────────────────

test.it("visibility=none returns zero size", function()
	local l = Layout.new()
	l.visibility = "none"
	local r = l:solve(400, 300)
	test.equal(r.width, 0)
	test.equal(r.height, 0)
end)

test.it("visibility=none returns visible=false", function()
	local l = Layout.new()
	l.visibility = "none"
	local r = l:solve(400, 300)
	test.equal(r.visible, false)
end)

test.it("visibility=none returns no children", function()
	local l = Layout.new()
	l.visibility = "none"
	local r = l:solve(400, 300)
	test.equal(#r.children, 0)
end)

-- ────────────────────────────────────────────────────────────────
-- Margin
-- ────────────────────────────────────────────────────────────────

test.it("margin.left offsets element x", function()
	local l = Layout.new()
	l.margin = { left = 20 }
	local r = l:solve(400, 300)
	test.equal(r.x, 20)
end)

test.it("margin.top offsets element y", function()
	local l = Layout.new()
	l.margin = { top = 15 }
	local r = l:solve(400, 300)
	test.equal(r.y, 15)
end)

test.it("margin reduces available width for rel children", function()
	local l = Layout.new()
	l.margin = { left = 10, right = 10 }
	-- rel=1.0 of (400 - 10 - 10) = 380
	local r = l:solve(400, 300)
	test.equal(r.width, 380)
end)

test.it("margin reduces available height for rel children", function()
	local l = Layout.new()
	l.margin = { top = 20, bottom = 30 }
	local r = l:solve(400, 300)
	test.equal(r.height, 250)
end)

-- ────────────────────────────────────────────────────────────────
-- Padding
-- ────────────────────────────────────────────────────────────────

test.it("padding.left shifts child x in row", function()
	local parent = Layout.new()
	parent.padding = { left = 10 }
	parent:withChildren({ makeChild({ abs = 50 }, { rel = 1.0 }) })
	local r = parent:solve(400, 300)
	test.equal(r.children[1].x, 10)
end)

test.it("padding.top shifts child y in row", function()
	local parent = Layout.new()
	parent.padding = { top = 8 }
	parent:withChildren({ makeChild({ abs = 50 }, { rel = 1.0 }) })
	local r = parent:solve(400, 300)
	test.equal(r.children[1].y, 8)
end)

test.it("padding reduces content area for children", function()
	local parent = Layout.new()
	parent.padding = { left = 20, right = 20, top = 10, bottom = 10 }
	parent:withChildren({ makeChild({ rel = 1.0 }, { rel = 1.0 }) })
	local r = parent:solve(400, 300)
	-- content area: 360 x 280
	test.equal(r.children[1].width, 360)
	test.equal(r.children[1].height, 280)
end)

-- ────────────────────────────────────────────────────────────────
-- Border
-- ────────────────────────────────────────────────────────────────

test.it("border width reduces content area", function()
	local parent = Layout.new()
	parent.border = {
		left = { width = 5 },
		right = { width = 5 },
		top = { width = 3 },
		bottom = { width = 3 }
	}
	parent:withChildren({ makeChild({ rel = 1.0 }, { rel = 1.0 }) })
	local r = parent:solve(400, 300)
	test.equal(r.children[1].width, 390)
	test.equal(r.children[1].height, 294)
end)

-- ────────────────────────────────────────────────────────────────
-- Row direction
-- ────────────────────────────────────────────────────────────────

test.it("row: two children are placed side by side", function()
	local parent = Layout.new()
	parent.direction = "row"
	parent:withChildren({
		makeChild({ abs = 100 }, { rel = 1.0 }),
		makeChild({ abs = 200 }, { rel = 1.0 })
	})
	local r = parent:solve(400, 300)
	test.equal(r.children[1].x, 0)
	test.equal(r.children[2].x, 100)
end)

test.it("row: children share full cross-axis height", function()
	local parent = Layout.new()
	parent.direction = "row"
	parent:withChildren({
		makeChild({ abs = 100 }, { rel = 1.0 }),
		makeChild({ abs = 100 }, { rel = 1.0 })
	})
	local r = parent:solve(400, 300)
	test.equal(r.children[1].height, 300)
	test.equal(r.children[2].height, 300)
end)

test.it("row: children y is 0 with no padding/margin", function()
	local parent = Layout.new()
	parent.direction = "row"
	parent:withChildren({
		makeChild({ abs = 100 }, { rel = 1.0 }),
		makeChild({ abs = 100 }, { rel = 1.0 })
	})
	local r = parent:solve(400, 300)
	test.equal(r.children[1].y, 0)
	test.equal(r.children[2].y, 0)
end)

-- ────────────────────────────────────────────────────────────────
-- Column direction
-- ────────────────────────────────────────────────────────────────

test.it("column: two children are stacked vertically", function()
	local parent = Layout.new()
	parent.direction = "column"
	parent:withChildren({
		makeChild({ rel = 1.0 }, { abs = 80 }),
		makeChild({ rel = 1.0 }, { abs = 120 })
	})
	local r = parent:solve(400, 300)
	test.equal(r.children[1].y, 0)
	test.equal(r.children[2].y, 80)
end)

test.it("column: children share full cross-axis width", function()
	local parent = Layout.new()
	parent.direction = "column"
	parent:withChildren({
		makeChild({ rel = 1.0 }, { abs = 80 }),
		makeChild({ rel = 1.0 }, { abs = 80 })
	})
	local r = parent:solve(400, 300)
	test.equal(r.children[1].width, 400)
	test.equal(r.children[2].width, 400)
end)

test.it("column: children x is 0 with no padding/margin", function()
	local parent = Layout.new()
	parent.direction = "column"
	parent:withChildren({
		makeChild({ rel = 1.0 }, { abs = 80 })
	})
	local r = parent:solve(400, 300)
	test.equal(r.children[1].x, 0)
end)

-- ────────────────────────────────────────────────────────────────
-- Gap
-- ────────────────────────────────────────────────────────────────

test.it("gap adds space between children in row", function()
	local parent = Layout.new()
	parent.direction = "row"
	parent.gap = 20
	parent:withChildren({
		makeChild({ abs = 100 }, { rel = 1.0 }),
		makeChild({ abs = 100 }, { rel = 1.0 })
	})
	local r = parent:solve(400, 300)
	test.equal(r.children[1].x, 0)
	test.equal(r.children[2].x, 120)
end)

test.it("gap adds space between children in column", function()
	local parent = Layout.new()
	parent.direction = "column"
	parent.gap = 15
	parent:withChildren({
		makeChild({ rel = 1.0 }, { abs = 50 }),
		makeChild({ rel = 1.0 }, { abs = 50 })
	})
	local r = parent:solve(400, 300)
	test.equal(r.children[1].y, 0)
	test.equal(r.children[2].y, 65)
end)

test.it("gap is not applied after the last child", function()
	local parent = Layout.new()
	parent.direction = "row"
	parent.gap = 20
	parent:withChildren({
		makeChild({ abs = 100 }, { rel = 1.0 })
	})
	local r = parent:solve(400, 300)
	-- single child: gap doesn't apply, x=0
	test.equal(r.children[1].x, 0)
end)

-- ────────────────────────────────────────────────────────────────
-- Justify
-- ────────────────────────────────────────────────────────────────

test.it("justify=start places children at the beginning", function()
	local parent = Layout.new()
	parent.justify = "start"
	parent:withChildren({
		makeChild({ abs = 100 }, { rel = 1.0 }),
		makeChild({ abs = 100 }, { rel = 1.0 })
	})
	local r = parent:solve(400, 300)
	test.equal(r.children[1].x, 0)
	test.equal(r.children[2].x, 100)
end)

test.it("justify=center centers children", function()
	local parent = Layout.new()
	parent.justify = "center"
	parent:withChildren({
		makeChild({ abs = 100 }, { rel = 1.0 }),
		makeChild({ abs = 100 }, { rel = 1.0 })
	})
	-- total=200, free=200, offset=100
	local r = parent:solve(400, 300)
	test.equal(r.children[1].x, 100)
	test.equal(r.children[2].x, 200)
end)

test.it("justify=end places children at the end", function()
	local parent = Layout.new()
	parent.justify = "end"
	parent:withChildren({
		makeChild({ abs = 100 }, { rel = 1.0 }),
		makeChild({ abs = 100 }, { rel = 1.0 })
	})
	-- total=200, free=200, offset=200
	local r = parent:solve(400, 300)
	test.equal(r.children[1].x, 200)
	test.equal(r.children[2].x, 300)
end)

test.it("justify=space-between distributes space evenly between children", function()
	local parent = Layout.new()
	parent.justify = "space-between"
	parent:withChildren({
		makeChild({ abs = 100 }, { rel = 1.0 }),
		makeChild({ abs = 100 }, { rel = 1.0 })
	})
	-- total=200, free=200, spacing=200/1=200
	local r = parent:solve(400, 300)
	test.equal(r.children[1].x, 0)
	test.equal(r.children[2].x, 300)
end)

test.it("justify=space-around puts equal space around each child", function()
	local parent = Layout.new()
	parent.justify = "space-around"
	parent:withChildren({
		makeChild({ abs = 100 }, { rel = 1.0 }),
		makeChild({ abs = 100 }, { rel = 1.0 })
	})
	-- free=200, spaceUnit=100, offset=50, spacing=100
	local r = parent:solve(400, 300)
	test.equal(r.children[1].x, 50)
	test.equal(r.children[2].x, 250)
end)

-- ────────────────────────────────────────────────────────────────
-- Align
-- ────────────────────────────────────────────────────────────────

test.it("align=start places children at the cross-axis start", function()
	local parent = Layout.new()
	parent.direction = "row"
	parent.align = "start"
	parent:withChildren({
		makeChild({ abs = 100 }, { abs = 50 })
	})
	local r = parent:solve(400, 300)
	test.equal(r.children[1].y, 0)
end)

test.it("align=center centers children on the cross axis", function()
	local parent = Layout.new()
	parent.direction = "row"
	parent.align = "center"
	parent:withChildren({
		makeChild({ abs = 100 }, { abs = 50 })
	})
	-- cross=300, childCross=50, offset=(300-50)/2=125
	local r = parent:solve(400, 300)
	test.equal(r.children[1].y, 125)
end)

test.it("align=end places children at the cross-axis end", function()
	local parent = Layout.new()
	parent.direction = "row"
	parent.align = "end"
	parent:withChildren({
		makeChild({ abs = 100 }, { abs = 50 })
	})
	-- cross=300, childCross=50, offset=300-50=250
	local r = parent:solve(400, 300)
	test.equal(r.children[1].y, 250)
end)

test.it("align=center on column centers on x axis", function()
	local parent = Layout.new()
	parent.direction = "column"
	parent.align = "center"
	parent:withChildren({
		makeChild({ abs = 60 }, { abs = 100 })
	})
	-- cross=400, childCross=60, offset=(400-60)/2=170
	local r = parent:solve(400, 300)
	test.equal(r.children[1].x, 170)
end)

-- ────────────────────────────────────────────────────────────────
-- Auto sizing
-- ────────────────────────────────────────────────────────────────

test.it("single auto child fills all remaining space in row", function()
	local parent = Layout.new()
	parent.direction = "row"
	parent:withChildren({
		makeChild({ abs = 100 }, { rel = 1.0 }),
		makeChild("auto", { rel = 1.0 })
	})
	local r = parent:solve(400, 300)
	test.equal(r.children[2].width, 300)
end)

test.it("single auto child is positioned after fixed sibling", function()
	local parent = Layout.new()
	parent.direction = "row"
	parent:withChildren({
		makeChild({ abs = 100 }, { rel = 1.0 }),
		makeChild("auto", { rel = 1.0 })
	})
	local r = parent:solve(400, 300)
	test.equal(r.children[2].x, 100)
end)

test.it("two auto children split remaining space equally", function()
	local parent = Layout.new()
	parent.direction = "row"
	parent:withChildren({
		makeChild({ abs = 100 }, { rel = 1.0 }),
		makeChild("auto", { rel = 1.0 }),
		makeChild("auto", { rel = 1.0 })
	})
	-- remaining = 400-100=300, split 2 ways = 150 each
	local r = parent:solve(400, 300)
	test.equal(r.children[2].width, 150)
	test.equal(r.children[3].width, 150)
end)

test.it("auto in column fills remaining vertical space", function()
	local parent = Layout.new()
	parent.direction = "column"
	parent:withChildren({
		makeChild({ rel = 1.0 }, { abs = 80 }),
		makeChild({ rel = 1.0 }, "auto")
	})
	local r = parent:solve(400, 300)
	test.equal(r.children[2].height, 220)
end)

-- ────────────────────────────────────────────────────────────────
-- Relative positioning
-- ────────────────────────────────────────────────────────────────

test.it("relative position adds left offset", function()
	local l = Layout.new()
	l.position = "relative"
	l.left = 30
	local r = l:solve(400, 300)
	test.equal(r.x, 30)
end)

test.it("relative position adds top offset", function()
	local l = Layout.new()
	l.position = "relative"
	l.top = 25
	local r = l:solve(400, 300)
	test.equal(r.y, 25)
end)

test.it("relative position uses right when left is absent", function()
	local l = Layout.new()
	l.position = "relative"
	l.right = 20
	local r = l:solve(400, 300)
	test.equal(r.x, -20)
end)

test.it("relative position uses bottom when top is absent", function()
	local l = Layout.new()
	l.position = "relative"
	l.bottom = 10
	local r = l:solve(400, 300)
	test.equal(r.y, -10)
end)

test.it("relative positioned child does not push siblings in row", function()
	local parent = Layout.new()
	parent.direction = "row"
	parent:withChildren({
		makeChild({ abs = 100 }, { rel = 1.0 }, { position = "relative" }),
		makeChild({ abs = 100 }, { rel = 1.0 })
	})
	-- relative child doesn't participate in flow, static child starts at 0
	local r = parent:solve(400, 300)
	test.equal(r.children[2].x, 0)
end)

-- ────────────────────────────────────────────────────────────────
-- Nested children
-- ────────────────────────────────────────────────────────────────

test.it("nested child positions are relative to parent content area", function()
	local grandparent = Layout.new()
	grandparent.direction = "row"

	local parent = makeChild({ abs = 200 }, { rel = 1.0 })
	parent.direction = "row"
	parent:withChildren({ makeChild({ abs = 50 }, { rel = 1.0 }) })

	grandparent:withChildren({ parent })

	local r = grandparent:solve(400, 300)
	-- grandchild x is relative to parent content, not grandparent
	test.equal(r.children[1].children[1].x, 0)
	test.equal(r.children[1].children[1].width, 50)
end)

test.it("nested layout passes correct dimensions to children", function()
	local parent = Layout.new()
	parent.padding = { left = 20, right = 20 }
	parent:withChildren({ makeChild({ rel = 1.0 }, { rel = 1.0 }) })
	local r = parent:solve(400, 300)
	-- content width = 400-40=360
	test.equal(r.children[1].width, 360)
end)

-- ────────────────────────────────────────────────────────────────
-- zIndex
-- ────────────────────────────────────────────────────────────────

test.it("zIndex is preserved in computed layout", function()
	local l = Layout.new()
	l.zIndex = 5
	local r = l:solve(400, 300)
	test.equal(r.zIndex, 5)
end)

test.it("zIndex=0 is the default", function()
	local r = Layout.new():solve(400, 300)
	test.equal(r.zIndex, 0)
end)

-- ────────────────────────────────────────────────────────────────
-- Layout.fromElement
-- ────────────────────────────────────────────────────────────────

test.it("fromElement creates a layout from a plain element", function()
	local el = Element.new("div")
	local layout = Layout.fromElement(el)
	test.truthy(layout)
	-- defaults are applied
	test.match(layout.width, { rel = 1.0 })
end)

test.it("fromElement applies layoutStyle fields", function()
	local el = Element.new("div"):withStyle({
		direction = "column",
		width = { abs = 150 },
		height = { abs = 80 }
	})
	local layout = Layout.fromElement(el)
	test.equal(layout.direction, "column")
	test.match(layout.width, { abs = 150 })
	test.match(layout.height, { abs = 80 })
end)

test.it("fromElement attaches visualStyle", function()
	local style = { bg = { r = 1, g = 0, b = 0, a = 1 } }
	local el = Element.new("div"):withStyle(style)
	local layout = Layout.fromElement(el)
	test.equal(layout.style.bg.r, 1)
end)

test.it("fromElement converts nested children recursively", function()
	local child = Element.new("span"):withStyle({ width = { abs = 50 } })
	local parent = Element.new("div"):withChildren({ child })
	local layout = Layout.fromElement(parent)
	test.equal(#layout.children, 1)
	test.match(layout.children[1].width, { abs = 50 })
end)

test.it("fromElement handles deeply nested elements", function()
	local grandchild = Element.new("span"):withStyle({ width = { abs = 30 } })
	local child = Element.new("div"):withChildren({ grandchild })
	local parent = Element.new("section"):withChildren({ child })
	local layout = Layout.fromElement(parent)
	test.equal(#layout.children[1].children, 1)
	test.match(layout.children[1].children[1].width, { abs = 30 })
end)

test.it("fromElement: solve produces correct geometry for element tree", function()
	local child = Element.new("span"):withStyle({
		width = { abs = 100 },
		height = { rel = 1.0 }
	})
	local parent = Element.new("div"):withChildren({ child })
	local layout = Layout.fromElement(parent)
	local r = layout:solve(400, 300)
	test.equal(r.children[1].width, 100)
	test.equal(r.children[1].height, 300)
	test.equal(r.children[1].x, 0)
end)

-- ────────────────────────────────────────────────────────────────
-- Element
-- ────────────────────────────────────────────────────────────────

test.it("Element.new has the given type", function()
	local el = Element.new("button")
	test.equal(el.type, "button")
end)

test.it("Element.from converts a string to a text element", function()
	local el = Element.from("hello")
	test.equal(el.type, "text")
	test.equal(el.userdata, "hello")
end)

test.it("Element.from returns the element unchanged", function()
	local original = Element.new("div")
	local el = Element.from(original)
	test.equal(el, original)
end)

test.it("withId sets the id field", function()
	local el = Element.new("div"):withId("my-id")
	test.equal(el.id, "my-id")
end)

test.it("withChildren auto-converts strings to text elements", function()
	local el = Element.new("div"):withChildren({ "hello", "world" })
	test.equal(#el.children, 2)
	test.equal(el.children[1].type, "text")
	test.equal(el.children[2].type, "text")
end)

test.it("withUserdata stores arbitrary data", function()
	local el = Element.new("div"):withUserdata({ foo = 42 })
	test.equal(el.userdata.foo, 42)
end)

test.it("onClick stores the message on the element", function()
	local el = Element.new("button"):onClick("clicked")
	test.equal(el.onclick, "clicked")
end)

test.it("onMouseDown stores the constructor", function()
	local fn = function(x, y) return { x = x, y = y } end
	local el = Element.new("div"):onMouseDown(fn)
	test.equal(el.onmousedown, fn)
end)

test.it("onMouseUp stores the message", function()
	local el = Element.new("div"):onMouseUp("released")
	test.equal(el.onmouseup, "released")
end)

test.it("onMouseMove stores the message", function()
	local el = Element.new("div"):onMouseMove("moved")
	test.equal(el.onmousemove, "moved")
end)

return test
