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


DROP VIEW IF EXISTS view_lidar_meta;
DROP TABLE IF EXISTS lidar_log;
DROP SEQUENCE IF EXISTS lidar_log_id_seq;
DROP TABLE IF EXISTS lidar_meta;
DROP SEQUENCE IF EXISTS lidar_meta_gid_seq;

CREATE TABLE lidar_meta (
    gid SERIAL PRIMARY KEY NOT NULL, -- Primärschlüssel (auto-inkrement)
    ptype TEXT,                      -- Projekttyp (z.B. als)
    pname TEXT,                      -- Projektname (z.B. hef)
    cdate TEXT,                      -- Datum der Befliegung (z.B 011011)
    cname TEXT,                      -- Befliegungskürzel (z.B. hef01)
    fname TEXT,                      -- Name der LAS-Datei
    fsize BIGINT,                    -- Größe der LAS-Datei in Bytes
    points BIGINT,                   -- Zahl der Punkte im LAS File
    srid INTEGER,                    -- EPSG Code der Projektion
    hull geometry(Polygon,0),        -- Geometrie der konkaven Hülle
    traj geometry(Linestring,0),     -- Geometrie der Trajektorie
    info JSON                        -- JSON-Objekt mit allen Attributen
);
GRANT SELECT ON lidar_meta TO GROUP web_group;
GRANT SELECT, UPDATE ON lidar_meta_gid_seq TO GROUP intranet_group;
GRANT SELECT, INSERT, UPDATE, DELETE ON lidar_meta TO GROUP intranet_group;


CREATE TABLE lidar_log (
    id SERIAL PRIMARY KEY NOT NULL,
    user_id TEXT,
    files TEXT[],
    tstamp TIMESTAMP DEFAULT NOW()
);
GRANT SELECT ON lidar_log TO GROUP web_group;
GRANT SELECT, UPDATE ON lidar_log_id_seq TO GROUP intranet_group;
GRANT SELECT, INSERT ON lidar_log TO GROUP intranet_group;


CREATE OR REPLACE VIEW view_lidar_meta AS (
    SELECT gid,ptype,pname,cname,cdate,fname,fsize,points,info,srid,
    to_date(cdate, 'YYMMDD') AS datum,
    info->>'system_identifier' AS sensor,
    (info->>'point_area')::numeric AS area,
    (info->>'point_density')::numeric AS density,
    ST_Transform(ST_SetSRID(hull,srid),4326) AS hull,
    ST_Transform(ST_SetSRID(traj,srid),4326) AS traj
    FROM lidar_meta
    WHERE ptype IN ('als','tls')
);
GRANT SELECT ON view_lidar_meta TO GROUP web_group;


COMMIT;

