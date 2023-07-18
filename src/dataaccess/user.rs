use num_traits::ToPrimitive;
use rocket::serde::{Serialize, Deserialize};
use sqlx::postgres::PgRow;
use sqlx::{Row, FromRow};
use sqlx::types::BigDecimal;

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(crate = "rocket::serde")]
pub struct User {
    pub user_id: i32,
    #[serde(skip_deserializing, skip_serializing_if = "Option::is_none")]
    pub discord_username: Option<String>,
    pub discord_id: i64,
    #[serde(skip_deserializing, skip_serializing_if = "Option::is_none")]
    pub friendly_name: Option<String>,
    pub points: Option<i32>,
    pub bbps_issued: Option<i32>,
    pub gbps_issued: Option<i32>,
    #[serde(skip_deserializing, skip_serializing_if = "Option::is_none")]
    pub rank: Option<i64>
}

impl FromRow<'_, PgRow> for User {
    fn from_row(row: &PgRow) -> sqlx::Result<Self> {
        Ok(Self {
            user_id: row.try_get("UserID")?,
            discord_username: row.try_get("DiscordUsername")?,
            discord_id: row.try_get::<BigDecimal, _>("DiscordID")?.to_f64().unwrap_or(0.0) as i64, 
            friendly_name: row.try_get("FriendlyName")?,
            points: row.try_get("Points")?,
            bbps_issued: row.try_get("BbpsIssued")?,
            gbps_issued: row.try_get("GbpsIssued")?,
            rank: None
        })
    }
}