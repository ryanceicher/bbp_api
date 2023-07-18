use rocket::fairing::AdHoc;
use rocket::serde::json::Json;
use rocket_db_pools::{sqlx, Database, Connection};

use crate::dataaccess::user::User;

#[derive(Database)]
#[database("bbp")]
struct Db(sqlx::PgPool);

type Result<T, E = rocket::response::Debug<sqlx::Error>> = std::result::Result<T, E>;

#[get("/leaderboard")]
async fn leaderboard(mut db: Connection<Db>) -> Result<Json<Vec<User>>> {
    let users: Vec<User> = sqlx::query_as::<_, User>("SELECT * FROM public.\"Users\"")
        .fetch_all(&mut *db)
        .await?;

    Ok(Json(users))
}

pub fn stage() -> AdHoc {
    AdHoc::on_ignite("SQLx Stage", |rocket| async {
        rocket.attach(Db::init())
            //.attach(AdHoc::try_on_ignite("SQLx Migrations", run_migrations))
            .mount("/api", routes![leaderboard])
    })
}