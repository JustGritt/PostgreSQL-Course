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