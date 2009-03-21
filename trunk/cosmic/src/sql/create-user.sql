-- userdb schema

-- Type this: psql -d userdb -f create-user.sql 

-- database user 'rspete' had special privileges in the database from
-- which I extracted that schema. those privilege lines are
-- commented out in this file, but left for future reference

CREATE TABLE project (
    id integer NOT NULL,
    name character varying(50)
);


CREATE TABLE state (
    id integer DEFAULT nextval('state_id_seq'::text) NOT NULL,
    name character varying(100),
    abbreviation character(2)
);


CREATE TABLE city (
    id integer DEFAULT nextval('city_id_seq'::text) NOT NULL,
    name character varying(100),
    state_id integer
);


CREATE SEQUENCE state_id_seq
    START 1
    INCREMENT 1
    MAXVALUE 9223372036854775807
    MINVALUE 1
    CACHE 1;


CREATE SEQUENCE city_id_seq
    START 1
    INCREMENT 1
    MAXVALUE 9223372036854775807
    MINVALUE 1
    CACHE 1;


CREATE SEQUENCE school_id_seq
    START 1
    INCREMENT 1
    MAXVALUE 9223372036854775807
    MINVALUE 1
    CACHE 1;


CREATE TABLE school (
    id integer DEFAULT nextval('school_id_seq'::text) NOT NULL,
    name character varying(100) NOT NULL,
    city_id integer
);


CREATE SEQUENCE teacher_id_seq
    START 1
    INCREMENT 1
    MAXVALUE 9223372036854775807
    MINVALUE 1
    CACHE 1;


CREATE TABLE teacher (
    id integer DEFAULT nextval('teacher_id_seq'::text) NOT NULL,
    name character varying(100) NOT NULL,
    email character varying(150),
    school_id integer
);


CREATE SEQUENCE research_group_id_seq
    START 1
    INCREMENT 1
    MAXVALUE 9223372036854775807
    MINVALUE 1
    CACHE 1;


CREATE TABLE research_group (
    id integer DEFAULT nextval('research_group_id_seq'::text) NOT NULL,
    name character varying(100) NOT NULL,
    "password" character varying(100) NOT NULL,
    teacher_id integer,
    role character varying(50),
    userarea text,
    ay character(6),
    survey boolean,
    first_time boolean DEFAULT true
);


-- REVOKE ALL ON TABLE research_group FROM PUBLIC;
-- GRANT ALL ON TABLE research_group TO rspete;


CREATE SEQUENCE student_id_seq
    START 1
    INCREMENT 1
    MAXVALUE 9223372036854775807
    MINVALUE 1
    CACHE 1;


CREATE TABLE student (
    id integer DEFAULT nextval('student_id_seq'::text) NOT NULL,
    name character varying(100) NOT NULL
);


CREATE TABLE research_group_project (
    research_group_id integer,
    project_id integer
);


CREATE TABLE research_group_student (
    research_group_id integer,
    student_id integer
);


CREATE TABLE survey (
    student_id integer,
    project_id integer,
    presurvey boolean DEFAULT false,
    postsurvey boolean DEFAULT false
);


CREATE TABLE research_group_detectorid (
    research_group_id integer,
    detectorid smallint
);


-- REVOKE ALL ON TABLE research_group_detectorid FROM PUBLIC;
-- GRANT ALL ON TABLE research_group_detectorid TO rspete;


CREATE TABLE research_group_favorite (
    research_group_id integer,
    favorite smallint
);


CREATE SEQUENCE keyword_id_seq
    START 1
    INCREMENT 1
    MAXVALUE 9223372036854775807
    MINVALUE 1
    CACHE 1;


CREATE TABLE keyword (
    id integer DEFAULT nextval('keyword_id_seq'::text) NOT NULL,
    keyword character varying(50) NOT NULL,
    description character varying(50) NOT NULL,
    project_id integer,
    section character(1),
    section_id integer,
    "type" character(2)
);


CREATE SEQUENCE log_id_seq
    START 1
    INCREMENT 1
    MAXVALUE 9223372036854775807
    MINVALUE 1
    CACHE 1;


CREATE SEQUENCE comment_id_seq
    START 1
    INCREMENT 1
    MAXVALUE 9223372036854775807
    MINVALUE 1
    CACHE 1;


CREATE TABLE test (
    id integer,
    date_entered timestamp without time zone DEFAULT 'now'
);


