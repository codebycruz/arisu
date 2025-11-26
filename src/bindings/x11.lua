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
    typedef unsigned long Time;
    typedef unsigned long Cursor;

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
        Window root;
        Window subwindow;
        Time time;
        int x, y;
        int x_root, y_root;
        unsigned int state;
        char is_hint;
        Bool same_screen;
    } XMotionEvent;

    typedef struct {
        int type;
        unsigned long serial;
        Bool send_event;
        Display *display;
        Window window;
        Window root;
        Window subwindow;
        Time time;
        int x, y;
        int x_root, y_root;
        unsigned int state;
        unsigned int button;
        Bool same_screen;
    } XButtonEvent;

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
        XMotionEvent xmotion;
        XButtonEvent xbutton;
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
    Status XSetWMProtocols(Display* display, Window w, Atom* protocols, int count);
    void XNextEvent(Display* display, XEvent* event_return);
    void XPeekEvent(Display* display, XEvent* event_return);
    int XDefaultScreen(Display* display);
    int XPending(Display* display);
    void XSelectInput(Display* display, Window w, long event_mask);
    Status XGetWindowAttributes(Display* display, Window w, XWindowAttributes* window_attributes_return);
    Cursor XCreateFontCursor(Display* display, unsigned int shape);
    void XDefineCursor(Display* display, Window w, Cursor cursor);
    void XUndefineCursor(Display* display, Window w);
    void XFreeCursor(Display* display, Cursor cursor);
    void XFlush(Display* display);
    void XChangeProperty(Display* display, Window w, Atom property, Atom type, int format, int mode, const unsigned char* data, int nelements);
]]

local C = ffi.load("X11")

---@class XEvent: userdata
---@field type number
---@field xclient { data: { l: number[] }, display: userdata, window: number }
---@field xexpose { window: number }
---@field xany { window: number }
---@field xconfigure { window: number, x: number, y: number, width: number, height: number }
---@field xmotion { x: number, y: number }
---@field xbutton { x: number, y: number, button: number }

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

    ---@type fun(display: XDisplay, event_return: XEvent)
    peekEvent = C.XPeekEvent,

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
    ButtonPress = 4,
    ButtonRelease = 5,
    MotionNotify = 6,
    UnmapNotify = 18,
    MapNotify = 19,
    ConfigureNotify = 22,
    DestroyNotify = 17,
    CreateNotify = 16,

    False = 0,
    True = 1,

    KeyPressMask           = 0x00000001,
    KeyReleaseMask         = 0x00000002,
    ButtonPressMask        = 0x00000004,
    ButtonReleaseMask      = 0x00000008,
    PointerMotionMask      = 0x00000040,
    ExposureMask           = 0x00008000,
    StructureNotifyMask    = 0x00020000,
    SubstructureNotifyMask = 0x00080000,

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

    ---@type fun(display: XDisplay, shape: number): number
    createFontCursor = C.XCreateFontCursor,

    ---@type fun(display: XDisplay, w: number, cursor: number)
    defineCursor = C.XDefineCursor,

    ---@type fun(display: XDisplay, w: number)
    undefineCursor = C.XUndefineCursor,

    ---@type fun(display: XDisplay, cursor: number)
    freeCursor = C.XFreeCursor,

    ---@type fun(display: XDisplay)
    flush = C.XFlush,

    changeProperty = function(display --[[@param display XDisplay]], w --[[@param w number]], property --[[@param property string]], ty --[[@param ty string]], format --[[@param format number]], mode --[[@param mode number]], data --[[@param data userdata]], nelements --[[@param nelements number]])
        local property_atom = C.XInternAtom(display, property, 0)
        local type_atom = C.XInternAtom(display, ty, 0)

        local data_ptr = data
        if type(data) ~= "string" then
            data_ptr = ffi.cast("const unsigned char*", data)
        end

        C.XChangeProperty(display, w, property_atom, type_atom, format, mode, data_ptr, nelements)
    end,

    XC_arrow = 2,
    XC_based_arrow_down = 4,
    XC_based_arrow_up = 6,
    XC_boat = 8,
    XC_bogosity = 10,
    XC_bottom_left_corner = 12,
    XC_bottom_right_corner = 14,
    XC_bottom_side = 16,
    XC_bottom_tee = 18,
    XC_box_spiral = 20,
    XC_center_ptr = 22,
    XC_circle = 24,
    XC_clock = 26,
    XC_coffee_mug = 28,
    XC_cross = 30,
    XC_cross_reverse = 32,
    XC_crosshair = 34,
    XC_diamond_cross = 36,
    XC_dot = 38,
    XC_dotbox = 40,
    XC_double_arrow = 42,
    XC_draft_large = 44,
    XC_draft_small = 46,
    XC_draped_box = 48,
    XC_exchange = 50,
    XC_fleur = 52,
    XC_gobbler = 54,
    XC_gumby = 56,
    XC_hand1 = 58,
    XC_hand2 = 60,
    XC_heart = 62,
    XC_icon = 64,
    XC_iron_cross = 66,
    XC_left_ptr = 68,
    XC_left_side = 70,
    XC_left_tee = 72,
    XC_leftbutton = 74,
    XC_ll_angle = 76,
    XC_lr_angle = 78,
    XC_man = 80,
    XC_middlebutton = 82,
    XC_mouse = 84,
    XC_pencil = 86,
    XC_pirate = 88,
    XC_plus = 90,
    XC_question_arrow = 92,
    XC_right_ptr = 94,
    XC_right_side = 96,
    XC_right_tee = 98,
    XC_rightbutton = 100,
    XC_rtl_logo = 102,
    XC_sailboat = 104,
    XC_sb_down_arrow = 106,
    XC_sb_h_double_arrow = 108,
    XC_sb_left_arrow = 110,
    XC_sb_right_arrow = 112,
    XC_sb_up_arrow = 114,
    XC_sb_v_double_arrow = 116,
    XC_shuttle = 118,
    XC_sizing = 120,
    XC_spider = 122,
    XC_spraycan = 124,
    XC_star = 126,
    XC_target = 128,
    XC_tcross = 130,
    XC_top_left_arrow = 132,
    XC_top_left_corner = 134,
    XC_top_right_corner = 136,
    XC_top_side = 138,
    XC_top_tee = 140,
    XC_trek = 142,
    XC_ul_angle = 144,
    XC_umbrella = 146,
    XC_ur_angle = 148,
    XC_watch = 150,
    XC_xterm = 152,
}
