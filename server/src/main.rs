use std::process::exit;
use actix_web::{App, HttpServer};

mod api;

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    match api::database::initialize_database() {
        Ok(_) => { println!("Database initialized successfully!"); }
        Err(_) => {
            println!("Failed to initialize database.");
            exit(1);
        }
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
