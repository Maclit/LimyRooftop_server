pub mod user;

pub fn initialize_database() -> Result<(), ()> {
    match user::initialize_user_table() {
        Ok(_) => { println!("User table initialized."); }
        Err(err) => {
            println!("Failed to create user table : {}.", err);
            return Err(());
        }
    }
    Ok(())
}
