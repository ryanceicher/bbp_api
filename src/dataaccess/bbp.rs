use rocket::serde::{Serialize, Deserialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(crate = "rocket::serde")]
pub struct Bbp {
    pub bbp_id: i32, 
    pub user_id: i32,
    pub issuer_id: i32,
    pub description: String,
    pub timestamp: String,
    pub forgiven: bool
}