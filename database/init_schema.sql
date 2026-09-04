-- ============================================================
-- CineSphere - Movie Theater Booking Database
-- ============================================================
-- DBMS      : MySQL
-- Project   : DBMS Mini Project
-- ============================================================

-- Create the CineSphere database
CREATE DATABASE IF NOT EXISTS cinesphere;

-- Select the CineSphere database
USE cinesphere;


-- ============================================================
-- TABLE: CUSTOMER
-- ============================================================

CREATE TABLE IF NOT EXISTS customer (
    customer_id INT AUTO_INCREMENT,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL,
    phone VARCHAR(15),
    password_hash VARCHAR(255) NOT NULL,
    registered_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_customer
        PRIMARY KEY (customer_id),

    CONSTRAINT uq_customer_email
        UNIQUE (email),

    CONSTRAINT uq_customer_phone
        UNIQUE (phone)
);


-- ============================================================
-- TABLE: MOVIE
-- ============================================================

CREATE TABLE movie (
    movie_id INT AUTO_INCREMENT,
    title VARCHAR(200) NOT NULL,
    duration_minutes INT NOT NULL,
    language VARCHAR(50) NOT NULL,
    release_date DATE,
    certificate VARCHAR(10),
    rating DECIMAL(3,1),
    synopsis TEXT,

    CONSTRAINT pk_movie
        PRIMARY KEY (movie_id),

    CONSTRAINT chk_movie_duration
        CHECK (duration_minutes > 0),

    CONSTRAINT chk_movie_rating
        CHECK (rating >= 0 AND rating <= 10)
);


-- ============================================================
-- TABLE: GENRE
-- ============================================================

CREATE TABLE genre (
    genre_id INT AUTO_INCREMENT,
    genre_name VARCHAR(50) NOT NULL,

    CONSTRAINT pk_genre
        PRIMARY KEY (genre_id),

    CONSTRAINT uq_genre_name
        UNIQUE (genre_name)
);


-- ============================================================
-- TABLE: THEATER
-- ============================================================

CREATE TABLE theater (
    theater_id INT AUTO_INCREMENT,
    theater_name VARCHAR(150) NOT NULL,
    city VARCHAR(100) NOT NULL,
    address VARCHAR(255) NOT NULL,
    contact_no VARCHAR(15),

    CONSTRAINT pk_theater
        PRIMARY KEY (theater_id)
);


-- ============================================================
-- TABLE: SLOT
-- ============================================================

CREATE TABLE slot (
    slot_id INT AUTO_INCREMENT,
    slot_name VARCHAR(100) NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,

    CONSTRAINT pk_slot
        PRIMARY KEY (slot_id),

    CONSTRAINT uq_slot_name
        UNIQUE (slot_name),

    CONSTRAINT chk_slot_time
        CHECK (end_time > start_time)
);


-- ============================================================
-- TABLE: SCREEN
-- ============================================================

CREATE TABLE screen (
    screen_id INT AUTO_INCREMENT,
    theater_id INT NOT NULL,
    screen_name VARCHAR(100) NOT NULL,
    screen_type VARCHAR(50) NOT NULL,
    capacity INT NOT NULL,

    CONSTRAINT pk_screen
        PRIMARY KEY (screen_id),

    CONSTRAINT fk_screen_theater
        FOREIGN KEY (theater_id)
        REFERENCES theater(theater_id),

    CONSTRAINT uq_screen_theater_name
        UNIQUE (theater_id, screen_name),

    CONSTRAINT chk_screen_capacity
        CHECK (capacity > 0)
);

-- ============================================================
-- TABLE: SEAT
-- ============================================================

CREATE TABLE seat (
    seat_id INT AUTO_INCREMENT,
    screen_id INT NOT NULL,
    row_label VARCHAR(5) NOT NULL,
    seat_number INT NOT NULL,
    seat_type VARCHAR(30) DEFAULT 'REGULAR',

    CONSTRAINT pk_seat
        PRIMARY KEY (seat_id),

    CONSTRAINT fk_seat_screen
        FOREIGN KEY (screen_id)
        REFERENCES screen(screen_id),

    CONSTRAINT uq_seat_position
        UNIQUE (screen_id, row_label, seat_number),

    CONSTRAINT chk_seat_number
        CHECK (seat_number > 0)
);