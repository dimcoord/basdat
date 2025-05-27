USE mysql;

CREATE USER 'user1'@'localhost'
IDENTIFIED BY '';

GRANT *
ON TweetCount.* 
TO 'user1'@'localhost';

USE TweetCount;

INSERT INTO User(username) VALUES(
  'user1'
);
