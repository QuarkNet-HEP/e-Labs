-- populates userdb with a pile of data that was taken from
-- quarknet.cs.uchicago.edu in early August 2006

INSERT INTO project (id, name) VALUES (1, 'cosmic');

INSERT INTO state (id, name, abbreviation) VALUES (1, 'ALABAMA', 'AL');
INSERT INTO state (id, name, abbreviation) VALUES (2, 'ALASKA', 'AK');
INSERT INTO state (id, name, abbreviation) VALUES (3, 'AMERICAN SAMOA', 'AS');
INSERT INTO state (id, name, abbreviation) VALUES (4, 'ARIZONA', 'AZ');
INSERT INTO state (id, name, abbreviation) VALUES (5, 'ARKANSAS', 'AR');
INSERT INTO state (id, name, abbreviation) VALUES (6, 'CALIFORNIA', 'CA');
INSERT INTO state (id, name, abbreviation) VALUES (7, 'COLORADO', 'CO');
INSERT INTO state (id, name, abbreviation) VALUES (8, 'CONNECTICUT', 'CT');
INSERT INTO state (id, name, abbreviation) VALUES (9, 'DELAWARE', 'DE');
INSERT INTO state (id, name, abbreviation) VALUES (10, 'DISTRICT OF COLUMBIA', 'DC');
INSERT INTO state (id, name, abbreviation) VALUES (11, 'FEDERATED STATES OF MICRONESIA', 'FM');
INSERT INTO state (id, name, abbreviation) VALUES (12, 'FLORIDA', 'FL');
INSERT INTO state (id, name, abbreviation) VALUES (13, 'GEORGIA', 'GA');
INSERT INTO state (id, name, abbreviation) VALUES (14, 'GUAM', 'GU');
INSERT INTO state (id, name, abbreviation) VALUES (15, 'HAWAII', 'HI');
INSERT INTO state (id, name, abbreviation) VALUES (16, 'IDAHO', 'ID');
INSERT INTO state (id, name, abbreviation) VALUES (17, 'ILLINOIS', 'IL');
INSERT INTO state (id, name, abbreviation) VALUES (18, 'INDIANA', 'IN');
INSERT INTO state (id, name, abbreviation) VALUES (19, 'IOWA', 'IA');
INSERT INTO state (id, name, abbreviation) VALUES (20, 'KANSAS', 'KS');
INSERT INTO state (id, name, abbreviation) VALUES (21, 'KENTUCKY', 'KY');
INSERT INTO state (id, name, abbreviation) VALUES (22, 'LOUISIANA', 'LA');
INSERT INTO state (id, name, abbreviation) VALUES (23, 'MAINE', 'ME');
INSERT INTO state (id, name, abbreviation) VALUES (24, 'MARSHALL ISLANDS', 'MH');
INSERT INTO state (id, name, abbreviation) VALUES (25, 'MARYLAND', 'MD');
INSERT INTO state (id, name, abbreviation) VALUES (26, 'MASSACHUSETTS', 'MA');
INSERT INTO state (id, name, abbreviation) VALUES (27, 'MICHIGAN', 'MI');
INSERT INTO state (id, name, abbreviation) VALUES (28, 'MINNESOTA', 'MN');
INSERT INTO state (id, name, abbreviation) VALUES (29, 'MISSISSIPPI', 'MS');
INSERT INTO state (id, name, abbreviation) VALUES (30, 'MISSOURI', 'MO');
INSERT INTO state (id, name, abbreviation) VALUES (31, 'MONTANA', 'MT');
INSERT INTO state (id, name, abbreviation) VALUES (32, 'NEBRASKA', 'NE');
INSERT INTO state (id, name, abbreviation) VALUES (33, 'NEVADA', 'NV');
INSERT INTO state (id, name, abbreviation) VALUES (34, 'NEW HAMPSHIRE', 'NH');
INSERT INTO state (id, name, abbreviation) VALUES (35, 'NEW JERSEY', 'NJ');
INSERT INTO state (id, name, abbreviation) VALUES (36, 'NEW MEXICO', 'NM');
INSERT INTO state (id, name, abbreviation) VALUES (37, 'NEW YORK', 'NY');
INSERT INTO state (id, name, abbreviation) VALUES (38, 'NORTH CAROLINA', 'NC');
INSERT INTO state (id, name, abbreviation) VALUES (39, 'NORTH DAKOTA', 'ND');
INSERT INTO state (id, name, abbreviation) VALUES (40, 'NORTHERN MARIANA ISLANDS', 'MP');
INSERT INTO state (id, name, abbreviation) VALUES (41, 'OHIO', 'OH');
INSERT INTO state (id, name, abbreviation) VALUES (42, 'OKLAHOMA', 'OK');
INSERT INTO state (id, name, abbreviation) VALUES (43, 'OREGON', 'OR');
INSERT INTO state (id, name, abbreviation) VALUES (44, 'PALAU', 'PW');
INSERT INTO state (id, name, abbreviation) VALUES (45, 'PENNSYLVANIA', 'PA');
INSERT INTO state (id, name, abbreviation) VALUES (46, 'PUERTO RICO', 'PR');
INSERT INTO state (id, name, abbreviation) VALUES (47, 'RHODE ISLAND', 'RI');
INSERT INTO state (id, name, abbreviation) VALUES (48, 'SOUTH CAROLINA', 'SC');
INSERT INTO state (id, name, abbreviation) VALUES (49, 'SOUTH DAKOTA', 'SD');
INSERT INTO state (id, name, abbreviation) VALUES (50, 'TENNESSEE', 'TN');
INSERT INTO state (id, name, abbreviation) VALUES (51, 'TEXAS', 'TX');
INSERT INTO state (id, name, abbreviation) VALUES (52, 'UTAH', 'UT');
INSERT INTO state (id, name, abbreviation) VALUES (53, 'VERMONT', 'VT');
INSERT INTO state (id, name, abbreviation) VALUES (54, 'VIRGIN ISLANDS', 'VI');
INSERT INTO state (id, name, abbreviation) VALUES (55, 'VIRGINIA', 'VA');
INSERT INTO state (id, name, abbreviation) VALUES (56, 'WASHINGTON', 'WA');
INSERT INTO state (id, name, abbreviation) VALUES (57, 'WEST VIRGINIA', 'WV');
INSERT INTO state (id, name, abbreviation) VALUES (58, 'WISCONSIN', 'WI');
INSERT INTO state (id, name, abbreviation) VALUES (59, 'WYOMING', 'WY');


