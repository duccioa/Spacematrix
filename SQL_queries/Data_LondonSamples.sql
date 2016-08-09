-- DROP SCHEMA support CASCADE;
--CREATE SCHEMA support 
--	AUTHORIZATION postgres;
DROP TABLE support.london_samples CASCADE;

CREATE TABLE support.london_samples (
	sample_id serial NOT NULL,
	area_name character varying (128),
	geom_points geometry
);
ALTER TABLE support.london_samples 
	ADD PRIMARY KEY (sample_id);
CREATE INDEX london_sample_idx 
	ON support.london_samples 
	USING gist 
	(geom_points);
--INSERT INTO support.london_samples  (area_name, geom_points) SELECT 'Lime House',ST_PointFromText('POINT (536748.624339 181817.351152)',27700);
--INSERT INTO support.london_samples  (area_name, geom_points) SELECT 'Holborn',ST_PointFromText('POINT (530514.328 181493.609)',27700);
--INSERT INTO support.london_samples  (area_name, geom_points) SELECT 'Kings Road',ST_PointFromText('POINT (526482.859164 177353.347044)',27700);
--INSERT INTO support.london_samples  (area_name, geom_points) SELECT 'Highgate Hill',ST_PointFromText('POINT (528367.042024 186706.743991)',27700);
--INSERT INTO support.london_samples  (area_name, geom_points) SELECT 'Covent Garden',ST_PointFromText('POINT (530320.590 180874.836)',27700);
--INSERT INTO support.london_samples  (area_name, geom_points) SELECT 'Swiss Cottage',ST_PointFromText('POINT (527214.47065 184273.552023)',27700);
--INSERT INTO support.london_samples  (area_name, geom_points) SELECT 'Royal Albert Hall',ST_PointFromText('POINT (526808.724965 179399.151516)',27700);
--INSERT INTO support.london_samples  (area_name, geom_points) SELECT 'Bank',ST_PointFromText('POINT (532714.622321 181108.558985)',27700);
--INSERT INTO support.london_samples  (area_name, geom_points) SELECT 'Bransbury',ST_PointFromText('POINT (531188.109025 183742.643734)',27700);
--INSERT INTO support.london_samples  (area_name, geom_points) SELECT 'Holloway',ST_PointFromText('POINT (530981.46808 185434.753209)',27700);

INSERT INTO support.london_samples  (area_name, geom_points) SELECT 'Swiss Cottage',ST_PointFromText('POINT (527214.47065 184273.552023)',27700);
INSERT INTO support.london_samples  (area_name, geom_points) SELECT 'Bank',ST_PointFromText('POINT (532989.006 181179.413)',27700);
INSERT INTO support.london_samples  (area_name, geom_points) SELECT 'Emerson Park',ST_PointFromText('POINT (554399.166 187946.556)',27700);
INSERT INTO support.london_samples  (area_name, geom_points) SELECT 'Angel',ST_PointFromText('POINT (531494.586 183280.470)',27700);
INSERT INTO support.london_samples  (area_name, geom_points) SELECT 'East Croydon',ST_PointFromText('POINT (532909.654 165804.205)',27700);

