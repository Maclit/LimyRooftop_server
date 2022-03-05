use std::process::exit;
use actix_web::{App, HttpServer};

mod database;
mod api;

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    match database::initialize_database() {
        Ok(_) => { println!("Database initialized successfully!"); }
        Err(_) => {
            println!("Failed to initialize database.");
            exit(1);
        }
    };

    match database::user::insert_user(String::from("julien.castillejos@gmail.com"), String::from("Maclit")) {
        Ok(totp_seed) => { println!("{}", totp_seed) }
        Err(err) => { println!("{}", err) }
    };

    match database::user::select_user(String::from("julien.castillejos@gmail.com")) {
        Ok(user) => { println!("{:?}", user) }
        Err(err) => { println!("{}", err) }
    };

    HttpServer::new(|| {
        App::new()
            .service(api::user::register)
            .service(api::user::login)
            .service(api::user::info)
    })
        .bind("127.0.0.1:8080")?
        .run()
        .await
}
