CREATE TABLE itn_merged.roadlink
(
  ogc_fid serial NOT NULL,
  
  fid character varying,
  version integer,
  versiondate character varying(10),
  theme character varying(12),
  changedate character varying[],
  reasonforchange character varying[],
  descriptivegroup character varying(13),
  descriptiveterm character varying(34),
  natureofroad character varying(31),
  length double precision,
  CONSTRAINT roadlink_pkey PRIMARY KEY (ogc_fid)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE itn_merged.roadlink
  OWNER TO postgres;