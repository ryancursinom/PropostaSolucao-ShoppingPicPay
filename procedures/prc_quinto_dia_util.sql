CREATE OR REPLACE PROCEDURE prc_quinto_dia_util()
LANGUAGE plpgsql AS $$
DECLARE
    v_dia_util INT := 0;
    v_data     DATE;
BEGIN
    FOR v_data IN
        SELECT generate_series(
            date_trunc('month', CURRENT_DATE)::DATE,
            CURRENT_DATE,
            '1 day'::INTERVAL
        )::DATE
    LOOP
        IF EXTRACT(DOW FROM v_data) BETWEEN 1 AND 5 THEN
            v_dia_util := v_dia_util + 1;
        END IF;
    END LOOP;

    IF v_dia_util = 5 THEN
        CALL prc_recarga_va;
    END IF;
END;
$$;