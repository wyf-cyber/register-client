-- 创建合并后的表
CREATE TABLE doctors (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    department VARCHAR(255) NOT NULL,
    doctor VARCHAR(255) NOT NULL,
    detail TEXT,
    state INT NOT NULL,
    work_date DATE NOT NULL -- 时间属性，用于区分数据来源
);

-- 插入合并数据
INSERT INTO doctors (department, doctor, detail, state, work_date)
SELECT department, doctor, detail, state, '2025-6-6' AS work_date FROM doctors1
UNION ALL
SELECT department, doctor, detail, state, '2025-6-7' AS work_date FROM doctors2
UNION ALL
SELECT department, doctor, detail, state, '2025-6-8' AS work_date FROM doctors3
UNION ALL
SELECT department, doctor, detail, state, '2025-6-9' AS work_date FROM doctors4
UNION ALL
SELECT department, doctor, detail, state, '2025-6-10' AS work_date FROM doctors5
UNION ALL
SELECT department, doctor, detail, state, '2025-6-11' AS work_date FROM doctors6
UNION ALL
SELECT department, doctor, detail, state, '2025-6-12' AS work_date FROM doctors7;

-- 验证数据是否合并成功
SELECT * FROM doctors;
