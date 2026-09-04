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

-- ============================================================
-- TABLE: MOVIE_GENRE
-- Purpose: Resolves the M:N relationship between MOVIE and GENRE
-- ============================================================

CREATE TABLE movie_genre (
    movie_id INT NOT NULL,
    genre_id INT NOT NULL,

    CONSTRAINT pk_movie_genre
        PRIMARY KEY (movie_id, genre_id),

    CONSTRAINT fk_movie_genre_movie
        FOREIGN KEY (movie_id)
        REFERENCES movie(movie_id),

    CONSTRAINT fk_movie_genre_genre
        FOREIGN KEY (genre_id)
        REFERENCES genre(genre_id)
);

-- ============================================================
-- TABLE: SCREENING
-- Purpose: Represents a movie shown on a screen at a given
--          date and time slot
-- ============================================================

CREATE TABLE screening (
    screening_id INT AUTO_INCREMENT,
    movie_id INT NOT NULL,
    screen_id INT NOT NULL,
    slot_id INT NOT NULL,
    screening_date DATE NOT NULL,
    base_price DECIMAL(10,2) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'SCHEDULED',

    CONSTRAINT pk_screening
        PRIMARY KEY (screening_id),

    CONSTRAINT fk_screening_movie
        FOREIGN KEY (movie_id)
        REFERENCES movie(movie_id),

    CONSTRAINT fk_screening_screen
        FOREIGN KEY (screen_id)
        REFERENCES screen(screen_id),

    CONSTRAINT fk_screening_slot
        FOREIGN KEY (slot_id)
        REFERENCES slot(slot_id),

    CONSTRAINT uq_screening_schedule
        UNIQUE (screen_id, screening_date, slot_id),

    CONSTRAINT chk_screening_price
        CHECK (base_price >= 0),

    CONSTRAINT chk_screening_status
        CHECK (
            status IN ('SCHEDULED', 'CANCELLED', 'COMPLETED')
        )
);

-- ============================================================
-- TABLE: BOOKING
-- Purpose: Records a customer's reservation for one screening
-- ============================================================

CREATE TABLE booking (
    booking_id INT AUTO_INCREMENT,
    customer_id INT NOT NULL,
    screening_id INT NOT NULL,
    booking_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    booking_status VARCHAR(20) NOT NULL DEFAULT 'PENDING',

    CONSTRAINT pk_booking
        PRIMARY KEY (booking_id),

    CONSTRAINT fk_booking_customer
        FOREIGN KEY (customer_id)
        REFERENCES customer(customer_id),

    CONSTRAINT fk_booking_screening
        FOREIGN KEY (screening_id)
        REFERENCES screening(screening_id),

    CONSTRAINT chk_booking_amount
        CHECK (total_amount >= 0),

    CONSTRAINT chk_booking_status
        CHECK (
            booking_status IN (
                'PENDING',
                'CONFIRMED',
                'CANCELLED'
            )
        )
);

-- ============================================================
-- TABLE: BOOKING_SEAT
-- Purpose: Associates one or more seats with a booking
-- ============================================================

CREATE TABLE booking_seat (
    booking_seat_id INT AUTO_INCREMENT,
    booking_id INT NOT NULL,
    seat_id INT NOT NULL,
    ticket_price DECIMAL(10,2) NOT NULL,
    seat_status VARCHAR(20) NOT NULL DEFAULT 'BOOKED',

    CONSTRAINT pk_booking_seat
        PRIMARY KEY (booking_seat_id),

    CONSTRAINT fk_booking_seat_booking
        FOREIGN KEY (booking_id)
        REFERENCES booking(booking_id),

    CONSTRAINT fk_booking_seat_seat
        FOREIGN KEY (seat_id)
        REFERENCES seat(seat_id),

    CONSTRAINT uq_booking_seat
        UNIQUE (booking_id, seat_id),

    CONSTRAINT chk_booking_seat_price
        CHECK (ticket_price >= 0),

    CONSTRAINT chk_booking_seat_status
        CHECK (
            seat_status IN ('BOOKED', 'CANCELLED')
        )
);

-- ============================================================
-- TABLE: TICKET
-- Purpose: Ticket generated for each booked seat
-- ============================================================

CREATE TABLE ticket (
    ticket_id INT AUTO_INCREMENT,
    booking_seat_id INT NOT NULL,
    issued_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    qr_code VARCHAR(255),
    ticket_status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',

    CONSTRAINT pk_ticket
        PRIMARY KEY (ticket_id),

    CONSTRAINT fk_ticket_booking_seat
        FOREIGN KEY (booking_seat_id)
        REFERENCES booking_seat(booking_seat_id),

    CONSTRAINT uq_ticket_booking_seat
        UNIQUE (booking_seat_id),

    CONSTRAINT uq_ticket_qr_code
        UNIQUE (qr_code),

    CONSTRAINT chk_ticket_status
        CHECK (
            ticket_status IN ('ACTIVE', 'USED', 'CANCELLED')
        )
);

-- ============================================================
-- TABLE: PAYMENT
-- Purpose: Records payment attempts for a booking
-- ============================================================

CREATE TABLE payment (
    payment_id INT AUTO_INCREMENT,
    booking_id INT NOT NULL,
    payment_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    amount DECIMAL(10,2) NOT NULL,
    payment_method VARCHAR(30) NOT NULL,
    payment_status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    transaction_reference VARCHAR(100),

    CONSTRAINT pk_payment
        PRIMARY KEY (payment_id),

    CONSTRAINT fk_payment_booking
        FOREIGN KEY (booking_id)
        REFERENCES booking(booking_id),

    CONSTRAINT uq_payment_transaction
        UNIQUE (transaction_reference),

    CONSTRAINT chk_payment_amount
        CHECK (amount > 0),

    CONSTRAINT chk_payment_method
        CHECK (
            payment_method IN (
                'CARD',
                'UPI',
                'NET_BANKING',
                'WALLET',
                'CASH'
            )
        ),

    CONSTRAINT chk_payment_status
        CHECK (
            payment_status IN (
                'PENDING',
                'SUCCESS',
                'FAILED',
                'REFUNDED'
            )
        )
);

