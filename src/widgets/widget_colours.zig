const Colour = @import("../gl/colour.zig").Colour;

pub const Window = struct {
    pub const Default = Colour.fromRgbaInt(40, 44, 52, 255);
};

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

pub const SearchBar = struct {
    pub const MainRect = struct {
        pub const Top = struct {
            pub const Default = Colour.fromRgbaInt(47, 48, 59, 255);
            pub const Hover = Colour.fromRgbaInt(53, 54, 65, 255);
            pub const Focused = Colour.fromRgbaInt(53, 54, 65, 255);
            pub const FocusedHover = Colour.fromRgbaInt(59, 60, 71, 255);
        };
        pub const Bottom = struct {
            pub const Default = Colour.fromRgbaInt(52, 53, 64, 255);
        };
    };
    pub const Shadow = struct {
        pub const Top = struct {
            pub const Default = Colour.fromRgbaInt(25, 25, 25, 250);
        };
        pub const Bottom = struct {
            pub const Default = Colour.fromRgbaInt(25, 25, 25, 0);
        };
    };
    pub const Highlight = struct {
        pub const Top = struct {
            pub const Default = Colour.fromRgbaInt(255, 255, 255, 0);
        };
        pub const Bottom = struct {
            pub const Default = Colour.fromRgbaInt(255, 255, 255, 51);
        };
    };
    pub const FocusHighlight = struct {
        pub const Default = Colour.fromRgbaInt(50, 25, 255, 0);
    };
    pub const PlaceholderText = struct {
        pub const Default = Colour.fromRgbaInt(217, 217, 255, 120);
    };
    pub const UserText = struct {
        pub const Default = Colour.fromRgbaInt(255, 255, 255, 80);
    };
    pub const TextOverflow = struct {
        pub const Left = struct {
            pub const Top = Colour.fromRgbaInt(47, 48, 59, 0);
            pub const Bottom = Colour.fromRgbaInt(52, 53, 64, 0);
        };
        pub const Right = struct {
            pub const Top = Colour.fromRgbaInt(47, 48, 59, 0);
            pub const Bottom = Colour.fromRgbaInt(52, 53, 64, 0);
        };
    };
    pub const TextCursor = struct {
        pub const Default = Colour.fromRgbaInt(50, 25, 255, 0);
    };
    pub const SelectionRect = struct {
        pub const Default = Colour.fromRgbaInt(50, 50, 255, 0);
    };
};
