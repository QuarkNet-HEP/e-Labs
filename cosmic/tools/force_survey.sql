update research_group set survey='t' where survey='f' and ay='AY2007';
insert into survey (student_id, project_id) (select id,1 from student
where id NOT in (select student_id from survey) and id in (select
student_id from research_group_student where research_group_id in
(select id from research_group where ay='AY2007')));
