use actix_web::{post, get, HttpResponse };

#[post("/api/users/v1/register")]
pub async fn register() -> HttpResponse {
    HttpResponse::Ok().body("OK")
}

#[post("/api/users/v1/login")]
pub async fn login() -> HttpResponse {
    HttpResponse::Ok().body("OK")
}

#[get("/api/users/v1/me")]
pub async fn info() -> HttpResponse {
    HttpResponse::Ok().body("OK")
}
