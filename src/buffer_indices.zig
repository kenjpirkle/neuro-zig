pub const Background = struct {
    pub var Quad: usize = undefined;
    pub var Colour: u8 = undefined;
    pub var ColourIndices: usize = undefined;
};

pub const TitleBar = struct {
    pub const MainRect = struct {
        pub var Quad: usize = undefined;
        pub var Colour: u8 = undefined;
        pub var ColourIndices: usize = undefined;
    };

    pub const MinimizeButton = struct {
        pub const Body = struct {
            pub var Quad: usize = undefined;
            pub var Colour: u8 = undefined;
            pub var ColourIndices: usize = undefined;
        };
        pub const Icon = struct {
            pub var Quad: usize = undefined;
            pub var Colour: u8 = undefined;
            pub var ColourIndices: usize = undefined;
        };
    };

    pub const MaximizeRestoreButton = struct {
        pub const Body = struct {
            pub var Quad: usize = undefined;
            pub var Colour: u8 = undefined;
            pub var ColourIndices: usize = undefined;
        };
        pub const Icon = struct {
            pub const Top = struct {
                pub var Quad: usize = undefined;
                pub var ColourIndices: usize = undefined;
            };
            pub const Left = struct {
                pub var Quad: usize = undefined;
                pub var ColourIndices: usize = undefined;
            };
            pub const Right = struct {
                pub var Quad: usize = undefined;
                pub var ColourIndices: usize = undefined;
            };
            pub const Bottom = struct {
                pub var Quad: usize = undefined;
                pub var ColourIndices: usize = undefined;
            };
            pub var Colour: u8 = undefined;
        };
    };

    pub const CloseButton = struct {
        pub var Quad: usize = undefined;
        pub var Colour: u8 = undefined;
        pub var ColourIndices: usize = undefined;
    };
};

pub const SearchBar = struct {
    pub const Body = struct {
        pub const MainRect = struct {
            pub var Quad: usize = undefined;
            pub var Colours: [2]u8 = undefined;
            pub var ColourIndices: usize = undefined;
        };
        pub const Shadow = struct {
            pub var Quad: usize = undefined;
            pub var Colours: [2]u8 = undefined;
            pub var ColourIndices: usize = undefined;
        };
        pub const Highlight = struct {
            pub var Quad: usize = undefined;
            pub var Colours: [2]u8 = undefined;
            pub var ColourIndices: usize = undefined;
        };
    };

    pub const FocusHighlight = struct {
        pub const Top = struct {
            pub var Quad: usize = undefined;
            pub var ColourIndices: usize = undefined;
        };
        pub const Bottom = struct {
            pub var Quad: usize = undefined;
            pub var ColourIndices: usize = undefined;
        };
        pub const Left = struct {
            pub var Quad: usize = undefined;
            pub var ColourIndices: usize = undefined;
        };
        pub const Right = struct {
            pub var Quad: usize = undefined;
            pub var ColourIndices: usize = undefined;
        };
        pub var Colour: u8 = undefined;
        pub var DrawCommand: usize = undefined;
    };

    pub const SearchText = struct {
        pub const PlaceholderText = struct {
            pub var Quad: usize = undefined;
            pub var Colour: u8 = undefined;
            pub var ColourIndices: usize = undefined;
        };
        pub const UserText = struct {
            pub var Quad: usize = undefined;
            pub var Colour: u8 = undefined;
            pub var ColourIndices: usize = undefined;
        };
        pub var DrawCommand: usize = undefined;
    };

    pub const TextOverflow = struct {
        pub const Left = struct {
            pub var Quad: usize = undefined;
            pub var ColourIndices: usize = undefined;
        };
        pub const Right = struct {
            pub var Quad: usize = undefined;
            pub var ColourIndices: usize = undefined;
        };
        pub var Colours: [4]u8 = undefined;
        pub var DrawCommand: usize = undefined;
    };

    pub const SelectionRect = struct {
        pub var Quad: usize = undefined;
        pub var Colour: u8 = undefined;
        pub var ColourIndices: usize = undefined;
    };

    pub const TextCursor = struct {
        pub var Quad: usize = undefined;
        pub var Colour: u8 = undefined;
        pub var ColourIndices: usize = undefined;
    };

    pub const SuggestionRects = struct {
        pub var Quad: usize = undefined;
        pub var Colour: u8 = undefined;
        pub var ColourIndices: usize = undefined;
        pub var DrawCommand: usize = undefined;
    };

    pub const SuggestionText = struct {
        pub var Quad: usize = undefined;
        pub var Colour: u8 = undefined;
        pub var ColourIndices: usize = undefined;
        pub var DrawCommand: usize = undefined;
    };
};
