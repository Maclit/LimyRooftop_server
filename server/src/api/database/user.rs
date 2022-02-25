use rusqlite::{Connection, Result};
use std::time::{SystemTime, UNIX_EPOCH};
use totp_lite::{totp, Sha512};

#[derive(Debug)]
pub struct User {
    login: String,
    display_name: String,
    totp_seed: String,
    created_at: String,
    last_login: String
}

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

pub fn insert_user(login: String, display_name: String) -> Result<(), rusqlite::Error> {
    let conn = Connection::open("server.db")?;
    let password: &[u8] = login.as_bytes();
    let seconds: u64 = SystemTime::now().duration_since(UNIX_EPOCH).unwrap().as_secs();
    let totp_seed: String = totp::<Sha512>(password, seconds);

    match conn.execute(
        "INSERT INTO user () values ();",
        [],
    ) {
        Ok(_) => { Ok(()) }
        Err(err) => { Err(err) }
    }
}
