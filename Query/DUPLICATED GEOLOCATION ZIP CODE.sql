-- check duplicated 
SELECT geolocation_zip_code_prefix, COUNT(*)
FROM geolocation
GROUP BY geolocation_zip_code_prefix
HAVING COUNT(*) > 1;

-- remove duplicated
DELETE FROM geolocation
WHERE ctid NOT IN (
    SELECT MIN(ctid)
    FROM geolocation
    GROUP BY geolocation_zip_code_prefix
);

-- add pkey
ALTER TABLE public.geolocation
	ADD PRIMARY KEY (geolocation_zip_code_prefix);

-- add unique constraint
ALTER TABLE IF EXISTS public.geolocation
	ADD CONSTRAINT ukey_geolocation UNIQUE (geolocation_zip_code_prefix);
