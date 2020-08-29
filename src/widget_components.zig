const Quad = @import("gl/quad.zig").Quad;
const Rectangle = @import("gl/rectangle.zig").Rectangle;
const ColourReference = @import("gl/colour_reference.zig").ColourReference;
const DrawArraysIndirectCommand = @import("gl/draw_arrays_indirect_command.zig").DrawArraysIndirectCommand;

pub const Background = struct {
    pub var mesh: Rectangle = undefined;
    pub var colour_reference: ColourReference = undefined;
};

pub const TitleBar = struct {
    pub const MainRect = struct {
        pub var mesh: Rectangle = undefined;
        pub var colour_reference: ColourReference = undefined;
    };

    pub const MinimizeButton = struct {
        pub const Body = struct {
            pub var mesh: Rectangle = undefined;
            pub var colour_reference: ColourReference = undefined;
        };
        pub const Icon = struct {
            pub var mesh: Rectangle = undefined;
            pub var colour_reference: ColourReference = undefined;
        };
    };

    pub const MaximizeRestoreButton = struct {
        pub const Body = struct {
            pub var mesh: Rectangle = undefined;
            pub var colour_reference: ColourReference = undefined;
        };
        pub const Icon = struct {
            pub const Top = struct {
                pub var mesh: Rectangle = undefined;
            };
            pub const Left = struct {
                pub var mesh: Rectangle = undefined;
            };
            pub const Right = struct {
                pub var mesh: Rectangle = undefined;
            };
            pub const Bottom = struct {
                pub var mesh: Rectangle = undefined;
            };
            pub var colour_reference: ColourReference = undefined;
        };
    };

    pub const CloseButton = struct {
        pub const Body = struct {
            pub var mesh: Rectangle = undefined;
            pub var colour_reference: ColourReference = undefined;
        };
        pub const Icon = struct {
            pub const Left = struct {
                pub var mesh: Quad = undefined;
            };
            pub const Right = struct {
                pub var mesh: Quad = undefined;
            };
            pub var colour_reference: ColourReference = undefined;
        };
    };
};

pub const SearchBar = struct {
    pub const Body = struct {
        pub const MainRect = struct {
            pub var mesh: Rectangle = undefined;
            pub var colour_references: [2]ColourReference = undefined;
        };
        pub const Shadow = struct {
            pub var mesh: Rectangle = undefined;
            pub var colour_references: [2]ColourReference = undefined;
        };
        pub const Highlight = struct {
            pub var mesh: Rectangle = undefined;
            pub var colour_references: [2]ColourReference = undefined;
        };
    };

    pub const FocusHighlight = struct {
        pub const Top = struct {
            pub var mesh: Rectangle = undefined;
        };
        pub const Left = struct {
            pub var mesh: Rectangle = undefined;
        };
        pub const Right = struct {
            pub var mesh: Rectangle = undefined;
        };
        pub const Bottom = struct {
            pub var mesh: Rectangle = undefined;
        };
        pub var colour_reference: ColourReference = undefined;
        pub var draw_command: *DrawArraysIndirectCommand = undefined;
    };

    pub const SearchText = struct {
        pub const PlaceholderText = struct {
            pub var meshes: [9]Rectangle = undefined;
            pub var colour_reference: ColourReference = undefined;
        };
        pub const UserText = struct {
            pub var meshes: [256]Rectangle = undefined;
            pub var colour_reference: ColourReference = undefined;
        };
        pub var draw_command: *DrawArraysIndirectCommand = undefined;
    };

    pub const TextOverflow = struct {
        pub const Left = struct {
            pub var mesh: Rectangle = undefined;
        };
        pub const Right = struct {
            pub var mesh: Rectangle = undefined;
        };
        pub var colour_references: [4]ColourReference = undefined;
        pub var draw_command: *DrawArraysIndirectCommand = undefined;
    };

    pub const SelectionRect = struct {
        pub var mesh: Rectangle = undefined;
        pub var colour_reference: ColourReference = undefined;
    };

    pub const TextCursor = struct {
        pub var mesh: Rectangle = undefined;
        pub var colour_reference: ColourReference = undefined;
    };

    pub const SuggestionRects = struct {
        pub var mesh: Rectangle = undefined;
        pub var colour_reference: ColourReference = undefined;
        pub var draw_command: *DrawArraysIndirectCommand = undefined;
    };

    pub const SuggestionText = struct {
        pub var mesh: Rectangle = undefined;
        pub var colour_reference: ColourReference = undefined;
        pub var draw_command: *DrawArraysIndirectCommand = undefined;
    };
};
