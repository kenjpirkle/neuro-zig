const Colour = @import("../gl/colour.zig").Colour;

pub const TitleBar = struct {
    pub const MinimizeButton = struct {
        pub const Body = struct {
            pub const Default = Colour.fromRgbaInt(120, 120, 120, 0);
            pub const Hover = Colour.fromRgbaInt(120, 120, 120, 80);
            pub const Pressed = Colour.fromRgbaInt(120, 120, 120, 120);
        };
        pub const Icon = struct {
            pub const Default = Colour.fromRgbaInt(255, 255, 255, 125);
            pub const Hover = Colour.fromRgbaInt(255, 255, 255, 180);
            pub const Pressed = Colour.fromRgbaInt(255, 255, 255, 255);
        };
    };
    pub const MaximizeRestoreButton = struct {
        pub const Body = struct {
            pub const Default = Colour.fromRgbaInt(120, 120, 120, 0);
            pub const Hover = Colour.fromRgbaInt(120, 120, 120, 80);
            pub const Pressed = Colour.fromRgbaInt(120, 120, 120, 120);
        };
        pub const Icon = struct {
            pub const Default = Colour.fromRgbaInt(255, 255, 255, 125);
            pub const Hover = Colour.fromRgbaInt(255, 255, 255, 180);
            pub const Pressed = Colour.fromRgbaInt(255, 255, 255, 255);
        };
    };
    pub const CloseButton = struct {
        pub const Body = struct {
            pub const Default = Colour.fromRgbaInt(200, 30, 30, 0);
            pub const Hover = Colour.fromRgbaInt(200, 30, 30, 80);
            pub const Pressed = Colour.fromRgbaInt(225, 30, 30, 120);
        };
        pub const Icon = struct {
            pub const Default = Colour.fromRgbaInt(255, 255, 255, 125);
            pub const Hover = Colour.fromRgbaInt(255, 255, 255, 180);
            pub const Pressed = Colour.fromRgbaInt(255, 255, 255, 255);
        };
    };
};
