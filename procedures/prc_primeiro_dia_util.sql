CREATE OR REPLACE PROCEDURE prc_primeiro_dia_util()
LANGUAGE plpgsql AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM generate_series(
            date_trunc('month', CURRENT_DATE)::DATE,
            CURRENT_DATE - 1,
            '1 day'::INTERVAL
        ) AS d
        WHERE EXTRACT(DOW FROM d) BETWEEN 1 AND 5
    ) THEN
        CALL prc_recarga_vt();
    END IF;
END;
$$;