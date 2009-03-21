CREATE SEQUENCE log_id_seq MINVALUE 1;

CREATE TABLE log (id int PRIMARY KEY DEFAULT nextval('log_id_seq'),
        project_id int,
        research_group_id int NOT NULL,
        keyword_id int,
        role varchar(50) NOT NULL,
        ref_rg_id int,
        date_entered timestamp DEFAULT 'now',
        log_text text,
        FOREIGN KEY(project_id) REFERENCES project(id) ON DELETE CASCADE,
        FOREIGN KEY(research_group_id) REFERENCES research_group(id) ON DELETE CASCADE,
        FOREIGN KEY(ref_rg_id) REFERENCES research_group(id) ON DELETE CASCADE,
        FOREIGN KEY(keyword_id) REFERENCES keyword(id) ON DELETE CASCADE);

CREATE SEQUENCE comment_id_seq MINVALUE 1;

CREATE TABLE comment (id int PRIMARY KEY DEFAULT nextval('comment_id_seq'),
        log_id int NOT NULL,
        date_entered timestamp DEFAULT 'now',
        comment text NOT NULL,
        FOREIGN KEY(log_id) REFERENCES log(id) ON DELETE CASCADE);

CREATE SEQUENCE keyword_id_seq MINVALUE 1;

CREATE TABLE keyword (id int PRIMARY KEY DEFAULT nextval('keyword_id_seq'),
         keyword varchar(50) NOT NULL,
         description varchar(50) NOT NULL,
         project_id int,
         section char(1),
         section_id int);

INSERT INTO keyword (keyword,description,project_id,section,section_id) VALUES ('analysis_tools', 'Notes on analysis tools to use',1,'C',30 );
INSERT INTO keyword (keyword,description,project_id,section,section_id) VALUES ('collect_upload_data', 'Notes on collecting and uploading data',1,'C',10 );
 INSERT INTO keyword (keyword,description,project_id,section,section_id) VALUES ('comment_poster', 'Notes on commenting posters',1,'D',40 );
 INSERT INTO keyword (keyword,description,project_id,section,section_id) VALUES ('cosmic_ray_study', 'Notes on what you can study about cosmic rays.',1,'B',20 );
 INSERT INTO keyword (keyword,description,project_id,section,section_id) VALUES ('cosmic_rays', 'Description of cosmic rays in simple terms.',1,'B',10 );
 INSERT INTO keyword (keyword,description,project_id,section,section_id) VALUES ('create_poster', 'Notes on making a poster',1,'D',20 );
 INSERT INTO keyword (keyword,description,project_id,section,section_id) VALUES ('data_error', 'Notes of data error and background',1,'C',40 );
 INSERT INTO keyword (keyword,description,project_id,section,section_id) VALUES ('defend_solution', 'Notes on our observations and research.',1,'D',10 );
 INSERT INTO keyword (keyword,description,project_id,section,section_id) VALUES ('detector', 'Description of what the detector can do.',1,'B',30 );
 INSERT INTO keyword (keyword,description,project_id,section,section_id) VALUES ('general', 'General Notes',1,'A',1 );
 INSERT INTO keyword (keyword,description,project_id,section,section_id) VALUES ('research_plan', 'Our Research plan.',1,'A',50 );
 INSERT INTO keyword (keyword,description,project_id,section,section_id) VALUES ('research_proposal', 'Our research proposal',1,'B',40 );
 INSERT INTO keyword (keyword,description,project_id,section,section_id) VALUES ('research_question', 'Notes on developing a research question.',1,'A',40 );
 INSERT INTO keyword (keyword,description,project_id,section,section_id) VALUES ('search_parameters', 'Notes on search parameters.',1,'C',20 );
 INSERT INTO keyword (keyword,description,project_id,section,section_id) VALUES ('simple_calculations', 'Notes on simple calculations',1,'A',20 );
 INSERT INTO keyword (keyword,description,project_id,section,section_id) VALUES ('simple_graphs', 'Notes on simple graphs',1,'A',30 );
 INSERT INTO keyword (keyword,description,project_id,section,section_id) VALUES ('simple_measurements', 'Notes on simple measurements',1,'A',10 );
 
 Alter table comment Add new_comment bool;
 Alter table log Add new_log bool;

 select to_char(date_entered, 'MM/DD/YYYY HH12:MI:SS') from comment;

