USE mysql;

CREATE USER 'user1'@'localhost'
IDENTIFIED BY '';

GRANT *
ON TweetCount.* 
TO 'user1'@'localhost';
