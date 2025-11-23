local ffi = require("ffi")

ffi.cdef[[
    typedef void Display;
    typedef unsigned long Window;
    typedef unsigned long Atom;
    typedef int Bool;
    typedef int Status;
    typedef void Visual;
    typedef unsigned long Colormap;
    typedef void Screen;

    typedef struct {
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
    } XClientMessageEvent;

    typedef struct {
        int type;
        unsigned long serial;
        Bool send_event;
        Display *display;
        Window window;
        int x, y;
        int width, height;
        int count;
    } XExposeEvent;

    typedef struct {
        int type;
        unsigned long serial;
        Bool send_event;
        Display *display;
        Window event;
        Window window;
        int x, y;
        int width, height;
        int border_width;
        Window above;
        Bool override_redirect;
    } XConfigureEvent;

    typedef struct {
        int type;
        unsigned long serial;
        Bool send_event;
        Display *display;
        Window window;
    } XAnyEvent;

    typedef union {
        int type;
        XAnyEvent xany;
        XClientMessageEvent xclient;
        XExposeEvent xexpose;
        XConfigureEvent xconfigure;
        long pad[24];
    } XEvent;

    typedef struct {
        int x, y;
        int width, height;
        int border_width;
        int depth;
        Visual* visual;
        Window root;
        int class;
        int bit_gravity;
        int win_gravity;
        int backing_store;
        unsigned long backing_planes;
        unsigned long backing_pixel;
        Bool save_under;
        Colormap colormap;
        Bool map_installed;
        int map_state;
        long all_event_masks;
        long your_event_mask;
        long do_not_propagate_mask;
        Bool override_redirect;
        Screen *screen;
    } XWindowAttributes;

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
    void XSelectInput(Display* display, Window w, long event_mask);
    Status XGetWindowAttributes(Display* display, Window w, XWindowAttributes* window_attributes_return);
]]

local C = ffi.load("X11")

---@class XEvent: userdata
---@field type number
---@field xclient { data: { l: number[] }, display: userdata, window: number }
---@field xexpose { window: number }
---@field xany { window: number }
---@field xconfigure { window: number, x: number, y: number, width: number, height: number }

---@class XDisplay: userdata

---@class XWindowAttributes: userdata
---@field x number
---@field y number
---@field width number
---@field height number

return {
    ---@type fun(display_name: string): XDisplay?
    openDisplay = C.XOpenDisplay,

    ---@type fun(display: XDisplay): number
    closeDisplay = C.XCloseDisplay,

    ---@type fun(display: XDisplay, window: number)
    destroyWindow = C.XDestroyWindow,

    ---@type fun(display: XDisplay): number
    defaultRootWindow = C.XDefaultRootWindow,

    ---@type fun(display: XDisplay, parent: number, x: number, y: number, width: number, height: number, border_width: number, border: number, background: number): number
    createSimpleWindow = C.XCreateSimpleWindow,

    ---@type fun(display: XDisplay, w: number)
    mapWindow = C.XMapWindow,

    ---@type fun(display: XDisplay, atom_name: string, only_if_exists: number): number
    internAtom = C.XInternAtom,

    -- ---@type fun(display: XDisplay, w: number, protocols: userdata, count: number)
    -- setWMProtocols = C.XSetWMProtocols,

    setWMProtocols = function(display --[[@param display XDisplay]], window --[[@param window Window]], protocols --[=[@param protocols string[]]=])
        assert(display == window.display, "Display mismatch in setWMProtocols")

        local atoms = ffi.new("Atom[?]", #protocols)
        for i = 1, #protocols do
            atoms[i - 1] = C.XInternAtom(display, protocols[i], 0)
        end

        C.XSetWMProtocols(display, window.id, atoms, #protocols)
    end,

    ---@type fun(display: XDisplay, event_return: XEvent)
    nextEvent = C.XNextEvent,

    ---@type fun(display: XDisplay): number
    defaultScreen = C.XDefaultScreen,

    ---@type fun(display: XDisplay): number
    pending = C.XPending,

    ---@type fun(display: XDisplay, w: number, event_mask: number)
    selectInput = C.XSelectInput,

    ---@return XWindowAttributes?
    getWindowAttributes = function(display --[[@param display XDisplay]], w --[[@param w Window]])
        local attrs = ffi.new("XWindowAttributes")

        local status = C.XGetWindowAttributes(display, w.id, attrs)
        if status == 0 then
            return nil
        end

        return attrs
    end,

    None = 0,
    ClientMessage = 33,
    Expose = 12,
    KeyPress = 2,
    KeyRelease = 3,
    UnmapNotify = 18,
    MapNotify = 19,
    ConfigureNotify = 22,
    DestroyNotify = 17,
    False = 0,
    True = 1,
    ExposureMask = 0x00008000,
    KeyPressMask = 0x00000001,
    KeyReleaseMask = 0x00000002,
    StructureNotifyMask = 0x00020000,

    --- @type fun(): XEvent
    newEvent = function() return ffi.new("XEvent") end,

    ---@type fun(...: any): userdata
    newAtomArray = function(...)
        local len = select("#", ...)
        local arr = ffi.new("Atom[?]", len)
        for i = 1, len do
            arr[i - 1] = select(i, ...)
        end

        return arr
    end,
}
