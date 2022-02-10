mod api;
mod repository;
mod database;
mod services;


use actix_web::{App, HttpServer};
use api::user::{info, login, register};

#[actix_web::main]
async fn main() -> std::io::Result<()> {
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
