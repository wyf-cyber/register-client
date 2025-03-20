CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,       -- 用户ID，自动增长，作为主键
    username VARCHAR(128) NOT NULL,          -- 用户名，不能为空
    password VARCHAR(512) NOT NULL,          -- 密码，不能为空
    email VARCHAR(128),                      -- 邮箱，可选
    role VARCHAR(128) NOT NULL               -- 角色，不能为空(admin or user)
);
-- 插入一些示例数据
INSERT INTO users (username, password, email, role) VALUES 
('wyf', '123456', '2022302111088@whu.edu.cn', 'admin');