INSERT INTO city (id, name, state_id) VALUES (1, 'Chicago', 17);
INSERT INTO city (id, name, state_id) VALUES (2, 'Batavia', 17);
INSERT INTO city (id, name, state_id) VALUES (3, 'Fictitious City', 7);
INSERT INTO city (id, name, state_id) VALUES (4, 'Birmingham', 1);
INSERT INTO city (id, name, state_id) VALUES (5, 'Tamps', 12);
INSERT INTO city (id, name, state_id) VALUES (6, 'Juneau', 2);
INSERT INTO city (id, name, state_id) VALUES (7, 'Sebastian', 12);
INSERT INTO city (id, name, state_id) VALUES (8, 'Palos Heights', 17);
INSERT INTO city (id, name, state_id) VALUES (9, 'notre dame', 18);
INSERT INTO city (id, name, state_id) VALUES (10, 'kjhkjh', 5);
INSERT INTO city (id, name, state_id) VALUES (11, 'Melbourne', 12);
INSERT INTO city (id, name, state_id) VALUES (12, 'Federal Way', 56);
INSERT INTO city (id, name, state_id) VALUES (13, 'Issaquah', 56);
INSERT INTO city (id, name, state_id) VALUES (14, 'Kirkland', 56);
INSERT INTO city (id, name, state_id) VALUES (15, 'Renton', 56);
INSERT INTO city (id, name, state_id) VALUES (16, 'Lynnwood', 56);
INSERT INTO city (id, name, state_id) VALUES (17, 'Monroe', 56);
INSERT INTO city (id, name, state_id) VALUES (18, 'Seattle', 56);
INSERT INTO city (id, name, state_id) VALUES (19, 'Redmond', 56);
INSERT INTO city (id, name, state_id) VALUES (20, 'Miami', 12);
INSERT INTO city (id, name, state_id) VALUES (21, 'Cincinatti', 41);
INSERT INTO city (id, name, state_id) VALUES (22, 'Tucson', 4);
INSERT INTO city (id, name, state_id) VALUES (23, 'Hillside', 17);
INSERT INTO city (id, name, state_id) VALUES (24, 'Lombard', 17);
INSERT INTO city (id, name, state_id) VALUES (25, 'Hampton', 55);
INSERT INTO city (id, name, state_id) VALUES (26, 'Berkeley', 6);
INSERT INTO city (id, name, state_id) VALUES (27, 'FORT WORTH', 51);
INSERT INTO city (id, name, state_id) VALUES (28, 'Sammamish', 56);
INSERT INTO city (id, name, state_id) VALUES (29, 'Lincoln', 32);
INSERT INTO city (id, name, state_id) VALUES (30, 'Mayaduez', 46);
INSERT INTO city (id, name, state_id) VALUES (31, 'Northbrook', 17);
INSERT INTO city (id, name, state_id) VALUES (32, 'Palatine', 17);
INSERT INTO city (id, name, state_id) VALUES (33, 'Piedmont', 6);
INSERT INTO city (id, name, state_id) VALUES (34, 'Fremont', 6);
INSERT INTO city (id, name, state_id) VALUES (35, 'Castro Valley', 6);
INSERT INTO city (id, name, state_id) VALUES (36, 'Danville', 6);
INSERT INTO city (id, name, state_id) VALUES (37, 'Lafayette', 6);
INSERT INTO city (id, name, state_id) VALUES (38, 'Sequim', 56);
INSERT INTO city (id, name, state_id) VALUES (39, 'Elmhurst', 17);
INSERT INTO city (id, name, state_id) VALUES (40, 'Muleshoe', 51);
INSERT INTO city (id, name, state_id) VALUES (41, 'Detroit', 27);
INSERT INTO city (id, name, state_id) VALUES (42, 'Titusville', 12);
INSERT INTO city (id, name, state_id) VALUES (43, 'Lake Zurich', 17);
INSERT INTO city (id, name, state_id) VALUES (44, 'RICHTON PARK', 17);
INSERT INTO city (id, name, state_id) VALUES (45, 'Romeoville', 17);
INSERT INTO city (id, name, state_id) VALUES (46, 'Oxford', 29);
INSERT INTO city (id, name, state_id) VALUES (47, 'Columbus', 29);
INSERT INTO city (id, name, state_id) VALUES (48, 'Corinth', 29);
INSERT INTO city (id, name, state_id) VALUES (49, 'Ridgeland', 29);
INSERT INTO city (id, name, state_id) VALUES (50, 'Louisville', 29);
INSERT INTO city (id, name, state_id) VALUES (51, 'Vero Beach', 12);
INSERT INTO city (id, name, state_id) VALUES (52, 'satellite beach', 12);
INSERT INTO city (id, name, state_id) VALUES (53, 'Stevensville', 27);
INSERT INTO city (id, name, state_id) VALUES (54, 'south bend', 18);
INSERT INTO city (id, name, state_id) VALUES (55, 'Mishawaka', 18);
INSERT INTO city (id, name, state_id) VALUES (56, 'Fermilab', 17);
INSERT INTO city (id, name, state_id) VALUES (57, 'Norfolk', 55);
INSERT INTO city (id, name, state_id) VALUES (58, 'Garland', 51);
INSERT INTO city (id, name, state_id) VALUES (59, 'Huntington Beach', 6);
INSERT INTO city (id, name, state_id) VALUES (60, 'Houston', 51);
INSERT INTO city (id, name, state_id) VALUES (61, 'Richmond', 51);
INSERT INTO city (id, name, state_id) VALUES (62, 'Moorestown', 35);
INSERT INTO city (id, name, state_id) VALUES (63, 'Oklahoma City', 42);
INSERT INTO city (id, name, state_id) VALUES (64, 'Rochester', 37);
INSERT INTO city (id, name, state_id) VALUES (65, 'Boone', 19);
INSERT INTO city (id, name, state_id) VALUES (66, 'Irving', 51);
INSERT INTO city (id, name, state_id) VALUES (67, 'Belmont', 26);
INSERT INTO city (id, name, state_id) VALUES (68, 'East Lansing', 27);
INSERT INTO city (id, name, state_id) VALUES (69, 'New Buffalo', 27);
INSERT INTO city (id, name, state_id) VALUES (70, 'LaPorte', 18);
INSERT INTO city (id, name, state_id) VALUES (71, 'Elkhart', 18);
INSERT INTO city (id, name, state_id) VALUES (72, 'Bremen', 18);
INSERT INTO city (id, name, state_id) VALUES (73, 'Paso Robles', 6);
INSERT INTO city (id, name, state_id) VALUES (74, 'Apache', 42);
INSERT INTO city (id, name, state_id) VALUES (75, 'Sulphur', 42);
INSERT INTO city (id, name, state_id) VALUES (76, 'Tulsa', 42);
INSERT INTO city (id, name, state_id) VALUES (77, 'Bethesda', 25);
INSERT INTO city (id, name, state_id) VALUES (78, 'Baltimore', 25);
INSERT INTO city (id, name, state_id) VALUES (79, 'Brooklandville', 25);
INSERT INTO city (id, name, state_id) VALUES (80, 'Centreville', 55);
INSERT INTO city (id, name, state_id) VALUES (81, 'Lorton', 55);
INSERT INTO city (id, name, state_id) VALUES (82, 'West Springfield', 55);
INSERT INTO city (id, name, state_id) VALUES (83, 'Geneva', 17);
INSERT INTO city (id, name, state_id) VALUES (84, 'Salt Lake City', 52);
INSERT INTO city (id, name, state_id) VALUES (85, 'Rockville', 25);
INSERT INTO city (id, name, state_id) VALUES (86, 'West Roxbury', 26);
INSERT INTO city (id, name, state_id) VALUES (87, 'Basalt', 7);
INSERT INTO city (id, name, state_id) VALUES (88, 'Carbondale', 7);
INSERT INTO city (id, name, state_id) VALUES (89, 'Boston', 26);
INSERT INTO city (id, name, state_id) VALUES (90, 'Needham', 26);
INSERT INTO city (id, name, state_id) VALUES (91, 'Swampscott', 26);
INSERT INTO city (id, name, state_id) VALUES (92, 'Gloucester', 26);
INSERT INTO city (id, name, state_id) VALUES (93, 'North Andover', 26);
INSERT INTO city (id, name, state_id) VALUES (94, 'Medford', 26);
INSERT INTO city (id, name, state_id) VALUES (95, 'Aspen', 7);
INSERT INTO city (id, name, state_id) VALUES (96, 'Pasadena', 6);
INSERT INTO city (id, name, state_id) VALUES (97, 'Cincinnati', 41);
INSERT INTO city (id, name, state_id) VALUES (98, 'El Paso', 51);
INSERT INTO city (id, name, state_id) VALUES (99, 'Aurora', 17);
INSERT INTO city (id, name, state_id) VALUES (100, 'Poughkeepsie', 37);
INSERT INTO city (id, name, state_id) VALUES (101, 'Elgin', 17);
INSERT INTO city (id, name, state_id) VALUES (102, 'Plymouth', 28);
INSERT INTO city (id, name, state_id) VALUES (103, 'Hurst', 51);
INSERT INTO city (id, name, state_id) VALUES (104, 'wanamingo', 28);
INSERT INTO city (id, name, state_id) VALUES (105, 'Bangalore', 18);
INSERT INTO city (id, name, state_id) VALUES (106, 'Rochester', 28);
INSERT INTO city (id, name, state_id) VALUES (107, 'Glenwood Springs', 7);
INSERT INTO city (id, name, state_id) VALUES (108, 'Dallas', 51);
INSERT INTO city (id, name, state_id) VALUES (109, 'Wylie', 51);
INSERT INTO city (id, name, state_id) VALUES (110, 'Sachse', 51);
INSERT INTO city (id, name, state_id) VALUES (111, 'DeSoto', 51);
INSERT INTO city (id, name, state_id) VALUES (112, 'Molina High School', 51);
INSERT INTO city (id, name, state_id) VALUES (113, 'Cedar Hill', 51);
INSERT INTO city (id, name, state_id) VALUES (114, 'Sugar Land', 51);
INSERT INTO city (id, name, state_id) VALUES (115, 'Lexington', 48);
INSERT INTO city (id, name, state_id) VALUES (116, 'Bettendorf', 19);
INSERT INTO city (id, name, state_id) VALUES (117, 'Roseburg', 43);
INSERT INTO city (id, name, state_id) VALUES (118, 'Eugene', 43);
INSERT INTO city (id, name, state_id) VALUES (119, 'Bend', 43);
INSERT INTO city (id, name, state_id) VALUES (120, 'Portland', 43);
INSERT INTO city (id, name, state_id) VALUES (121, 'Silverton', 43);
INSERT INTO city (id, name, state_id) VALUES (122, 'Cottage Grove', 43);
INSERT INTO city (id, name, state_id) VALUES (123, 'BurnabyBC', 6);
INSERT INTO city (id, name, state_id) VALUES (124, 'OxfordIN', 18);
INSERT INTO city (id, name, state_id) VALUES (125, 'San Luis Obispo', 6);
INSERT INTO city (id, name, state_id) VALUES (126, 'Buffalo Grove', 17);
INSERT INTO city (id, name, state_id) VALUES (127, 'GenevaCH', 17);
INSERT INTO city (id, name, state_id) VALUES (128, 'River Falls', 58);
INSERT INTO city (id, name, state_id) VALUES (129, 'Boulder', 7);
INSERT INTO city (id, name, state_id) VALUES (130, 'Vancouver', 10);
INSERT INTO city (id, name, state_id) VALUES (131, 'VancouverBC', 10);
INSERT INTO city (id, name, state_id) VALUES (132, 'Manoa', 15);
INSERT INTO city (id, name, state_id) VALUES (133, 'Honolulu', 15);


