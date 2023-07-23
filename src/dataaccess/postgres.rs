use rocket::fairing::AdHoc;
use rocket::serde::json::Json;
use rocket_db_pools::{sqlx, Database, Connection};
use sqlx::types::BigDecimal;

use crate::dataaccess::{user::User, bbp::Bbp};

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

//todo is this right?
#[get("/bbp/<userid>")]
async fn get_bbps(mut db: Connection<Db>, userid: i32) -> Result<Json<Vec<Bbp>>> {
    //todo: parameterize
    let bbps = sqlx::query_as!(Bbp, r#"
            SELECT 
                "BbpID" as bbp_id,
                b."UserID" as user_id,
                "Description" as description,
                "IssuerID" as issuer_id,
                "Forgiven" as forgiven
            FROM public."Bbps" AS b
            INNER JOIN public."Users" AS u ON u."UserID" = b."UserID"
            WHERE u."DiscordID" = $1
            "#, Into::<BigDecimal>::into(userid).into())
        // look int query_as_with and how to pass in parameters
        .fetch_all(&mut *db)
        .await?;

    Ok(Json(bbps))
}

pub fn stage() -> AdHoc {
    AdHoc::on_ignite("SQLx Stage", |rocket| async {
        rocket.attach(Db::init())
        //.attach(AdHoc::try_on_ignite("SQLx Migrations", run_migrations))
        .mount("/api", routes![leaderboard,get_bbps])
    })
}

 