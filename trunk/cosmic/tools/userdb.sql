--CREATE DATABASE userdb8082_2004_0720;

--DROP TABLE project;
DROP SEQUENCE state_id_seq;
--DROP TABLE state;
DROP SEQUENCE city_id_seq;
--DROP TABLE city;
DROP SEQUENCE school_id_seq;
--DROP TABLE school;
DROP SEQUENCE teacher_id_seq;
--DROP TABLE teacher;
DROP SEQUENCE research_group_id_seq;
--DROP TABLE research_group;
DROP SEQUENCE student_id_seq;
DROP SEQUENCE question_id_seq;
DROP SEQUENCE answer_id_seq;
--DROP TABLE student;
--DROP TABLE research_group_project;
--DROP TABLE research_group_student;
--DROP TABLE survey;
CREATE TABLE project (id int PRIMARY KEY, name varchar(50));
CREATE TABLE state (id int PRIMARY KEY, name varchar(100), abbreviation char(2));
CREATE TABLE city (id int PRIMARY KEY, name varchar(100), state_id int);
CREATE SEQUENCE state_id_seq MINVALUE 1;
ALTER TABLE state ALTER id SET DEFAULT nextval('state_id_seq');
CREATE SEQUENCE city_id_seq MINVALUE 1;
ALTER TABLE city ALTER id SET DEFAULT nextval('city_id_seq');
CREATE SEQUENCE school_id_seq MINVALUE 1;
CREATE TABLE school (id int PRIMARY KEY DEFAULT nextval('school_id_seq'), name varchar(100) NOT NULL, city_id int);
CREATE SEQUENCE teacher_id_seq MINVALUE 1;
CREATE TABLE teacher (id int PRIMARY KEY DEFAULT nextval('teacher_id_seq'), name varchar(100) NOT NULL, email varchar(150),school_id int);
CREATE SEQUENCE research_group_id_seq MINVALUE 1;
CREATE TABLE research_group (id int PRIMARY KEY DEFAULT nextval('research_group_id_seq'), name varchar(100) NOT NULL, password varchar(100) NOT NULL, teacher_id int, role varchar(50), userarea text, ay char(6), survey boolean);
CREATE SEQUENCE student_id_seq MINVALUE 1;
CREATE TABLE student (id int PRIMARY KEY DEFAULT nextval('student_id_seq'), name varchar(100) NOT NULL);
CREATE TABLE research_group_project (research_group_id int, project_id int);
CREATE TABLE research_group_student (research_group_id int, student_id int);
CREATE TABLE survey (student_id int, project_id int, presurvey bool DEFAULT false, postsurvey bool DEFAULT false);
CREATE TABLE research_group_detectorID (research_group_id int, detectorID smallint);
CREATE TABLE research_group_favorite (research_group_id int, favorite smallint);
-- survey tables
CREATE SEQUENCE question_id_seq MINVALUE 1;
CREATE TABLE question (id int PRIMARY KEY DEFAULT nextval('question_id_seq'),
        question text, answer char(1) NOT NULL);
CREATE TABLE answer (
        question_id int, student_id int, answer char(1) NOT
        NULL, FOREIGN KEY(question_id) REFERENCES question(id) ON DELETE CASCADE, FOREIGN
        KEY(student_id) REFERENCES student(id) ON DELETE CASCADE, PRIMARY KEY
        (question_id, student_id));