INSERT INTO school (id, name, city_id) VALUES (1, 'UofC', 2);
INSERT INTO school (id, name, city_id) VALUES (2, 'Fermilab', 2);
INSERT INTO school (id, name, city_id) VALUES (3, 'Fictitious School', 3);
INSERT INTO school (id, name, city_id) VALUES (4, 'EEG High', 4);
INSERT INTO school (id, name, city_id) VALUES (5, 'HS', 5);
INSERT INTO school (id, name, city_id) VALUES (6, 'Gilbert High', 6);
INSERT INTO school (id, name, city_id) VALUES (7, 'Sebastian River High School', 7);
INSERT INTO school (id, name, city_id) VALUES (9, 'ND QN Center', 9);
INSERT INTO school (id, name, city_id) VALUES (10, 'mbmbm', 10);
INSERT INTO school (id, name, city_id) VALUES (11, 'Florida Institute of Technology', 11);
INSERT INTO school (id, name, city_id) VALUES (12, 'DeVry University', 12);
INSERT INTO school (id, name, city_id) VALUES (13, 'Issaquah High School', 13);
INSERT INTO school (id, name, city_id) VALUES (14, 'Juanita High School', 14);
INSERT INTO school (id, name, city_id) VALUES (15, 'Liberty High School', 15);
INSERT INTO school (id, name, city_id) VALUES (16, 'Meadowdale', 16);
INSERT INTO school (id, name, city_id) VALUES (17, 'Monroe High School', 17);
INSERT INTO school (id, name, city_id) VALUES (18, 'Nathan Hale High School', 18);
INSERT INTO school (id, name, city_id) VALUES (19, 'Redmond High School', 19);
INSERT INTO school (id, name, city_id) VALUES (20, 'Roosevelt High School', 18);
INSERT INTO school (id, name, city_id) VALUES (21, 'Florida International University', 20);
INSERT INTO school (id, name, city_id) VALUES (22, 'University of Illinois at Chicago', 1);
INSERT INTO school (id, name, city_id) VALUES (23, 'Anderson High School', 21);
INSERT INTO school (id, name, city_id) VALUES (24, 'MJ Young and Associates', 22);
INSERT INTO school (id, name, city_id) VALUES (25, 'Glenbard', 2);
INSERT INTO school (id, name, city_id) VALUES (26, 'San Marcos', 2);
INSERT INTO school (id, name, city_id) VALUES (27, 'Proviso West', 23);
INSERT INTO school (id, name, city_id) VALUES (28, 'Potomac', 24);
INSERT INTO school (id, name, city_id) VALUES (29, 'Hampton University', 25);
INSERT INTO school (id, name, city_id) VALUES (30, 'LBNL', 26);
INSERT INTO school (id, name, city_id) VALUES (31, 'UT ARLINGTON', 27);
INSERT INTO school (id, name, city_id) VALUES (32, 'NORTHSIDE HS', 27);
INSERT INTO school (id, name, city_id) VALUES (33, 'Skyline High School', 28);
INSERT INTO school (id, name, city_id) VALUES (34, 'University of Nebraska', 29);
INSERT INTO school (id, name, city_id) VALUES (35, 'University of Puerto Rico', 30);
INSERT INTO school (id, name, city_id) VALUES (36, 'Glenbrook North High School', 31);
INSERT INTO school (id, name, city_id) VALUES (37, 'Garfield High School', 18);
INSERT INTO school (id, name, city_id) VALUES (8, 'Alan Shepard High School', 8);
INSERT INTO school (id, name, city_id) VALUES (38, 'Walter Payton College Prep', 1);
INSERT INTO school (id, name, city_id) VALUES (39, 'Marist HS', 1);
INSERT INTO school (id, name, city_id) VALUES (40, 'William Fremd High School', 32);
INSERT INTO school (id, name, city_id) VALUES (41, 'Gwendolyn Brooks College Prep', 1);
INSERT INTO school (id, name, city_id) VALUES (42, 'Piedmont High School', 33);
INSERT INTO school (id, name, city_id) VALUES (43, 'Mission san Jose High school', 34);
INSERT INTO school (id, name, city_id) VALUES (44, 'Castro Valley High School', 35);
INSERT INTO school (id, name, city_id) VALUES (45, 'Monte Vista High School', 36);
INSERT INTO school (id, name, city_id) VALUES (46, 'Acalanes High School', 37);
INSERT INTO school (id, name, city_id) VALUES (47, 'Sequim High School', 38);
INSERT INTO school (id, name, city_id) VALUES (48, 'Hubbard High School', 1);
INSERT INTO school (id, name, city_id) VALUES (49, 'York Community High School', 39);
INSERT INTO school (id, name, city_id) VALUES (50, 'Muleshoe High School', 40);
INSERT INTO school (id, name, city_id) VALUES (51, 'Henry Ford High School', 41);
INSERT INTO school (id, name, city_id) VALUES (52, 'Melbourne High School', 11);
INSERT INTO school (id, name, city_id) VALUES (53, 'Astronaut High School', 42);
INSERT INTO school (id, name, city_id) VALUES (54, 'Titusville High School', 42);
INSERT INTO school (id, name, city_id) VALUES (55, 'University of Washington', 18);
INSERT INTO school (id, name, city_id) VALUES (56, 'Lake Zurich High School', 43);
INSERT INTO school (id, name, city_id) VALUES (57, 'Rich South HS', 44);
INSERT INTO school (id, name, city_id) VALUES (58, 'Curie High School', 1);
INSERT INTO school (id, name, city_id) VALUES (59, 'PatsLab Fermilab', 2);
INSERT INTO school (id, name, city_id) VALUES (60, 'Romeoville High School', 45);
INSERT INTO school (id, name, city_id) VALUES (61, 'University of Mississippi', 46);
INSERT INTO school (id, name, city_id) VALUES (62, 'Mississippi School for Mathematics and Science', 47);
INSERT INTO school (id, name, city_id) VALUES (63, 'Kossuth Hiigh School', 48);
INSERT INTO school (id, name, city_id) VALUES (64, 'Columbus High School', 47);
INSERT INTO school (id, name, city_id) VALUES (65, 'Ridgeland High School', 49);
INSERT INTO school (id, name, city_id) VALUES (66, 'Grace Christian School', 50);
INSERT INTO school (id, name, city_id) VALUES (67, 'Saint Edwards School', 51);
INSERT INTO school (id, name, city_id) VALUES (68, 'satellite beach high school', 52);
INSERT INTO school (id, name, city_id) VALUES (69, 'Palm Bay High', 11);
INSERT INTO school (id, name, city_id) VALUES (70, 'Lakeshore High School', 53);
INSERT INTO school (id, name, city_id) VALUES (71, 'John Adams', 54);
INSERT INTO school (id, name, city_id) VALUES (72, 'Trinity School at Greenlawn', 54);
INSERT INTO school (id, name, city_id) VALUES (73, 'Saint Josephs High School', 54);
INSERT INTO school (id, name, city_id) VALUES (74, 'NDQC', 9);
INSERT INTO school (id, name, city_id) VALUES (75, 'Quarknet', 56);
INSERT INTO school (id, name, city_id) VALUES (76, 'Northside College Prep High School', 1);
INSERT INTO school (id, name, city_id) VALUES (77, 'Norfolk Academy', 57);
INSERT INTO school (id, name, city_id) VALUES (78, 'Garland High School', 58);
INSERT INTO school (id, name, city_id) VALUES (79, 'Huntington Beach High School', 59);
INSERT INTO school (id, name, city_id) VALUES (80, 'Kempner High School', 60);
INSERT INTO school (id, name, city_id) VALUES (81, 'Bush High School', 61);
INSERT INTO school (id, name, city_id) VALUES (82, 'Moorestown High School', 62);
INSERT INTO school (id, name, city_id) VALUES (83, 'Putnam City High School', 63);
INSERT INTO school (id, name, city_id) VALUES (84, 'East High', 64);
INSERT INTO school (id, name, city_id) VALUES (85, 'Boone High School', 65);
INSERT INTO school (id, name, city_id) VALUES (86, 'Macarthur High School', 66);
INSERT INTO school (id, name, city_id) VALUES (87, 'Belmont HS', 67);
INSERT INTO school (id, name, city_id) VALUES (88, 'Godwin High School', NULL);
INSERT INTO school (id, name, city_id) VALUES (89, 'Michigan State University', 68);
INSERT INTO school (id, name, city_id) VALUES (90, 'NDteachers', 9);
INSERT INTO school (id, name, city_id) VALUES (91, 'New Buffalo High School', 69);
INSERT INTO school (id, name, city_id) VALUES (92, 'LaLumiere', 70);
INSERT INTO school (id, name, city_id) VALUES (93, 'LaPorte High School', 70);
INSERT INTO school (id, name, city_id) VALUES (94, 'Penn High School', 55);
INSERT INTO school (id, name, city_id) VALUES (95, 'Elkhart Central High School', 71);
INSERT INTO school (id, name, city_id) VALUES (96, 'Bremen High School', 72);
INSERT INTO school (id, name, city_id) VALUES (97, 'Bethel College', 54);
INSERT INTO school (id, name, city_id) VALUES (98, 'kandert', 70);
INSERT INTO school (id, name, city_id) VALUES (99, 'Paso Robles High School', 73);
INSERT INTO school (id, name, city_id) VALUES (100, 'Boone-Apache High School', 74);
INSERT INTO school (id, name, city_id) VALUES (101, 'Sulphur High School', 75);
INSERT INTO school (id, name, city_id) VALUES (102, 'Union Public Schools', 76);
INSERT INTO school (id, name, city_id) VALUES (103, 'Landon School', 77);
INSERT INTO school (id, name, city_id) VALUES (104, 'Patterson High School', 78);
INSERT INTO school (id, name, city_id) VALUES (105, 'Parkville High Schoo', 78);
INSERT INTO school (id, name, city_id) VALUES (106, 'Parkville High School', 78);
INSERT INTO school (id, name, city_id) VALUES (107, 'Baltimore Polytechnic High School', 78);
INSERT INTO school (id, name, city_id) VALUES (108, 'St. Paul School for Girls', 79);
INSERT INTO school (id, name, city_id) VALUES (109, 'The Catholic High School of Baltimore', 78);
INSERT INTO school (id, name, city_id) VALUES (110, 'Johns Hopkins University', 78);
INSERT INTO school (id, name, city_id) VALUES (111, 'Perry Hall High School', 78);
INSERT INTO school (id, name, city_id) VALUES (112, 'Maryvale Prepratory School', 79);
INSERT INTO school (id, name, city_id) VALUES (113, 'Woodlawn High School', 78);
INSERT INTO school (id, name, city_id) VALUES (114, 'Jimtown High School', 71);
INSERT INTO school (id, name, city_id) VALUES (115, 'godwin', 25);
INSERT INTO school (id, name, city_id) VALUES (116, 'Centreville High School', 80);
INSERT INTO school (id, name, city_id) VALUES (117, 'South County Secondary School', 81);
INSERT INTO school (id, name, city_id) VALUES (118, 'West Springfield High School', 82);
INSERT INTO school (id, name, city_id) VALUES (119, 'Geneva High School', 83);
INSERT INTO school (id, name, city_id) VALUES (120, 'University of Utah', 84);
INSERT INTO school (id, name, city_id) VALUES (121, 'Richard Montgomery High School', 85);
INSERT INTO school (id, name, city_id) VALUES (122, 'RCPSD', 64);
INSERT INTO school (id, name, city_id) VALUES (123, 'RCSD', 64);
INSERT INTO school (id, name, city_id) VALUES (124, 'Roxbury Latin School', 86);
INSERT INTO school (id, name, city_id) VALUES (125, 'Basalt High School', 87);
INSERT INTO school (id, name, city_id) VALUES (126, 'Roaring Fork High School', 88);
INSERT INTO school (id, name, city_id) VALUES (127, 'Northeastern University', 89);
INSERT INTO school (id, name, city_id) VALUES (128, 'Needham High School', 90);
INSERT INTO school (id, name, city_id) VALUES (129, 'Swampscott High School', 91);
INSERT INTO school (id, name, city_id) VALUES (130, 'Gloucester High School', 92);
INSERT INTO school (id, name, city_id) VALUES (131, 'North Andover High School', 93);
INSERT INTO school (id, name, city_id) VALUES (132, 'Medford High School', 94);
INSERT INTO school (id, name, city_id) VALUES (133, 'QuarkNet Traveling Array', 95);
INSERT INTO school (id, name, city_id) VALUES (134, 'Caltech', 96);
INSERT INTO school (id, name, city_id) VALUES (135, 'Summit Country Day School', 97);
INSERT INTO school (id, name, city_id) VALUES (136, 'Eastwood High School ', 98);
INSERT INTO school (id, name, city_id) VALUES (137, 'IMSA', 99);
INSERT INTO school (id, name, city_id) VALUES (138, 'Florida Air Academy', 11);
INSERT INTO school (id, name, city_id) VALUES (139, 'Francis W. Parker', 1);
INSERT INTO school (id, name, city_id) VALUES (140, 'Francis W. Parker High School', 1);
INSERT INTO school (id, name, city_id) VALUES (141, 'SUNY New Paltz', 100);
INSERT INTO school (id, name, city_id) VALUES (142, 'Providence Academy', 102);
INSERT INTO school (id, name, city_id) VALUES (143, 'Aspen High School', 95);
INSERT INTO school (id, name, city_id) VALUES (144, 'L. D. Bell High School', 103);
INSERT INTO school (id, name, city_id) VALUES (145, 'Mayo High School', 104);
INSERT INTO school (id, name, city_id) VALUES (146, 'Government Science College', 105);
INSERT INTO school (id, name, city_id) VALUES (147, 'Federal Way Public Academy', 12);
INSERT INTO school (id, name, city_id) VALUES (148, 'Liberty High School', 2);
INSERT INTO school (id, name, city_id) VALUES (149, 'Fermilab Test Array', 2);
INSERT INTO school (id, name, city_id) VALUES (150, 'Carbondale Middle School', 88);
INSERT INTO school (id, name, city_id) VALUES (151, 'Glenwood Springs High School', 107);
INSERT INTO school (id, name, city_id) VALUES (152, 'Aspen Middle School', 95);
INSERT INTO school (id, name, city_id) VALUES (153, 'Wylie High School', 109);
INSERT INTO school (id, name, city_id) VALUES (154, 'Lake Highlands High School', 108);
INSERT INTO school (id, name, city_id) VALUES (155, 'Skyline Center', 108);
INSERT INTO school (id, name, city_id) VALUES (156, 'Sachse High School', 110);
INSERT INTO school (id, name, city_id) VALUES (157, 'Zion Lutheran', 108);
INSERT INTO school (id, name, city_id) VALUES (158, 'DeSoto High School', 111);
INSERT INTO school (id, name, city_id) VALUES (159, 'Molina High School', 108);
INSERT INTO school (id, name, city_id) VALUES (160, 'Village Fair Alternative Center', 108);
INSERT INTO school (id, name, city_id) VALUES (161, 'SMU', 108);
INSERT INTO school (id, name, city_id) VALUES (162, 'Cedar Hill High School', 113);
INSERT INTO school (id, name, city_id) VALUES (163, 'I H Kempner High School', 114);
INSERT INTO school (id, name, city_id) VALUES (164, 'Lexington High School', 115);
INSERT INTO school (id, name, city_id) VALUES (165, 'Bangalore Association for Science Education', 105);
INSERT INTO school (id, name, city_id) VALUES (166, 'Bettendorf High School', 116);
INSERT INTO school (id, name, city_id) VALUES (167, 'Dunbar Vocational Career Academy', 1);
INSERT INTO school (id, name, city_id) VALUES (168, 'Roseburg High School', 117);
INSERT INTO school (id, name, city_id) VALUES (169, 'South Eugene High School', 118);
INSERT INTO school (id, name, city_id) VALUES (170, 'Bend Senior HIgh School', 119);
INSERT INTO school (id, name, city_id) VALUES (171, 'Oregon Episcopal School', 120);
INSERT INTO school (id, name, city_id) VALUES (172, 'St. Marys Academy', 120);
INSERT INTO school (id, name, city_id) VALUES (173, 'Silverton High School', 121);
INSERT INTO school (id, name, city_id) VALUES (174, 'Cottage Grove High School', 122);
INSERT INTO school (id, name, city_id) VALUES (175, 'Burnaby North Secondary School', 123);
INSERT INTO school (id, name, city_id) VALUES (176, 'Benton Central High School', 124);
INSERT INTO school (id, name, city_id) VALUES (177, 'Cuesta College', 125);
INSERT INTO school (id, name, city_id) VALUES (178, 'Buffalo Grove High School', 126);
INSERT INTO school (id, name, city_id) VALUES (179, 'CERN', 127);
INSERT INTO school (id, name, city_id) VALUES (180, 'University of Wisconsin-River Falls', 128);
INSERT INTO school (id, name, city_id) VALUES (181, 'University of Colorado - Boulder', 129);
INSERT INTO school (id, name, city_id) VALUES (182, 'TRIUMF', 130);
INSERT INTO school (id, name, city_id) VALUES (183, 'TRIUMFworkshop', 131);
INSERT INTO school (id, name, city_id) VALUES (184, 'University of Hawaii-Manoa', 132);
INSERT INTO school (id, name, city_id) VALUES (185, 'University of Hawaii ', 133);

