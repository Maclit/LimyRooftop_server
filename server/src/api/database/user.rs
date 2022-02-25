use rusqlite::{Connection, Result};
use std::time::{SystemTime, UNIX_EPOCH};
use totp_lite::{totp, Sha512};

#[derive(Debug)]
pub struct User {
    pub id: i64,
    pub login: String,
    pub display_name: String,
    pub totp_seed: String,
    pub created_at: String,
    pub last_login: String
}

pub fn initialize_user_table() -> Result<(), rusqlite::Error> {
    let conn = Connection::open("server.db")?;

    match conn.execute(
        "CREATE TABLE IF NOT EXISTS user (
                id INTEGER PRIMARY KEY AUTOINCREMENT  , -- user id
                login TEXT UNIQUE, -- user login
                display_name TEXT, -- display name
                totp_seed TEXT, -- user otp seed if set to null users can't login
                created_at TEXT NOT NULL DEFAULT (datetime('now')), -- account creation date
                last_login TEXT NOT NULL DEFAULT ('')
            );
         )",
        [],
    ) {
        Ok(_) => { Ok(()) }
        Err(err) => { Err(err) }
    }
}

pub fn insert_user(login: String, display_name: String) -> Result<String, rusqlite::Error> {
    let conn = Connection::open("server.db")?;
    let password: &[u8] = login.as_bytes();
    let seconds: u64 = SystemTime::now().duration_since(UNIX_EPOCH).unwrap().as_secs();
    let totp_seed: String = totp::<Sha512>(password, seconds);

    match conn.execute(
        "INSERT INTO user (login, display_name, totp_seed) values (?1, ?2, ?3);",
        &[&login.to_string(), &display_name.to_string(), &totp_seed.to_string()],
    ) {
        Ok(_) => { Ok(totp_seed) }
        Err(err) => { Err(err) }
    }
}

pub fn select_user(login: String) -> Result<User, rusqlite::Error> {
    let conn = Connection::open("server.db")?;

    let mut smt = conn.prepare(
        "SELECT * FROM user"
    )?;
    let mut user_iter = smt.query_map([], |row| {
        Ok(User {
            id: row.get(0)?,
            login: row.get(1)?,
            display_name: row.get(2)?,
            totp_seed: row.get(3)?,
            created_at: row.get(4)?,
            last_login: row.get(5)?,
        })
    })?;
    
    return user_iter.next().unwrap();
}
