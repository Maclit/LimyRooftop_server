use rusqlite::{Connection, Result};

pub fn initialize_user_table() -> Result<(), rusqlite::Error> {
    let conn = Connection::open("server.db")?;

    match conn.execute(
        "CREATE TABLE IF NOT EXISTS user (
                id TEXT  NOT NULL PRIMARY KEY , -- user id
                login TEXT UNIQUE, -- user login
                display_name TEXT, -- display name
                totp_seed TEXT, -- user otp seed if set to null users can't login
                created_at TEXT NOT NULL DEFAULT (datetime('now')), -- account creation date
                last_login TEXT
            );
         )",
        [],
    ) {
        Ok(_) => { Ok(()) }
        Err(err) => { Err(err) }
    }
}
