CREATE TABLE appointment (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,  
    department VARCHAR(255) NOT NULL,         
    doctor VARCHAR(255) NOT NULL,
    username VARCHAR(100) NOT NULL,          -- 用户名，长度限制为100字符 
    register_day VARCHAR(100) NOT NULL,      -- 用户挂号的日期，长度限制为100字符
    day VARCHAR(100) NOT NULL,
    time INT NOT NULL           
);