CREATE TABLE log (
    id integer DEFAULT nextval('log_id_seq'::text) NOT NULL,
    project_id integer,
    research_group_id integer NOT NULL,
    keyword_id integer,
    role character varying(50) NOT NULL,
    ref_rg_id integer,
    date_entered timestamp without time zone DEFAULT 'now',
    log_text text,
    new_log boolean
);


CREATE TABLE "comment" (
    id integer DEFAULT nextval('comment_id_seq'::text) NOT NULL,
    log_id integer NOT NULL,
    date_entered timestamp without time zone DEFAULT 'now',
    "comment" text NOT NULL,
    new_comment boolean
);


CREATE SEQUENCE keyword1_id_seq
    START 1
    INCREMENT 1
    MAXVALUE 9223372036854775807
    MINVALUE 1
    CACHE 1;


CREATE TABLE keyword1 (
    id integer DEFAULT nextval('keyword1_id_seq'::text) NOT NULL,
    keyword character varying(50) NOT NULL,
    description character varying(50) NOT NULL,
    project_id integer,
    section character(1),
    section_id integer
);


CREATE SEQUENCE usage_id_seq
    START 0
    INCREMENT 1
    MAXVALUE 9223372036854775807
    MINVALUE 0
    CACHE 1;


CREATE TABLE "usage" (
    id integer DEFAULT nextval('usage_id_seq'::text) NOT NULL,
    research_group_id integer NOT NULL,
    date_entered timestamp without time zone DEFAULT now()
);


CREATE SEQUENCE question_id_seq
    START 1
    INCREMENT 1
    MAXVALUE 9223372036854775807
    MINVALUE 1
    CACHE 1;


CREATE TABLE question (
    id integer DEFAULT nextval('question_id_seq'::text) NOT NULL,
    project_id integer,
    test_name character varying(50),
    question_no integer,
    question text,
    answer character(1) NOT NULL,
    response1 text NOT NULL,
    response2 text NOT NULL,
    response3 text,
    response4 text,
    response5 text
);


CREATE TABLE answer (
    question_id integer NOT NULL,
    student_id integer NOT NULL,
    answer character(1) NOT NULL
);


--
-- TOC entry 48 (OID 2265460)
-- Name: project_pkey; Type: CONSTRAINT; Schema: public; Owner: vds8085
--

ALTER TABLE ONLY project
    ADD CONSTRAINT project_pkey PRIMARY KEY (id);


--
-- TOC entry 49 (OID 2265464)
-- Name: state_pkey; Type: CONSTRAINT; Schema: public; Owner: vds8085
--

ALTER TABLE ONLY state
    ADD CONSTRAINT state_pkey PRIMARY KEY (id);


--
-- TOC entry 50 (OID 2265468)
-- Name: city_pkey; Type: CONSTRAINT; Schema: public; Owner: vds8085
--

ALTER TABLE ONLY city
    ADD CONSTRAINT city_pkey PRIMARY KEY (id);


--
-- TOC entry 51 (OID 2265481)
-- Name: school_pkey; Type: CONSTRAINT; Schema: public; Owner: vds8085
--

ALTER TABLE ONLY school
    ADD CONSTRAINT school_pkey PRIMARY KEY (id);


--
-- TOC entry 52 (OID 2265488)
-- Name: teacher_pkey; Type: CONSTRAINT; Schema: public; Owner: vds8085
--

ALTER TABLE ONLY teacher
    ADD CONSTRAINT teacher_pkey PRIMARY KEY (id);


--
-- TOC entry 53 (OID 2265498)
-- Name: research_group_pkey; Type: CONSTRAINT; Schema: public; Owner: vds8085
--

ALTER TABLE ONLY research_group
    ADD CONSTRAINT research_group_pkey PRIMARY KEY (id);


--
-- TOC entry 54 (OID 2265505)
-- Name: student_pkey; Type: CONSTRAINT; Schema: public; Owner: vds8085
--

ALTER TABLE ONLY student
    ADD CONSTRAINT student_pkey PRIMARY KEY (id);


--
-- TOC entry 55 (OID 3563328)
-- Name: keyword_pkey; Type: CONSTRAINT; Schema: public; Owner: vds8085
--

ALTER TABLE ONLY keyword
    ADD CONSTRAINT keyword_pkey PRIMARY KEY (id);


--
-- TOC entry 56 (OID 3563469)
-- Name: log_pkey; Type: CONSTRAINT; Schema: public; Owner: vds8085
--

ALTER TABLE ONLY log
    ADD CONSTRAINT log_pkey PRIMARY KEY (id);


