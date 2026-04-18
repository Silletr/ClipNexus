// Learn more about Tauri commands at https://tauri.app/develop/calling-rust/
/*
#[tauri::command]
fn greet(name: &str) -> String {
    format!("Hello, {}! You've been greeted from Rust!", name)
}
*/

#[tauri::command]
fn for_something_else() -> String {
    format!("Something is happenin'")
}

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        .plugin(tauri_plugin_opener::init())
        .invoke_handler(tauri::generate_handler![for_something_else])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
