CREATE DATABASE IF NOT EXISTS wifi_status;

USE wifi_status;

CREATE TABLE IF NOT EXISTS status (
    id INT AUTO_INCREMENT PRIMARY KEY,
    signal_level INT,
    link_quality INT,
    seconds_epoch INT,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);