#[cxx_qt::bridge]
pub mod qobject {
    unsafe extern "C++" {
        include!("cxx-qt-lib/qstring.h");
        type QString = cxx_qt_lib::QString;
    }

    unsafe extern "RustQt" {
        #[qobject]
        #[qml_element]
        #[qproperty(QString, pfp_path)]
        #[qproperty(QString, username)]
        #[qproperty(i32, wifi_strength)]
        type UserInfo = super::UserInfoRust;

        #[qinvokable]
        fn refresh(self: Pin<&mut UserInfo>);
    }
}

use core::pin::Pin;
use cxx_qt_lib::QString;
use std::env;
use std::path::PathBuf;

pub struct UserInfoRust {
    pfp_path: QString,
    username: QString,
    wifi_strength: i32,
}

impl Default for UserInfoRust {
    fn default() -> Self {
        Self {
            pfp_path: QString::from(&find_pfp_path()),
            username: QString::from(&env::var("USER").unwrap_or_default()),
            wifi_strength: read_wifi_strength(),
        }
    }
}

impl qobject::UserInfo {
    pub fn refresh(mut self: Pin<&mut Self>) {
        let path = find_pfp_path();
        self.as_mut().set_pfp_path(QString::from(&path));
        let user = env::var("USER").unwrap_or_default();
        self.as_mut().set_username(QString::from(&user));
        self.set_wifi_strength(read_wifi_strength());
    }
}

/// Reads wifi link quality from /proc/net/wireless and maps it to 0–4 bars.
/// Returns 0 if wifi is disconnected or the interface isn't found.
fn read_wifi_strength() -> i32 {
    let content = std::fs::read_to_string("/proc/net/wireless").unwrap_or_default();
    for line in content.lines().skip(2) {
        let parts: Vec<&str> = line.split_whitespace().collect();
        // Format: iface: status link. level. noise. ...
        // parts[0] = "wlan0:", parts[2] = link quality (may have trailing dot)
        if parts.len() >= 3 {
            let quality_str = parts[2].trim_end_matches('.');
            if let Ok(quality) = quality_str.parse::<f64>() {
                // Link quality is typically 0–70 on Linux
                return match quality as i32 {
                    q if q >= 56 => 4,
                    q if q >= 42 => 3,
                    q if q >= 28 => 2,
                    q if q >= 1  => 1,
                    _            => 0,
                };
            }
        }
    }
    0
}

/// Checks the common places a Linux profile picture actually lives, in
/// priority order, and returns a file:// URL QML's Image can load directly.
/// Falls back to the bundled account.svg if the user has no pfp set.
fn find_pfp_path() -> String {
    let user = env::var("USER").unwrap_or_default();
    let home = env::var("HOME").unwrap_or_default();

    let candidates = [
        // AccountsService — what GNOME/Budgie's user switcher actually reads
        format!("/var/lib/AccountsService/icons/{}", user),
        // classic dotfile convention (some DMs/greeters use this)
        format!("{}/.face", home),
        format!("{}/.face.icon", home),
    ];

    for candidate in candidates {
        if PathBuf::from(&candidate).exists() {
            return format!("file://{}", candidate);
        }
    }

    // fallback: your existing bundled icon, unchanged
    "qrc:/assets/icons/account.svg".to_string()
}
