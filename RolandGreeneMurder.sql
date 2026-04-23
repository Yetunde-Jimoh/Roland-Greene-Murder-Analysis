CREATE TABLE suspects (
	suspect_id INT Primary key,
	first_name VARCHAR(50) NOT NULL,
	last_name VARCHAR(50) NOT NULL,
	suspect_role VARCHAR(50) NOT NULL,
	relation_to_victim VARCHAR(50) NOT NULL,
	alibi VARCHAR(50) NOT NULL
);
DROP TABLE suspects CASCADE;
SELECT * FROM suspects;

DROP TABLE access_logs;

CREATE TABLE access_logs (
	log_id INT Primary key,
	suspect_id INT,
	access_date_time TIMESTAMP NOT NULL,
	access_time TIME NOT NULL,
	door_accessed VARCHAR (50) NOT NULL,
	success_flag VARCHAR (50) NOT NULL,
	FOREIGN KEY (suspect_id) REFERENCES suspects(suspect_id)
);

SELECT * FROM access_logs;

DROP TABLE call_records;

CREATE TABLE call_records(
	call_id INT Primary key,
	suspect_id INT,
	call_date_time TIMESTAMP NOT NULL,
	call_duration VARCHAR (50) NOT NULL,
	recipient_relation VARCHAR (50) NOT NULL,
	call_date DATE NOT NULL,
	call_time TIME NOT NULL,
	CallDurationInMin INT NOT NULL,
	FOREIGN KEY (suspect_id) REFERENCES suspects(suspect_id)
);

SELECT * FROM call_records;

CREATE TABLE forensic_events(
	event_date_time TIMESTAMP NOT NULL,
	event_description VARCHAR(50) NOT NULL,
	event_time TIME NOT NULL
);

SELECT * FROM forensic_events;

 -- who were in the vault room shortly before or after the murder time?--
SELECT s.suspect_id, s.first_name, s.last_name, s.suspect_role, s.relation_to_victim, a.access_time, a.door_accessed, a.success_flag, s.alibi
FROM access_logs a
LEFT JOIN suspects s
ON a.suspect_id = s.suspect_id
WHERE a.success_flag = 'TRUE'
AND a.door_accessed = 'Vault Room'
ORDER BY a.access_time
;
 --who entered the vault room before the shooting?--
SELECT s.suspect_id, s.first_name, s.last_name, s.relation_to_victim, a.access_time, a.door_accessed, a.success_flag, s.alibi
FROM access_logs a
LEFT JOIN suspects s
ON a.suspect_id = s.suspect_id
WHERE a.success_flag = 'TRUE'
AND a.door_accessed = 'Vault Room'
AND a.access_time <= '20:00:00';

--who entered the vault room after the shooting?--
SELECT s.suspect_id, s.first_name, s.last_name, s.relation_to_victim, a.access_time, a.door_accessed, a.success_flag, s.alibi
FROM access_logs a
LEFT JOIN suspects s
ON a.suspect_id = s.suspect_id
WHERE a.success_flag = 'TRUE'
AND a.door_accessed = 'Vault Room'
AND a.access_time >= '20:00:00';

--who called the victim between 7:50 to 8:00pm?--
SELECT c.suspect_id, s.first_name, s.last_name, s.suspect_role, s.relation_to_victim, c.call_time, c.call_duration, c.recipient_relation
FROM call_records c
JOIN suspects s ON c.suspect_id = s.suspect_id
WHERE call_time BETWEEN '19:50' AND '20:00'
AND recipient_relation = 'Victim';

SELECT * FROM forensic_events
ORDER BY event_time;

--other doors accessed by those that went near the vault room and time--
SELECT s.suspect_id, s.first_name, s.last_name,s.suspect_role, s.relation_to_victim, a.access_time, a.door_accessed, a.success_flag, s.alibi
FROM access_logs a
LEFT JOIN suspects s
ON a.suspect_id = s.suspect_id
WHERE s.suspect_id IN (
	SELECT suspect_id
	FROM access_logs
	WHERE door_accessed = 'Vault Room')
ORDER BY s.suspect_id, a.access_time
;

SELECT * FROM access_logs
WHERE suspect_id = 26;

--Doors accessed by the callers to the victim by 7:50 to 8pm--
SELECT s.suspect_id, s.first_name, s.last_name,s.suspect_role, c.call_time, c.call_duration, s.relation_to_victim, a.access_time, a.door_accessed, a.success_flag, s.alibi
FROM access_logs a
LEFT JOIN suspects s
ON a.suspect_id = s.suspect_id
JOIN call_records c
ON s.suspect_id = c.suspect_id
WHERE c.recipient_relation = 'Victim'
	AND c.call_time BETWEEN '19:50' AND '20:00'
ORDER BY s.suspect_id, a.access_time
;