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

SELECT ADD_ARTIST('The Weeknd', '1990-02-16');