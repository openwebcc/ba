BEGIN;

--
-- create PostgreSQL schema for FFP application
--

DROP VIEW IF EXISTS view_ffp_tiles;
DROP TABLE IF EXISTS ffp_agreements;
DROP TABLE IF EXISTS ffp_meta;
DROP TABLE IF EXISTS ffp_tiles;

DROP SEQUENCE IF EXISTS ffp_agreements_seq;
DROP SEQUENCE IF EXISTS ffp_meta_seq;

CREATE TABLE ffp_tiles (
    id INTEGER,
    meridian TEXT,
    geom geometry(Polygon)
);
GRANT SELECT ON ffp_tiles TO GROUP web_group;

CREATE SEQUENCE ffp_meta_seq START 1000 INCREMENT 1;
CREATE TABLE ffp_meta (
    id INTEGER PRIMARY KEY NOT NULL DEFAULT NEXTVAL('ffp_meta_seq'),
    ptype TEXT,
    pname TEXT,
    cdate TEXT,
    cname TEXT,
    ctype TEXT,
    fname TEXT,
    ftype TEXT,
    fdate TEXT,
    fsize BIGINT,
    tile INTEGER
);
GRANT SELECT ON ffp_meta TO GROUP web_group;
GRANT INSERT,UPDATE,DELETE ON ffp_meta TO GROUP intranet_group;
GRANT SELECT,UPDATE ON ffp_meta_seq TO GROUP intranet_group;

CREATE SEQUENCE ffp_agreements_seq START 100 INCREMENT 1;
CREATE TABLE ffp_agreements (
    id INTEGER PRIMARY KEY NOT NULL DEFAULT NEXTVAL('ffp_agreements_seq'),
    user_id TEXT,
    person TEXT,
    project TEXT,
    tiles INTEGER,
    mb INTEGER,
    pname TEXT,
    cdate TEXT,
    cname TEXT,
    ctype TEXT,
    ftype TEXT,
    fname TEXT,
    geom_json TEXT,
    tstamp TIMESTAMP DEFAULT NOW()
);
GRANT INSERT ON ffp_agreements TO GROUP intranet_group;

CREATE VIEW view_ffp_tiles AS (
    SELECT m.id,m.ptype,m.pname,m.cdate,m.cname,m.ctype,m.fname,m.ftype,m.fdate,m.fsize,t.id AS tile, t.geom AS geom FROM ffp_meta AS m
    INNER JOIN ffp_tiles AS t ON (t.id=m.tile AND t.meridian=m.pname)
);
GRANT SELECT ON view_ffp_tiles TO GROUP web_group;

COMMIT;
