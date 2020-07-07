pub const BackgroundIndices = struct {
    pub const QuadId = 0;
    pub const ColourId = 0;
    pub const ColourIndicesId = 0;
};

pub const TitleBarIndices = struct {
    pub const MainRect = struct {
        pub const QuadId = BackgroundIndices.QuadId + 1;
        pub const ColourId = BackgroundIndices.ColourId + 1;
        pub const ColourIndicesId = BackgroundIndices.ColourIndicesId + 1;
    };

    pub const Minimize = struct {
        pub const QuadId = MainRect.QuadId + 1;
        pub const ColourId = MainRect.ColourId + 1;
        pub const ColourIndicesId = MainRect.ColourIndicesId + 1;
    };

    pub const MinimizeIcon = struct {
        pub const QuadId = Minimize.QuadId + 1;
        pub const ColourId = Minimize.ColourId + 1;
        pub const ColourIndicesId = Minimize.ColourIndicesId + 1;
    };

    pub const MaximizeRestore = struct {
        pub const QuadId = MinimizeIcon.QuadId + 1;
        pub const ColourId = MinimizeIcon.ColourId + 1;
        pub const ColourIndicesId = MinimizeIcon.ColourIndicesId + 1;
    };

    pub const Close = struct {
        pub const QuadId = MaximizeRestore.QuadId + 1;
        pub const ColourId = MaximizeRestore.ColourId + 1;
        pub const ColourIndicesId = MaximizeRestore.ColourIndicesId + 1;
    };
};

pub const SearchBarIndices = struct {
    pub const Body = struct {
        pub const MainRect = struct {
            pub const QuadId = TitleBarIndices.Close.QuadId + 1;
            pub const ColourId = TitleBarIndices.Close.ColourId + 1;
            pub const ColourIndicesId = TitleBarIndices.Close.ColourIndicesId + 1;
        };
        pub const Shadow = struct {
            pub const QuadId = MainRect.QuadId + 1;
            pub const ColourId = MainRect.ColourId + 2;
            pub const ColourIndicesId = MainRect.ColourIndicesId + 1;
        };
        pub const Highlight = struct {
            pub const QuadId = Shadow.QuadId + 1;
            pub const ColourId = Shadow.ColourId + 2;
            pub const ColourIndicesId = Shadow.ColourIndicesId + 1;
        };
    };

    pub const FocusHighlight = struct {
        pub const Top = struct {
            pub const QuadId = Body.Highlight.QuadId + 1;
            pub const ColourIndicesId = Body.Highlight.ColourIndicesId + 1;
        };
        pub const Bottom = struct {
            pub const QuadId = Top.QuadId + 1;
            pub const ColourIndicesId = Top.ColourIndicesId + 1;
        };
        pub const Left = struct {
            pub const QuadId = Bottom.QuadId + 1;
            pub const ColourIndicesId = Bottom.ColourIndicesId + 1;
        };
        pub const Right = struct {
            pub const QuadId = Left.QuadId + 1;
            pub const ColourIndicesId = Left.ColourIndicesId + 1;
        };
        pub const ColourId = Body.Highlight.ColourId + 2;
    };

    pub const SearchText = struct {
        pub const PlaceholderText = struct {
            pub const QuadId = FocusHighlight.Right.QuadId + 1;
            pub const ColourId = FocusHighlight.ColourId + 1;
            pub const ColourIndicesId = FocusHighlight.Right.ColourIndicesId + 1;
        };
        pub const UserText = struct {
            pub const QuadId = PlaceholderText.QuadId + 9;
            pub const ColourId = PlaceholderText.ColourId + 1;
            pub const ColourIndicesId = PlaceholderText.ColourIndicesId + 9;
        };
        pub const DrawCommandId = 1;
    };

    pub const TextOverflow = struct {
        pub const Left = struct {
            pub const QuadId = SearchText.UserText.QuadId + 256;
            pub const ColourIndicesId = SearchText.UserText.ColourIndicesId + 256;
        };
        pub const Right = struct {
            pub const QuadId = Left.QuadId + 1;
            pub const ColourIndicesId = Left.ColourIndicesId + 1;
        };
        pub const ColourId = SearchText.UserText.ColourId + 1;
    };

    pub const SelectionRect = struct {
        pub const QuadId = TextOverflow.Right.QuadId + 1;
        pub const ColourId = TextOverflow.ColourId + 4;
        pub const ColourIndicesId = TextOverflow.Right.ColourIndicesId + 1;
    };

    pub const TextCursor = struct {
        pub const QuadId = SelectionRect.QuadId + 1;
        pub const ColourId = SelectionRect.ColourId + 1;
        pub const ColourIndicesId = SelectionRect.ColourIndicesId + 1;
    };

    pub const SuggestionRects = struct {
        pub const QuadId = TextCursor.QuadId + 1;
        pub const ColourId = TextCursor.ColourId + 1;
        pub const ColourIndicesId = TextCursor.ColourIndicesId + 1;
        pub const DrawCommandId = SearchText.DrawCommandId + 1;
    };

    pub const SuggestionText = struct {
        pub const QuadId = SuggestionRects.QuadId + 10;
        pub const ColourId = SuggestionRects.ColourId + 2;
        pub const ColourIndicesId = SuggestionRects.ColourIndicesId + 10;
        pub const DrawCommandId = SuggestionRects.DrawCommandId + 1;
    };
};
