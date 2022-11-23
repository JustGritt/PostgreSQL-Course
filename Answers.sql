-- ====================
-- Question 1 
-- ====================
CREATE OR REPLACE FUNCTION ADD_ARTIST(NAME VARCHAR(128), BIRTHDATE DATE )
    RETURNS BOOLEAN AS $$
BEGIN
    PERFORM tmp.id FROM
    (
        SELECT artist.id, artist.name AS artistName
        FROM artist
    ) tmp 
    WHERE tmp.artistName = NAME;
    IF FOUND THEN
        RETURN FALSE;
    ELSE
        INSERT INTO ARTIST (name, birthdate) VALUES (NAME, BIRTHDATE);
        RETURN TRUE;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Execute the function
SELECT ADD_ARTIST('The Weeknd', '1990-02-16');
SELECT ADD_ARTIST('Black M', '1984-12-27');
SELECT ADD_ARTIST('Sexion D''Assaut ', '2002-02-02');
SELECT ADD_ARTIST('Black M', '2012-03-09');
SELECT * FROM artist;

-- ====================
-- Question 2
-- ====================
CREATE OR REPLACE FUNCTION ADD_ALBUM(NAME VARCHAR(128))
    RETURNS BOOLEAN AS $$
BEGIN
    PERFORM tmp.id FROM
    ( 
        SELECT album.id, album.name AS albumName
        FROM album
    ) tmp 
    WHERE tmp.albumName = NAME;
    IF FOUND THEN
        RETURN FALSE;
    ELSE
        INSERT INTO album (name) VALUES (NAME);
        RETURN TRUE;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Execute the function
SELECT ADD_ALBUM('Dawn FM');
SELECT ADD_ALBUM('L''Ecole des points vitaux ');
SELECT ADD_ALBUM('Futur ');
SELECT ADD_ALBUM('Subliminal ');
SELECT ADD_ALBUM('Futur ');
SELECT ADD_ALBUM('fuTuR '); -- Same name but different cases
SELECT * from album;

-- ====================
-- Question 3
-- ====================
CREATE OR REPLACE VIEW VIEW_ARTISTS AS
SELECT artist.name AS artist, artist.birthdate, COUNT(song.id) AS songs
FROM artist
INNER JOIN song ON song.artist_id = artist.id
GROUP BY artist.name, artist.birthdate
ORDER BY artist.name ASC; 

-- Execute the view
SELECT * FROM VIEW_ARTISTS; -- You have to add a song to the artist first to see the result

-- ====================
-- Add a song to the database
-- ====================
CREATE OR REPLACE FUNCTION ADD_SONG(NAME VARCHAR(128), DURATION INTEGER, ARTIST_ID INTEGER)
    RETURNS BOOLEAN AS $$
BEGIN
    PERFORM tmp.id FROM
    ( 
        SELECT song.id, song.name AS songName
        FROM song
    ) tmp 
    WHERE tmp.songName = NAME;
    IF FOUND THEN
        RETURN FALSE;
    ELSE
        INSERT INTO song (name, duration, artist_id) VALUES (NAME, DURATION, ARTIST_ID);
        RETURN TRUE;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Execute the function or insert a song directly in the database
SELECT ADD_SONG('Less Than Zero', 199, 1); -- Artist ID 1 is The Weeknd
INSERT INTO song (name, duration, artist_id) VALUES ('Starry Eyes', 137, 1);
SELECT * FROM song;

-- ====================
-- Question 4
-- ====================
CREATE OR REPLACE VIEW VIEW_ALBUMS AS
SELECT album.name AS album, COUNT(song.id) AS songs, SUM(song.duration) AS duration
FROM album
INNER JOIN album_song ON album_song.album_id = album.id
INNER JOIN song ON song.id = album_song.song_id
GROUP BY album.name
ORDER BY album.name ASC;

-- Add a song to an album. (eg. "Billie Jean" to "Thriller")
INSERT INTO album_song (album_id, song_id, track) VALUES (1, 1, 1); -- Album: Dawn FM, Song: Less Than Zero, track 1
INSERT INTO album_song (album_id, song_id, track) VALUES (1, 2, 2); -- Album: Dawn FM, Song: Starry Eyes, track 2
SELECT * FROM VIEW_ALBUMS;

-- ====================
-- Question 5 
-- ====================
CREATE OR REPLACE FUNCTION ADD_STOCK(ALBUM VARCHAR(128), AMOUNT INTEGER)
    RETURNS BOOLEAN AS $$
DECLARE 
	tmpId integer;
	stockValue integer;
