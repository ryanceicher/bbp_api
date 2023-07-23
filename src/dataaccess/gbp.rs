use rocket::serde::{Serialize, Deserialize};
use sqlx::{postgres::PgRow, FromRow, Row};

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(crate = "rocket::serde")]
pub struct Gbp {
    pub bbp_id: i32, 
    pub user_id: i32,
    pub issuer_id: i32,
    pub description: String,
    //pub timestamp: String // maybe chrono?
}

impl FromRow<'_, PgRow> for Gbp {
    fn from_row(row: &PgRow) -> sqlx::Result<Self> {
        Ok(Self {
            bbp_id: row.try_get("BbpID")?,
            user_id: row.try_get("UserID")?,
            issuer_id: row.try_get("IssuerID")?,
            description: row.try_get("Description")?,
            //timestamp: row.try_get("Timestamp")?,
        })
    }
}