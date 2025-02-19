CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,       -- 用户ID，自动增长，作为主键
    username VARCHAR(100) NOT NULL,          -- 用户名，不能为空
    password VARCHAR(255) NOT NULL           -- 密码，不能为空
);

-- 插入一些示例数据
INSERT INTO users (username, password) VALUES 
('john_doe', 'password123'),
('jane_smith', 'mypassword'),
('sam_wilson', 'securepassword');


