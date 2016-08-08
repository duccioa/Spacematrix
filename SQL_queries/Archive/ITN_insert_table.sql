
SELECT AddGeometryColumn('itn_merged','roadlink','wkb_geometry',27700,'LineString',2);
INSERT INTO itn_merged.roadlink (wkb_geometry, 
			fid, version, versiondate, theme, 
			changedate, reasonforchange, descriptivegroup, 
			descriptiveterm, natureofroad, length
			) 
			SELECT wkb_geometry, 
			fid, version, versiondate, theme, 
			changedate, reasonforchange, descriptivegroup, 
			descriptiveterm, natureofroad, length 
			FROM itn1.roadlink;
INSERT INTO itn_merged.roadlink (wkb_geometry, 
			fid, version, versiondate, theme, 
			changedate, reasonforchange, descriptivegroup, 
			descriptiveterm, natureofroad, length
			) 
			SELECT wkb_geometry, 
			fid, version, versiondate, theme, 
			changedate, reasonforchange, descriptivegroup, 
			descriptiveterm, natureofroad, length 
			FROM itn2.roadlink;

SELECT count(*)+1 AS exact_count FROM itn_merged.roadlink;
CREATE SEQUENCE ogc_fid START (SELECT count(ogc_fid)+1 FROM itn_merged.roadlink);
SELECT * FROM ogc_fid;
SELECT nextval('ogc_fid');
UPDATE itn_merged.roadlink SET ogc_fid = ogc_fid;