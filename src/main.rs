use rocket::response::Redirect;

mod dataaccess;

#[macro_use] extern crate rocket;

type Result<T, E = rocket::response::Debug<sqlx::Error>> = std::result::Result<T, E>;

#[get("/")]
fn index() -> Redirect {
    Redirect::to(uri!("/api", dataaccess::postgres::leaderboard()))
}

#[rocket::main]
async fn main() -> Result<(), rocket::Error> {
    let _rocket = rocket::build()
        .mount("/", routes![index])
        .attach(dataaccess::postgres::stage())
        .launch()
        .await?;

    Ok(())
}