INSERT INTO teacher (id, name, email, school_id) VALUES (7, 'teacher', 'teacher@example.com', 4);


INSERT INTO research_group (id, name, "password", teacher_id, role, userarea, ay, survey, first_time) VALUES (11, 'guest', 'guest', 7, 'user', 'AY2008/IL/Chicago/UofC/guest/guest', 'AY2008', true, false);

INSERT INTO student (id, name) VALUES (5, 'guest');


INSERT INTO research_group_project (research_group_id, project_id) VALUES (11, 1);


INSERT INTO research_group_student (research_group_id, student_id) VALUES (11, 5);

INSERT INTO research_group_detectorid (research_group_id, detectorid) VALUES (11, 999);

INSERT INTO keyword (id, keyword, description, project_id, section, section_id, "type") VALUES (18, 'collect_upload_data', 'Notes on collecting and uploading data', 1, 'C', 10, 'S ');
INSERT INTO keyword (id, keyword, description, project_id, section, section_id, "type") VALUES (19, 'comment_poster', 'Notes on commenting posters', 1, 'D', 40, 'S ');
INSERT INTO keyword (id, keyword, description, project_id, section, section_id, "type") VALUES (34, 'detection_techniques', 'Notes on detection techniques', 1, 'B', 25, 'S ');
INSERT INTO keyword (id, keyword, description, project_id, section, section_id, "type") VALUES (35, 'analysis_iterations', 'Notes on changes between analysis runs', 1, 'C', 50, 'S ');
INSERT INTO keyword (id, keyword, description, project_id, section, section_id, "type") VALUES (36, 'classroom_insights', 'Notes on how to guide students', 1, 'C', 55, 'S ');
INSERT INTO keyword (id, keyword, description, project_id, section, section_id, "type") VALUES (37, 'detection_techniques', 'Notes on detection techniques', 1, 'B', 25, 'S ');
INSERT INTO keyword (id, keyword, description, project_id, section, section_id, "type") VALUES (38, 'analysis_iterations', 'Notes on changes between analysis runs', 1, 'C', 50, 'S ');
INSERT INTO keyword (id, keyword, description, project_id, section, section_id, "type") VALUES (39, 'classroom_insights', 'Notes on how to guide students', 1, 'C', 55, 'S ');
INSERT INTO keyword (id, keyword, description, project_id, section, section_id, "type") VALUES (21, 'cosmic_rays', 'Description of cosmic rays in simple terms.', 1, 'B', 10, 'SW');
INSERT INTO keyword (id, keyword, description, project_id, section, section_id, "type") VALUES (30, 'search_parameters', 'Notes on search parameters.', 1, 'C', 20, 'SW');
INSERT INTO keyword (id, keyword, description, project_id, section, section_id, "type") VALUES (17, 'analysis_tools', 'Notes on analysis tools to use', 1, 'C', 30, 'SW');
INSERT INTO keyword (id, keyword, description, project_id, section, section_id, "type") VALUES (23, 'data_error', 'Notes of data error and background', 1, 'C', 40, 'SW');
INSERT INTO keyword (id, keyword, description, project_id, section, section_id, "type") VALUES (24, 'defend_solution', 'Notes on our observations and research.', 1, 'D', 10, 'SW');
INSERT INTO keyword (id, keyword, description, project_id, section, section_id, "type") VALUES (22, 'create_poster', 'Notes on making a poster', 1, 'D', 20, 'SW');
INSERT INTO keyword (id, keyword, description, project_id, section, section_id, "type") VALUES (28, 'research_proposal', 'Our research proposal', 1, 'B', 40, 'SW');
INSERT INTO keyword (id, keyword, description, project_id, section, section_id, "type") VALUES (20, 'cosmic_ray_study', 'Notes on what you can study about cosmic rays.', 1, 'B', 20, 'SW');
INSERT INTO keyword (id, keyword, description, project_id, section, section_id, "type") VALUES (25, 'detector', 'Description of what the detector can do.', 1, 'B', 30, 'SW');
INSERT INTO keyword (id, keyword, description, project_id, section, section_id, "type") VALUES (26, 'general', 'General Notes', 1, 'A', 1, 'SW');
INSERT INTO keyword (id, keyword, description, project_id, section, section_id, "type") VALUES (27, 'research_plan', 'Our Research plan.', 1, 'A', 50, 'SW');
INSERT INTO keyword (id, keyword, description, project_id, section, section_id, "type") VALUES (29, 'research_question', 'Notes on developing a research question.', 1, 'A', 40, 'SW');
INSERT INTO keyword (id, keyword, description, project_id, section, section_id, "type") VALUES (31, 'simple_calculations', 'Notes on simple calculations', 1, 'A', 20, 'SW');
INSERT INTO keyword (id, keyword, description, project_id, section, section_id, "type") VALUES (32, 'simple_graphs', 'Notes on simple graphs', 1, 'A', 30, 'SW');
INSERT INTO keyword (id, keyword, description, project_id, section, section_id, "type") VALUES (33, 'simple_measurements', 'Notes on simple measurements', 1, 'A', 10, 'SW');
INSERT INTO keyword (id, keyword, description, project_id, section, section_id, "type") VALUES (40, 'detection_techniques', 'Notes on detection techniques', 1, 'B', 25, 'W ');
INSERT INTO keyword (id, keyword, description, project_id, section, section_id, "type") VALUES (41, 'analysis_iterations', 'Notes on changes between analysis runs', 1, 'C', 50, 'W ');
INSERT INTO keyword (id, keyword, description, project_id, section, section_id, "type") VALUES (42, 'classroom_insights', 'Notes on how to guide students', 1, 'C', 55, 'W ');


