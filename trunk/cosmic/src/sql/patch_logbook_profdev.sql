 Alter table keyword Add type char(2);
 Update keyword SET type='S';
 update keyword SET type='SW' where keyword='cosmic_rays';
 update keyword SET type='SW' where keyword='search_parameters';
 update keyword SET type='SW' where keyword='analysis_tools';
 update keyword SET type='SW' where keyword='data_error';
 update keyword SET type='SW' where keyword='defend_solution';
 update keyword SET type='SW' where keyword='create_poster';
 update keyword SET type='SW' where keyword='research_proposal';
 update keyword SET type='SW' where keyword='cosmic_ray_study';
 update keyword SET type='SW' where keyword='detector';
 update keyword SET type='SW' where section='A';
 
 
INSERT INTO keyword (keyword,description,project_id,section,section_id,type) VALUES ('detection_techniques', 'Notes on detection techniques',1,'B',25,'W');
INSERT INTO keyword (keyword,description,project_id,section,section_id,type) VALUES ('analysis_iterations', 'Notes on changes between analysis runs',1,'C',50,'W');
INSERT INTO keyword (keyword,description,project_id,section,section_id,type) VALUES ('classroom_insights', 'Notes on how to guide students',1,'C',55,'W');
