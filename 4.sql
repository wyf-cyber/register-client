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
SELECT department, doctor, detail, state, '2025-2-21' AS work_date FROM doctors1
UNION ALL
SELECT department, doctor, detail, state, '2025-2-22' AS work_date FROM doctors2
UNION ALL
SELECT department, doctor, detail, state, '2025-2-23' AS work_date FROM doctors3
UNION ALL
SELECT department, doctor, detail, state, '2025-2-24' AS work_date FROM doctors4
UNION ALL
SELECT department, doctor, detail, state, '2025-2-25' AS work_date FROM doctors5
UNION ALL
SELECT department, doctor, detail, state, '2025-2-26' AS work_date FROM doctors6
UNION ALL
SELECT department, doctor, detail, state, '2025-2-27' AS work_date FROM doctors7;

-- 验证数据是否合并成功
SELECT * FROM doctors;
