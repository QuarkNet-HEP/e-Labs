-- SQL Schema for CVS Graph 
-- Driver: PostgreSQL 7.*

DROP SEQUENCE jobs_id_seq CASCADE;

DROP TABLE jobs CASCADE;

CREATE SEQUENCE jobs_id_seq MINVALUE 0 MAXVALUE 9223372036854775807 INCREMENT 1;

CREATE TABLE jobs (
        id              BIGINT DEFAULT NEXTVAL('jobs_id_seq') PRIMARY KEY,
        rg_id           INTEGER NOT NULL,
        job_dir         VARCHAR(255) NOT NULL,
        job_type        VARCHAR(255) NOT NULL,
        num_jobs        INTEGER,
        run_location    VARCHAR(255),
        jobs_completed  INTEGER,
        curr_status     VARCHAR(255),
        submit_time     TIMESTAMP WITH TIME ZONE DEFAULT 'now'::timestamp,
        finish_time     TIMESTAMP WITH TIME ZONE,

        CONSTRAINT fk_jobs FOREIGN KEY(rg_id) REFERENCES research_group(id) ON DELETE CASCADE
);
