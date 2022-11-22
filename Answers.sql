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