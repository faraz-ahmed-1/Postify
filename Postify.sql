CREATE DATABASE Postify;
USE Postify;

CREATE TABLE Users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100),
    bio TEXT,
    profile_pic VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
SELECT * FROM Users;
UPDATE Users
SET profile_pic = "/uploads/default.png";
SET SQL_SAFE_UPDATES = 0;

ALTER TABLE Users
ADD COLUMN profile_pic VARCHAR(225) DEFAULT '/uploads/default.png';

CREATE TABLE followers (
  id INT AUTO_INCREMENT PRIMARY KEY,
  follower_id INT NOT NULL,   -- who follows
  following_id INT NOT NULL,  -- who is being followed
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (follower_id) REFERENCES Users(user_id),
  FOREIGN KEY (following_id) REFERENCES Users(user_id)
);
SELECT * FROM followers;

CREATE TABLE posts (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(100) NOT NULL,
  content TEXT,
  image_url VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(user_id)
);
SELECT * FROM posts;
ALTER TABLE posts
-- ADD COLUMN user_id INT NOT NULL;
ADD CONSTRAINT fk_posts_user FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE;
DESCRIBE posts;
ALTER TABLE posts ADD COLUMN video_url VARCHAR(255) NULL AFTER image_url;
UPDATE posts SET image_url = NULL WHERE id = 5;
UPDATE posts p
JOIN Users u ON p.username = u.username
SET p.user_id = u.user_id;

ALTER TABLE posts
MODIFY user_id INT NOT NULL,
ADD CONSTRAINT fk_posts_user FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE;

-- Likes table
CREATE TABLE Likes (
  id INT AUTO_INCREMENT PRIMARY KEY,
  post_id INT NOT NULL,
  user_id INT NOT NULL,
  username VARCHAR(50) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY unique_like (post_id, user_id),
  FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

SELECT user_id, username FROM Users WHERE username = 'farazahmed';
SELECT id FROM Posts WHERE id = 15; -- replace with the postId you’re liking

SELECT * FROM Likes;
DELETE FROM Likes
WHERE username = 'farazahmed';
ALTER TABLE likes
MODIFY user_id INT NOT NULL,
ADD CONSTRAINT fk_like_user FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE;
DESCRIBE likes;
DROP TABLE likes;

DELETE FROM Likes;
ALTER TABLE likes
-- ADD COLUMN user_id INT NOT NULL;/
ADD CONSTRAINT fk_likes_user FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE;
SELECT * FROM likes;
SELECT user_id, username, email, password_hash FROM Users;

-- Comments table
CREATE TABLE comments (
  id INT AUTO_INCREMENT PRIMARY KEY,
  post_id INT NOT NULL,
  username VARCHAR(255) NOT NULL,
  comment TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE
);
SELECT * FROM comments;

CREATE TABLE stories (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) NOT NULL,
  media_url VARCHAR(255) NOT NULL,   -- image or video path
  media_type ENUM('image','video') NOT NULL,  -- detect type
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  expires_at TIMESTAMP NOT NULL,
  FOREIGN KEY (username) REFERENCES Users(username) ON DELETE CASCADE
);

SELECT * FROM stories;

DROP TABLE stories;

CREATE TABLE Notifications (
  id INT AUTO_INCREMENT PRIMARY KEY,
  sender_id INT NOT NULL,          -- who performed the action
  receiver_id INT NOT NULL,        -- who receives notification
  post_id INT NULL,                -- post/reel reference
  type ENUM('like','comment','follow') NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (sender_id) REFERENCES Users(user_id),
  FOREIGN KEY (receiver_id) REFERENCES Users(user_id),
  FOREIGN KEY (post_id) REFERENCES posts(id)
);
SELECT * FROM Notifications;
DELETE FROM followers;

ALTER TABLE Notifiations
DROP CONSTRAINT notifications_ibfk_3;

ALTER TABLE Notifications
ADD FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE ON UPDATE CASCADE;

SHOW CREATE TABLE Notifications;
CREATE TABLE Conversations (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user1_id INT NOT NULL,
  user2_id INT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  UNIQUE KEY unique_pair (user1_id, user2_id),
  FOREIGN KEY (user1_id) REFERENCES Users(user_id) ON DELETE CASCADE,
  FOREIGN KEY (user2_id) REFERENCES Users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB;
ALTER TABLE Conversations DROP CHECK chk_user_order;
SELECT * FROM Conversations;
DROP TABLE Conversations;
-- Store messages
CREATE TABLE Messages (
  id INT AUTO_INCREMENT PRIMARY KEY,
  sender_id INT NOT NULL,
  receiver_id INT NOT NULL,
  message TEXT,
  post_id INT, -- optional: reference to shared reel/post
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (sender_id) REFERENCES Users(user_id) ON DELETE CASCADE,
  FOREIGN KEY (receiver_id) REFERENCES Users(user_id) ON DELETE CASCADE,
  FOREIGN KEY (post_id) REFERENCES Posts(id) ON DELETE CASCADE
);

TRUNCATE TABLE Messages;

ALTER TABLE Messages 
-- ADD COLUMN conversation_id INT;
ADD FOREIGN KEY (conversation_id) REFERENCES Conversations(id) ON DELETE CASCADE;

ALTER TABLE Messages ADD COLUMN status ENUM('sent', 'delivered', 'seen') DEFAULT 'sent';


DROP TABLE Messages;
SHOW CREATE TABLE Messages;
SELECT * FROM Messages;


SELECT * FROM posts;
SELECT 
  m.id AS message_id,
  m.sender_id,
  m.receiver_id,
  m.message,
  m.post_id,
  m.created_at,
  m.status,
  p.image_url AS image_url,   -- keep separate
  p.video_url AS video_url,
  u.username AS sender_username,
  u.profile_pic AS sender_profile_pic
FROM Messages m
LEFT JOIN posts p ON m.post_id = p.id
LEFT JOIN Users u ON m.sender_id = u.user_id
WHERE m.conversation_id = 2 OR m.post_id =  p.id
ORDER BY m.created_at ASC;


SELECT 
  m.id AS message_id,
  m.sender_id,
  m.receiver_id,
  m.message,
  m.post_id,
  m.created_at,
  m.status,
  p.image_url AS image_url,   -- keep separate
  p.video_url AS video_url
FROM Messages m
LEFT JOIN posts p ON p.id = m.post_id
WHERE m.conversation_id = 2 OR m.post_id = p.id
ORDER BY m.created_at ASC;


SELECT * FROM Messages WHERE conversation_id = 2 OR post_id = 14;