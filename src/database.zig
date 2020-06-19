const std = @import("std");
const ArrayList = std.ArrayList;
usingnamespace @import("print.zig");
usingnamespace @import("c.zig");

pub const Database = struct {
    connection: *sqlite3,

    pub fn init(path: []const u8) !Database {
        var sql_connection: ?*sqlite3 = undefined;

        var result = sqlite3_open_v2(@ptrCast([*:0]const u8, path), &sql_connection, SQLITE_OPEN_READWRITE, null);

        switch (result) {
            SQLITE_OK => {
                return Database{
                    .connection = sql_connection.?,
                };
            },
            else => {
                result = sqlite3_open_v2(@ptrCast([*c]const u8, path), &sql_connection, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE, null);
                var db = Database{
                    .connection = sql_connection.?,
                };
                try createNewSchema(db);

                return db;
            },
        }
    }

    pub fn deinit(self: Database) void {
        _ = sqlite3_close_v2(self.connection);
    }

    fn createNewSchema(self: Database) !void {
        const stmt =
            \\begin transaction;
            \\create table stats(
            \\targ_ret int not null,
            \\avg_ease int not null,
            \\avg_ease_count int not null,
            \\ivl_1 int not null,
            \\ivl_2 int not null,
            \\ivl_3 int not null,
            \\ivl_4 int not null,
            \\ivl_5 int not null,
            \\ivl_1_count int not null,
            \\ivl_2_count int not null,
            \\ivl_3_count int not null,
            \\ivl_4_count int not null,
            \\ivl_5_count int not null,
            \\avg_re_ease int not null,
            \\avg_re_ease_count int not null,
            \\avg_re_ease_soft int not null,
            \\avg_re_ease_soft_count int not null,
            \\new_cards_per_deck int not null
            \\);
            \\insert into stats(
            \\targ_ret, avg_ease, avg_ease_count, ivl_1, ivl_2, ivl_3, ivl_4, ivl_5,
            \\ivl_1_count, ivl_2_count, ivl_3_count, ivl_4_count, ivl_5_count,
            \\avg_re_ease, avg_re_ease_soft, avg_re_ease_count,
            \\avg_re_ease_soft_count, new_cards_per_deck
            \\)
            \\values(9500,2500,1,60000,600000,86400000,
            \\172800000,518400000,1,1,1,1,1,500,750,1,1,50
            \\);
            \\create table rev_log(
            \\id int primary key not null,
            \\card_id int not null,
            \\quality int not null,
            \\ease int not null,
            \\next_rep int not null,
            \\actual_rep int not null,
            \\last_rep int not null,
            \\stage int not null,
            \\time int not null
            \\);
            \\create table decks(
            \\id int primary key not null,
            \\name text not null,
            \\desc text not null,
            \\new_cards_per_day int not null
            \\);
            \\create table tags(
            \\id int primary key not null,
            \\tag text not null
            \\);
            \\create table disambig_tags(
            \\id int primary key not null,
            \\tag_id int not null,
            \\disambig_tag text not null
            \\);
            \\create virtual table tags_fts using fts5(tag, prefix='1 2 3 4 5 6 7 8');
            \\create table item_schemas(
            \\id int primary key not null,
            \\name text not null,
            \\desc text null,
            \\data blob not null
            \\);
            \\create table items(
            \\id int primary key not null,
            \\schema int not null
            \\);
            \\create table content(
            \\id int primary key not null,
            \\item int not null,
            \\field_number int not null,
            \\type int not null,
            \\data text null
            \\);
            \\create index item_content on content(item, field_number);
            \\create table card_schemas(
            \\id int primary key not null,
            \\name text not null,
            \\desc text null,
            \\data blob not null
            \\);
            \\create table card_metadata(
            \\id int primary key not null,
            \\deck int not null,
            \\schema int not null,
            \\item int not null,
            \\ease int not null,
            \\next_rep int not null,
            \\actual_rep int not null,
            \\last_rep int not null,
            \\stage int not null,
            \\reps int not null,
            \\s_reps int not null,
            \\rs_reps int not null,
            \\avg_ease int not null,
            \\recent_avg_ease int not null
            \\);
            \\create index due_cards on card_metadata(next_rep) where stage < 4;
            \\create index due_cards_decks on card_metadata(deck, next_rep) where stage < 4;
            \\create index new_cards on card_metadata(stage) where stage = 4;
            \\create index new_cards_decks on card_metadata(deck) where stage = 4;
            \\end transaction;
        ;

        var error_message: ?[*:0]u8 = undefined;
        const result = sqlite3_exec(self.connection, stmt, null, null, &error_message);
        switch (result) {
            SQLITE_OK => {
                return;
            },
            else => {
                print("sqlite error: ");
                print(result);
                print(": ");
                printLine(error_message);
                return error.SQLiteError;
            },
        }

        return;
    }

    pub fn getTagsLike(self: Database, search_term: []const u8) !ArrayList([]const u8) {
        const source = "select tag from tags_fts where tag match ?*;";
        var stmt: ?sqlite3_stmt = undefined;
        sqlite3_prepare_v2(self.connection, source, source.len + 1, &stmt, SQLITE_TRANSIENT);

        var results = ArrayList([]const u8).init(std.heap.c_allocator);

        var done = false;
        var bytes = 0;
        var text: ?[*:0]const u8 = undefined;

        while (done != true) {
            switch (sqlite3_step(stmt)) {
                SQLITE_DONE => {
                    done = true;
                    break;
                },
                SQLITE_ROW => {
                    bytes = sqlite3_column_bytes(stmt, 0);
                    text = sqlite3_column_text(stmt, 0);
                },
            }
        }
    }
};