INSERT INTO question (question, answer) VALUES ('What is the slope of the
        line?', 'c');
INSERT INTO question (question, answer) VALUES ('What is the maximum value?',
        'a');
INSERT INTO question (question, answer) VALUES ('How many detectors do you
        have?', 'b');
INSERT INTO answer (question_id, student_id, answer) VALUES (1, 2, 'c');
INSERT INTO answer (question_id, student_id, answer) VALUES (2, 2, 'b');
INSERT INTO answer (question_id, student_id, answer) VALUES (3, 2, 'b');
INSERT INTO answer (question_id, student_id, answer) VALUES (1, 1, 'c');
INSERT INTO answer (question_id, student_id, answer) VALUES (2, 1, 'f');
INSERT INTO answer (question_id, student_id, answer) VALUES (3, 1, 'z');
INSERT INTO state (name, abbreviation) VALUES ('ALABAMA', 'AL');
INSERT INTO state (name, abbreviation) VALUES ('ALASKA', 'AK');
INSERT INTO state (name, abbreviation) VALUES ('AMERICAN SAMOA', 'AS');
INSERT INTO state (name, abbreviation) VALUES ('ARIZONA', 'AZ');
INSERT INTO state (name, abbreviation) VALUES ('ARKANSAS', 'AR');
INSERT INTO state (name, abbreviation) VALUES ('CALIFORNIA', 'CA');
INSERT INTO state (name, abbreviation) VALUES ('COLORADO', 'CO');
INSERT INTO state (name, abbreviation) VALUES ('CONNECTICUT', 'CT');
INSERT INTO state (name, abbreviation) VALUES ('DELAWARE', 'DE');
INSERT INTO state (name, abbreviation) VALUES ('DISTRICT OF COLUMBIA', 'DC');
INSERT INTO state (name, abbreviation) VALUES ('FEDERATED STATES OF MICRONESIA', 'FM');
INSERT INTO state (name, abbreviation) VALUES ('FLORIDA', 'FL');
INSERT INTO state (name, abbreviation) VALUES ('GEORGIA', 'GA');
INSERT INTO state (name, abbreviation) VALUES ('GUAM', 'GU');
INSERT INTO state (name, abbreviation) VALUES ('HAWAII', 'HI');
INSERT INTO state (name, abbreviation) VALUES ('IDAHO', 'ID');
INSERT INTO state (name, abbreviation) VALUES ('ILLINOIS', 'IL');
INSERT INTO state (name, abbreviation) VALUES ('INDIANA', 'IN');
INSERT INTO state (name, abbreviation) VALUES ('IOWA', 'IA');
INSERT INTO state (name, abbreviation) VALUES ('KANSAS', 'KS');
INSERT INTO state (name, abbreviation) VALUES ('KENTUCKY', 'KY');
INSERT INTO state (name, abbreviation) VALUES ('LOUISIANA', 'LA');
INSERT INTO state (name, abbreviation) VALUES ('MAINE', 'ME');
INSERT INTO state (name, abbreviation) VALUES ('MARSHALL ISLANDS', 'MH');
INSERT INTO state (name, abbreviation) VALUES ('MARYLAND', 'MD');
INSERT INTO state (name, abbreviation) VALUES ('MASSACHUSETTS', 'MA');
INSERT INTO state (name, abbreviation) VALUES ('MICHIGAN', 'MI');
INSERT INTO state (name, abbreviation) VALUES ('MINNESOTA', 'MN');
INSERT INTO state (name, abbreviation) VALUES ('MISSISSIPPI', 'MS');
INSERT INTO state (name, abbreviation) VALUES ('MISSOURI', 'MO');
INSERT INTO state (name, abbreviation) VALUES ('MONTANA', 'MT');
INSERT INTO state (name, abbreviation) VALUES ('NEBRASKA', 'NE');
INSERT INTO state (name, abbreviation) VALUES ('NEVADA', 'NV');
INSERT INTO state (name, abbreviation) VALUES ('NEW HAMPSHIRE', 'NH');
INSERT INTO state (name, abbreviation) VALUES ('NEW JERSEY', 'NJ');
INSERT INTO state (name, abbreviation) VALUES ('NEW MEXICO', 'NM');
INSERT INTO state (name, abbreviation) VALUES ('NEW YORK', 'NY');
INSERT INTO state (name, abbreviation) VALUES ('NORTH CAROLINA', 'NC');
INSERT INTO state (name, abbreviation) VALUES ('NORTH DAKOTA', 'ND');
INSERT INTO state (name, abbreviation) VALUES ('NORTHERN MARIANA ISLANDS', 'MP');
INSERT INTO state (name, abbreviation) VALUES ('OHIO', 'OH');
INSERT INTO state (name, abbreviation) VALUES ('OKLAHOMA', 'OK');
INSERT INTO state (name, abbreviation) VALUES ('OREGON', 'OR');
INSERT INTO state (name, abbreviation) VALUES ('PALAU', 'PW');
INSERT INTO state (name, abbreviation) VALUES ('PENNSYLVANIA', 'PA');
INSERT INTO state (name, abbreviation) VALUES ('PUERTO RICO', 'PR');
INSERT INTO state (name, abbreviation) VALUES ('RHODE ISLAND', 'RI');
INSERT INTO state (name, abbreviation) VALUES ('SOUTH CAROLINA', 'SC');
INSERT INTO state (name, abbreviation) VALUES ('SOUTH DAKOTA', 'SD');
INSERT INTO state (name, abbreviation) VALUES ('TENNESSEE', 'TN');
INSERT INTO state (name, abbreviation) VALUES ('TEXAS', 'TX');
INSERT INTO state (name, abbreviation) VALUES ('UTAH', 'UT');
INSERT INTO state (name, abbreviation) VALUES ('VERMONT', 'VT');
INSERT INTO state (name, abbreviation) VALUES ('VIRGIN ISLANDS', 'VI');
INSERT INTO state (name, abbreviation) VALUES ('VIRGINIA', 'VA');
INSERT INTO state (name, abbreviation) VALUES ('WASHINGTON', 'WA');
INSERT INTO state (name, abbreviation) VALUES ('WEST VIRGINIA', 'WV');
INSERT INTO state (name, abbreviation) VALUES ('WISCONSIN', 'WI');
INSERT INTO state (name, abbreviation) VALUES ('WYOMING', 'WY');
--usage table
CREATE sequence usage_id_seq minvalue 0;
CREATE table usage (id int PRIMARY KEY DEFAULT nextval('usage_id_seq'), research_group_id int not null, date_entered timestamp without time zone default now(), FOREIGN KEY(research_group_id) REFERENCES research_group(id));


--create the first "project" - cosmic
INSERT INTO project (id, name) VALUES(1, 'cosmic');

--"guest" group
INSERT INTO city (name) VALUES ('Chicago');
UPDATE city SET state_id=state.id FROM state WHERE state.abbreviation='IL';
INSERT INTO school (name) VALUES ('UofC');
UPDATE school SET city_id=city.id FROM city WHERE city.name='Chicago';
INSERT INTO teacher (name) VALUES ('Physics7');
UPDATE teacher SET school_id=school.id FROM school WHERE school.name='UofC';
INSERT INTO research_group (name, password, role, userarea) VALUES ('group2', 'password', 'user', 'AY2004/IL/Chicago/UofC/Physics7/group2');
UPDATE research_group SET teacher_id=teacher.id FROM teacher WHERE teacher.name='Physics7';
--"fermigroup" group
INSERT INTO city (name) VALUES ('Batavia');
UPDATE city SET state_id=state.id FROM state WHERE state.abbreviation='IL';
INSERT INTO school (name) VALUES ('Fermilab');
UPDATE school SET city_id=city.id FROM city WHERE city.name='Batavia';
INSERT INTO teacher (name) VALUES ('Jordan');
UPDATE teacher SET school_id=school.id FROM school WHERE school.name='Fermilab';
INSERT INTO research_group (name, password, role, userarea) VALUES ('fermigroup', 'blah', 'upload', 'AY2004/IL/Batavia/Fermilab/Jordan/fermigroup');
UPDATE research_group SET teacher_id=teacher.id FROM teacher WHERE teacher.name='Jordan';
INSERT INTO research_group_detectorid (research_group_id, detectorid) VALUES (2, 180);
INSERT INTO research_group_detectorid (research_group_id, detectorid) VALUES (2, 181);
--Reserved and special users
INSERT INTO research_group (name, password, role) VALUES ('qnteacher', 'pr0t0n', 'teacher');