INSERT INTO test (id, date_entered) VALUES (1, '2004-11-30 13:41:11.410235');
INSERT INTO test (id, date_entered) VALUES (2, '2004-11-30 13:41:35.96234');


--
-- TOC entry 3 (OID 2265470)
-- Name: state_id_seq; Type: SEQUENCE SET; Schema: public; Owner: vds8085
--

SELECT pg_catalog.setval ('state_id_seq', 59, true);


--
-- TOC entry 5 (OID 2265473)
-- Name: city_id_seq; Type: SEQUENCE SET; Schema: public; Owner: vds8085
--

SELECT pg_catalog.setval ('city_id_seq', 133, true);


--
-- TOC entry 7 (OID 2265476)
-- Name: school_id_seq; Type: SEQUENCE SET; Schema: public; Owner: vds8085
--

SELECT pg_catalog.setval ('school_id_seq', 185, true);


--
-- TOC entry 9 (OID 2265483)
-- Name: teacher_id_seq; Type: SEQUENCE SET; Schema: public; Owner: vds8085
--

SELECT pg_catalog.setval ('teacher_id_seq', 251, true);


--
-- TOC entry 11 (OID 2265490)
-- Name: research_group_id_seq; Type: SEQUENCE SET; Schema: public; Owner: vds8085
--

