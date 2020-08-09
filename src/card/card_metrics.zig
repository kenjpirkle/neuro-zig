const Card = @import("card.zig").Card;

pub const CardMetrics = packed struct {
    card: *Card,
    next_rep: u64,
    actual_rep: u64,
    last_rep: u64,
    ease: u32,
    average_ease: u32,
    recent_average_ease: u32,
    stage: u8,
    reps: u8,
    successful_reps: u8,
    recent_successful_reps: u8,
};
