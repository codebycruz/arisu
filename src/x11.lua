local ffi = require("ffi")

ffi.cdef[[
    typedef void Display;
    typedef unsigned long Window;
    typedef unsigned long Atom;
    typedef int Bool;

    typedef union {
        int type;
        struct {
            int type;
            unsigned long serial;
            Bool send_event;
            Display *display;
            Window window;
            Atom message_type;
            int format;
            union {
                char b[20];
                short s[10];
                long l[5];
            } data;
        } xclient;
    } XEvent;

    Display* XOpenDisplay(const char* display_name);
    int XCloseDisplay(Display* display);
    void XDestroyWindow(Display* display, unsigned long window);
    Window XDefaultRootWindow(Display* display);
    Window XCreateSimpleWindow(Display* display, Window parent, int x, int y, unsigned int width, unsigned int height, unsigned int border_width, unsigned long border, unsigned long background);
    void XMapWindow(Display* display, Window w);
    Atom XInternAtom(Display* display, const char* atom_name, Bool only_if_exists);
    void XSetWMProtocols(Display* display, Window w, Atom* protocols, int count);
    void XNextEvent(Display* display, XEvent* event_return);
    int XDefaultScreen(Display* display);
    int XPending(Display* display);
]]

local C = ffi.load("X11")

---@class Event: userdata
---@field type number
---@field xclient { data: { l: number[] }, display: userdata, window: number }

return {
    ---@type fun(display_name: string): userdata?
    openDisplay = C.XOpenDisplay,

    ---@type fun(display: userdata): number
    closeDisplay = C.XCloseDisplay,

    ---@type fun(display: userdata, window: number)
    destroyWindow = C.XDestroyWindow,

    ---@type fun(display: userdata): number
    defaultRootWindow = C.XDefaultRootWindow,

    ---@type fun(display: userdata, parent: number, x: number, y: number, width: number, height: number, border_width: number, border: number, background: number): number
    createSimpleWindow = C.XCreateSimpleWindow,

    ---@type fun(display: userdata, w: number)
    mapWindow = C.XMapWindow,

    ---@type fun(display: userdata, atom_name: string, only_if_exists: number): number
    internAtom = C.XInternAtom,

    ---@type fun(display: userdata, w: number, protocols: userdata, count: number)
    setWMProtocols = C.XSetWMProtocols,

    ---@type fun(display: userdata, event_return: Event)
    nextEvent = C.XNextEvent,

    ---@type fun(display: userdata): number
    defaultScreen = C.XDefaultScreen,

    ---@type fun(display: userdata): number
    pending = C.XPending,

    None = 0,
    ClientMessage = 33,
    False = 0,
    True = 1,

    --- @type fun(): Event
    newEvent = function() return ffi.new("XEvent") end,

    newAtomArray = function(size) return ffi.new("Atom[?]", size) end,
}