--
-- TOC entry 82 (OID 3563471)
-- Name: $1; Type: CONSTRAINT; Schema: public; Owner: vds8085
--

ALTER TABLE ONLY log
    ADD CONSTRAINT "$1" FOREIGN KEY (project_id) REFERENCES project(id) ON UPDATE NO ACTION ON DELETE CASCADE;


--
-- TOC entry 83 (OID 3563475)
-- Name: $2; Type: CONSTRAINT; Schema: public; Owner: vds8085
--

ALTER TABLE ONLY log
    ADD CONSTRAINT "$2" FOREIGN KEY (research_group_id) REFERENCES research_group(id) ON UPDATE NO ACTION ON DELETE CASCADE;


--
-- TOC entry 84 (OID 3563479)
-- Name: $3; Type: CONSTRAINT; Schema: public; Owner: vds8085
--

ALTER TABLE ONLY log
    ADD CONSTRAINT "$3" FOREIGN KEY (ref_rg_id) REFERENCES research_group(id) ON UPDATE NO ACTION ON DELETE CASCADE;


--
-- TOC entry 85 (OID 3563483)
-- Name: $4; Type: CONSTRAINT; Schema: public; Owner: vds8085
--

ALTER TABLE ONLY log
    ADD CONSTRAINT "$4" FOREIGN KEY (keyword_id) REFERENCES keyword(id) ON UPDATE NO ACTION ON DELETE CASCADE;


--
-- TOC entry 57 (OID 3563975)
-- Name: comment_pkey; Type: CONSTRAINT; Schema: public; Owner: vds8085
--

ALTER TABLE ONLY "comment"
    ADD CONSTRAINT comment_pkey PRIMARY KEY (id);


--
-- TOC entry 86 (OID 3563977)
-- Name: $1; Type: CONSTRAINT; Schema: public; Owner: vds8085
--

ALTER TABLE ONLY "comment"
    ADD CONSTRAINT "$1" FOREIGN KEY (log_id) REFERENCES log(id) ON UPDATE NO ACTION ON DELETE CASCADE;


--
-- TOC entry 58 (OID 3565503)
-- Name: keyword1_pkey; Type: CONSTRAINT; Schema: public; Owner: vds8085
--

ALTER TABLE ONLY keyword1
    ADD CONSTRAINT keyword1_pkey PRIMARY KEY (id);


--
-- TOC entry 59 (OID 3575188)
-- Name: usage_pkey; Type: CONSTRAINT; Schema: public; Owner: vds8085
--

ALTER TABLE ONLY "usage"
    ADD CONSTRAINT usage_pkey PRIMARY KEY (id);


--
-- TOC entry 87 (OID 3575190)
-- Name: $1; Type: CONSTRAINT; Schema: public; Owner: vds8085
--

ALTER TABLE ONLY "usage"
    ADD CONSTRAINT "$1" FOREIGN KEY (research_group_id) REFERENCES research_group(id) ON UPDATE NO ACTION ON DELETE NO ACTION;


--
-- TOC entry 60 (OID 3736881)
-- Name: question_pkey; Type: CONSTRAINT; Schema: public; Owner: vds8085
--

ALTER TABLE ONLY question
    ADD CONSTRAINT question_pkey PRIMARY KEY (id);


--
-- TOC entry 88 (OID 3736883)
-- Name: $1; Type: CONSTRAINT; Schema: public; Owner: vds8085
--

ALTER TABLE ONLY question
    ADD CONSTRAINT "$1" FOREIGN KEY (project_id) REFERENCES project(id) ON UPDATE NO ACTION ON DELETE CASCADE;


--
-- TOC entry 61 (OID 3736889)
-- Name: answer_pkey; Type: CONSTRAINT; Schema: public; Owner: vds8085
--

ALTER TABLE ONLY answer
    ADD CONSTRAINT answer_pkey PRIMARY KEY (question_id, student_id);


--
-- TOC entry 89 (OID 3736891)
-- Name: $1; Type: CONSTRAINT; Schema: public; Owner: vds8085
--

ALTER TABLE ONLY answer
    ADD CONSTRAINT "$1" FOREIGN KEY (question_id) REFERENCES question(id) ON UPDATE NO ACTION ON DELETE CASCADE;


--
-- TOC entry 90 (OID 3736895)
-- Name: $2; Type: CONSTRAINT; Schema: public; Owner: vds8085
--

ALTER TABLE ONLY answer
    ADD CONSTRAINT "$2" FOREIGN KEY (student_id) REFERENCES student(id) ON UPDATE NO ACTION ON DELETE CASCADE;

