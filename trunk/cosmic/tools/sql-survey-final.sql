
DROP TABLE answer;
DROP TABLE question;
DROP SEQUENCE question_id_seq;

-- survey tables
CREATE SEQUENCE question_id_seq MINVALUE 1;
CREATE TABLE question (id int PRIMARY KEY DEFAULT nextval('question_id_seq'),
        project_id int,
        test_name varchar(50),
        question text, answer char(1) NOT NULL,
        response1 text NOT NULL, response2 text NOT NULL, response3 text, response4 text, response5 text,
         FOREIGN KEY(project_id) REFERENCES project(id) ON DELETE CASCADE);
CREATE TABLE answer (
        question_id int, student_id int, answer char(1) NOT
        NULL, FOREIGN KEY(question_id) REFERENCES question(id) ON DELETE CASCADE, FOREIGN
        KEY(student_id) REFERENCES student(id) ON DELETE CASCADE, PRIMARY KEY
        (question_id, student_id));


INSERT INTO question (project_id, test_name, question, answer, response1,response2,response3,response4,response5) VALUES (1,'pretest',
'Cosmic ray flux decreases:','3',
'when sun is below the horizon',
'during precipitation events',
'when barometric pressure is high',
'all of the above',
'do not know');

INSERT INTO question (project_id, test_name, question, answer, response1,response2,response3,response4,response5) VALUES (1,'pretest',
'Secondary cosmic rays are composed of:','1',
'kaons, pions, and nuclei with fewer nucleons',
'gamma rays, muons and neutrinos',
'positrons and electrons',
'all of the above',
'do not know');

INSERT INTO question (project_id, test_name, question, answer, response1,response2,response3,response4,response5) VALUES (1,'pretest',
'Cosmic rays are currently detected by:','4',
 'scintillation detectors',
 'Cerenkov radiation detectors',
 'photodiodes that measure flourescent light in the sky on moonless,cloudless nights',
 'all of the above',
 'do not know');
 
INSERT INTO question (project_id, test_name, question, answer, response1,response2,response3,response4,response5) VALUES (1,'pretest',
'Cosmic rays typically travel:','2',
 'at the speed of light',
 'at 99.999999% of the speed of light',
 'faster than the speed of light',
 'do not know','');

INSERT INTO question (project_id, test_name, question, answer, response1,response2,response3,response4,response5) VALUES (1,'pretest',
'A typical photomultiplier tube pulse lasts closest to:','1',
 '10 nanoseconds',
 '10 microseconds',
 '10 milliseconds',
 '10 seconds',
 'do not know');

INSERT INTO question (project_id, test_name, question, answer, response1,response2,response3,response4,response5) VALUES (1,'pretest',
'The likelihood of finding coincidences increases with:','2',
 'decreasing gate width',
 'increasing gate width',
 'removing detectors from the search list',
 'adding detectors to the search list',
 'do not know');

INSERT INTO question (project_id, test_name, question, answer, response1,response2,response3,response4,response5) VALUES (1,'pretest',
'Cosmic ray muon flux at earth surface is enhanced by:','1',
 'time dilation for the muon',
 'time dilation for our clocks',
 'length contraction for us',
 'do not know','');
 
INSERT INTO question (project_id, test_name, question, answer, response1,response2,response3,response4,response5) VALUES (1,'pretest',
'The energies of cosmic rays compare to:','1',
 'a dropped brick',
 'a truck collision',
 'a speeding train locomotive',
 'the Earth in orbit',
 'do not know');

INSERT INTO question (project_id, test_name, question, answer, response1,response2,response3,response4,response5) VALUES (1,'pretest',
'Source of data errors in measuring cosmic rays is:','4',
 'calibration drift',
 'scintillator light leaks',
 'photomultiplier dark current',
 'all of the above',
 'do not know');

INSERT INTO question (project_id, test_name, question, answer, response1,response2,response3,response4,response5) VALUES (1,'pretest',
'A teacher has written a new final exam for his five sections of chemistry and has been asked to present the results to his department chairman. What data should he use?','3',
'Class-level data: The average scores of each of his five classes.',
'Overall data: The average score of all of his students.',
'Student-level data: The individual scores of each of his students.',
'do not know','');

INSERT INTO question (project_id, test_name, question, answer, response1,response2,response3,response4,response5) VALUES (1,'pretest',
'Examine Figures A1, A2, and A3, three representations of the data from the new exam. <BR><BR><IMG SRC="graphics/figurea1.gif"><IMG SRC="graphics/figurea2.gif"><BR>
<IMG SRC="graphics/figurea3.gif"><BR>Which of the three representations provides the most useful graphical information?','2',
'Figure A1, the pie chart.',
'Figure A2, the histogram.',
'Figure A3, the scatterplot.',
'do not know','');

INSERT INTO question (project_id, test_name, question, answer, response1,response2,response3,response4,response5) VALUES (1,'pretest',
'Examine Figures B1, B2, and B3, which were all generated from the same data on student tardiness (n = 1,000 students).<BR><BR><IMG SRC="graphics/figureb1.gif"><IMG SRC="graphics/figureb2.gif"><BR>
<IMG SRC="graphics/figureb3.gif"><BR>	Which histogram gives you the most information about student tardiness?','2',
'Figure B1.',
'Figure B2.',
'Figure B3.',
'do not know','');


INSERT INTO question (project_id, test_name, question, answer, response1,response2,response3,response4,response5) VALUES (1,'pretest',
'Which histogram is the most misleading about the actual pattern of student tardiness?','3',
'Figure B1.',
'Figure B2.',
'Figure B3.',
'do not know','');

INSERT INTO question (project_id, test_name, question, answer, response1,response2,response3,response4,response5) VALUES (1,'pretest',
'Which of the following statements best describes the pattern of student tardiness?','1',
'There are two main groups of students: rarely tardy (1-3 times), and frequently tardy (6-7 times).',
'Very few students are never tardy, but generally, as the number of tardies increases, the number of students with that number of tardies decreases.',
'There is no real pattern. The number of students with a given number of tardies jumps around randomly.',
'do not know','');

INSERT INTO question (project_id, test_name, question, answer, response1,response2,response3,response4,response5) VALUES (1,'pretest',
'Which of the three histograms was most useful in answering the previous question?','2',
'Figure B1.',
'Figure B2.',
'Figure B3.',
'do not know','');

INSERT INTO question (project_id, test_name, question, answer, response1,response2,response3,response4,response5) VALUES (1,'pretest',
'Which of the three histograms would you use to draw a curve representing this data?','2',
'Figure B1.',
'Figure B2.',
'Figure B3.',
'do not know','');
 
 select question.question, question.answer as correct, answer.answer from question,answer where question.id=answer.question_id and student_id=166 order by answer.question_id;
