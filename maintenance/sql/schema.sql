BEGIN;

--
-- schema for metadata application
--

-- requires the following users:
--
-- createuser -U postgres -p 5434 -P intranet
-- createuser -U postgres -p 5434 -P web
-- CREATE ROLE web_group;
-- CREATE ROLE intranet_group;
-- GRANT web_group TO web;
-- GRANT web_group TO intranet;
-- GRANT intranet_group TO intranet;
--


DROP VIEW IF EXISTS view_meta;
DROP TABLE IF EXISTS meta;
DROP SEQUENCE IF EXISTS meta_gid_seq;

CREATE TABLE meta (
    gid SERIAL PRIMARY KEY NOT NULL, -- Primärschlüssel (auto-inkrement)
    ptype TEXT,                      -- Projekttyp (z.B. als)
    pname TEXT,                      -- Projektname (z.B. hef)
    cdate TEXT,                      -- Datum der Kampagne (z.B 011011)
    cname TEXT,                      -- Kampagnenname (z.B. hef01)
    fname TEXT,                      -- Name der LAS-Datei
    fsize BIGINT,                    -- Größe der LAS-Datei in Bytes
    points BIGINT,                   -- Zahl der Punkte im LAS File
    srid INTEGER,                    -- EPSG Code der Projektion
    hull geometry(Polygon,0),        -- Geometrie der konkaven Hülle
    traj geometry(Linestring,0),     -- Geometrie der Trajektorie
    info JSON                        -- JSON Objekt mit allen Attributen
);
GRANT SELECT ON meta TO GROUP web_group;
GRANT SELECT, UPDATE ON meta_gid_seq TO GROUP intranet_group;
GRANT SELECT, INSERT, UPDATE, DELETE ON meta TO GROUP intranet_group;

CREATE VIEW view_meta AS (
    SELECT gid,ptype,pname,cname,cdate,fname,fsize,points,info,srid,
    to_date(cdate, 'YYMMDD') AS datum,
    info->>'system_identifier' AS sensor,
    (info->>'point_area')::numeric AS area,
    (info->>'point_density')::numeric AS density,
    ST_Transform(ST_SetSRID(hull,srid),4326) AS hull,
    ST_Transform(ST_SetSRID(traj,srid),4326) AS traj
    FROM meta
    WHERE ptype='als'
);
GRANT SELECT ON view_meta TO GROUP web_group;


COMMIT;

