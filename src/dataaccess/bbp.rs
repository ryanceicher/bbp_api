use rocket::serde::{Serialize, Deserialize};
use sqlx::postgres::PgRow;
use sqlx::{Row, FromRow};

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(crate = "rocket::serde")]
pub struct Bbp {
    pub bbp_id: i32, 
    pub user_id: Option<i32>,
    pub issuer_id: Option<i32>,
    pub description: Option<String>,
    //pub timestamp: String,
    pub forgiven: Option<bool>
}

impl FromRow<'_, PgRow> for Bbp {
    fn from_row(row: &PgRow) -> sqlx::Result<Self> {
        Ok(Self {
            bbp_id: row.try_get("BbpID")?,
            user_id: row.try_get("UserID")?,
            issuer_id: row.try_get("IssuerID")?,
            description: row.try_get("Description")?,
            //timestamp: row.try_get("Timestamp").to_string(),
            forgiven: row.try_get("Forgiven")?,
        })
    }
}