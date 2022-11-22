CREATE TABLE artist(
	id serial PRIMARY KEY,
	name varchar(128) NOT NULL,
	birthdate date
);

CREATE TABLE song (
	id serial PRIMARY KEY,
	name varchar(128) NOT NULL,
	duration integer  NOT NULL CHECK (duration > 0),
	artist_id integer  NOT NULL,
	constraint fk_artist_id FOREIGN KEY (artist_id) references artist (id)
);

CREATE TABLE album (
	id serial PRIMARY KEY,
	name varchar(128) NOT NULL
);

CREATE TABLE album_song (
	album_id serial references album (id),
	song_id serial references song (id),
	track integer NOT NULL CHECK (track > 0),
	primary key (album_id, song_id)
);


CREATE TABLE album_stock (
	id serial PRIMARY KEY,
	album_id integer  NOT NULL,
	stock integer  NOT NULL CHECK (stock >= 0),
	constraint fk_album_id FOREIGN KEY (album_id) references album (id)
);

CREATE TABLE track_deliveries (
	id serial PRIMARY KEY,
	album_stock_id integer  NOT NULL,
	amount integer  NOT NULL,
	delivery_date date  NOT NULL,
	constraint fk_album_stock_id FOREIGN KEY (album_stock_id) references album_stock (id)
);

CREATE TABLE customer (
	id serial PRIMARY KEY,
	email varchar(128) not null,
	firstname varchar(64) not null,
	lastname  varchar(64) not null
);

CREATE TABLE album_rent(
	album_id serial references album (id),
	customer_id serial references customer (id),
	borrow_date timestamp not null,
	return_date timestamp  null
);