SELECT pg_catalog.setval ('research_group_id_seq', 638, true);


--
-- TOC entry 13 (OID 2265500)
-- Name: student_id_seq; Type: SEQUENCE SET; Schema: public; Owner: vds8085
--

SELECT pg_catalog.setval ('student_id_seq', 711, true);


--
-- TOC entry 15 (OID 3563318)
-- Name: keyword_id_seq; Type: SEQUENCE SET; Schema: public; Owner: vds8085
--

SELECT pg_catalog.setval ('keyword_id_seq', 42, true);


--
-- TOC entry 17 (OID 3563346)
-- Name: log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: vds8085
--

SELECT pg_catalog.setval ('log_id_seq', 874, true);


--
-- TOC entry 19 (OID 3563373)
-- Name: comment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: vds8085
--

SELECT pg_catalog.setval ('comment_id_seq', 397, true);


--
-- TOC entry 21 (OID 3565432)
-- Name: keyword1_id_seq; Type: SEQUENCE SET; Schema: public; Owner: vds8085
--

SELECT pg_catalog.setval ('keyword1_id_seq', 63, true);


--
-- TOC entry 23 (OID 3575182)
-- Name: usage_id_seq; Type: SEQUENCE SET; Schema: public; Owner: vds8085
--

SELECT pg_catalog.setval ('usage_id_seq', 11805, true);


--
-- TOC entry 25 (OID 3736873)
-- Name: question_id_seq; Type: SEQUENCE SET; Schema: public; Owner: vds8085
--

SELECT pg_catalog.setval ('question_id_seq', 32, true);


