use std::env;

use tracing_subscriber::{
    filter::LevelFilter, prelude::__tracing_subscriber_SubscriberExt, util::SubscriberInitExt,
};

mod prisma;

#[tokio::main]
async fn main() {
    println!("App starting");

    tracing_subscriber::registry()
        .with(LevelFilter::TRACE)
        .with(tracing_subscriber::fmt::layer())
        .init();

    println!("App creating connection");

    let client = prisma::new_client_with_url(
        &env::var("DATABASE_URL").expect("`DATABASE_URL` not provided"),
    )
    .await
    .expect("Error creating DB client");

    client.post().delete_many(vec![]).exec().await.unwrap();
    client
        .post()
        .create("My Post".into(), "Hello World".into(), vec![])
        .exec()
        .await
        .unwrap();

    println!("App finished successfully");
}