BEGIN
    SELECT tmp.id into tmpId FROM
    ( 
        SELECT album.id, album.name AS albumNAme
        FROM album
    ) tmp 
    WHERE tmp.albumNAme = ALBUM;
	IF FOUND THEN
		SELECT stock into stockValue FROM album_stock WHERE album_id = tmpId;
		IF FOUND THEN
			IF stockValue + AMOUNT >= 0 THEN
				UPDATE album_stock SET stock = stockValue + AMOUNT WHERE album_id = tmpId;
				RETURN TRUE;
			ELSE
				RETURN FALSE;
			END IF;
		ELSE
			INSERT INTO album_stock (album_id, stock) VALUES (tmpId, AMOUNT);
		END IF;
		RETURN TRUE;
	ELSE
		RETURN FALSE;
	END IF;
END;
$$ LANGUAGE plpgsql;

-- Execute the function
SELECT ADD_STOCK('Dawn FM', 10);
SELECT ADD_STOCK('L''Ecole des points vitaux ', 5);
SELECT ADD_STOCK('Unknown ', 3); -- Unknown doesn't exist in the database
SELECT ADD_STOCK('Futur ', 1);
SELECT * FROM album_stock;

-- ====================
-- Question 6
-- ====================
CREATE OR REPLACE FUNCTION RENT_ALBUM(CUSTOMER_EMAIL VARCHAR(128), ALBUM VARCHAR(128), BORROW_DATE TIMESTAMP)
    RETURNS BOOLEAN AS $$
DECLARE
    tmpId integer;
    stockValue integer;
	customerId integer;
BEGIN
    SELECT temp.id into tmpId FROM
    ( 
        SELECT album.id, album.name AS aName
        FROM album
    ) temp 
    WHERE temp.aName = ALBUM;
    IF FOUND THEN
        SELECT stock into stockValue FROM album_stock WHERE album_id = tmpId;
		SELECT id INTO customerId FROM customer WHERE email = CUSTOMER_EMAIL;
        IF FOUND THEN
            IF stockValue > 0 THEN
                UPDATE album_stock SET stock = stockValue - 1 WHERE album_id = tmpId;
                INSERT INTO album_rent (album_id, customer_id, borrow_date) VALUES (tmpId, customerId, BORROW_DATE);
                RETURN TRUE;
            ELSE
                RETURN FALSE;
            END IF;
        ELSE
            RETURN FALSE;
        END IF;
    ELSE
        RETURN FALSE;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Execute the function
INSERT INTO customer (email, firstname, lastname) VALUES ('Turtle@myges.fr', 'Smol', 'Turtle');
INSERT INTO customer (email, firstname, lastname) VALUES ('billonr@myges.fr', 'billonr', 'myges');
INSERT INTO customer (email, firstname, lastname) VALUES ('gaillad@myges.fr', 'gaillad', 'myges');
SELECT RENT_ALBUM('Turtle@myges.fr', 'Dawn FM', '2022-01-10');
SELECT RENT_ALBUM('billonr@myges.fr', 'L''Ecole des points vitaux ', '2019-01-05');
SELECT RENT_ALBUM('gaillad@myges.fr', 'Futur ', '2019-01-05');
SELECT RENT_ALBUM('billonr@myges.fr', 'Futur ', '2019-01-05');
SELECT RENT_ALBUM('billonr@myges.fr', 'L''Ecole des points vitaux ', '2019-01-05');

-- ====================
-- Question 7 
-- ====================
CREATE OR REPLACE TRIGGER show_track_deliveries
AFTER UPDATE ON album_stock
FOR EACH ROW
EXECUTE PROCEDURE log_stock();

CREATE OR REPLACE FUNCTION log_stock()
RETURNS TRIGGER AS $$
BEGIN
	INSERT INTO track_deliveries (album_stock_id, amount, delivery_date) 
	VALUES (NEW.album_id, NEW.stock, NOW());
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Execute the trigger
SELECT ADD_STOCK('Billie Jean', 10);

-- ====================
-- Question 8
-- ====================
CREATE OR REPLACE FUNCTION DURATION_TO_STRING(DURATION INT)
RETURNS VARCHAR(16) AS $$
DECLARE
	minutes INT;
	seconds INT;
BEGIN
	IF DURATION < 0 THEN
		RETURN '0:00';
	END IF;

	minutes = DURATION / 60;
	seconds = DURATION % 60;
	RETURN CONCAT(minutes, ':', seconds);
END;
$$ LANGUAGE plpgsql;

-- Execute the function
SELECT DURATION_TO_STRING(120);



