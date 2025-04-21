/*
 Navicat Premium Data Transfer

 Source Server         : LocalServer
 Source Server Type    : MySQL
 Source Server Version : 80037 (8.0.37)
 Source Host           : localhost:3306
 Source Schema         : test

 Target Server Type    : MySQL
 Target Server Version : 80037 (8.0.37)
 File Encoding         : 65001

 Date: 16/04/2025 19:28:57
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for appointment
-- ----------------------------
DROP TABLE IF EXISTS `appointment`;
CREATE TABLE `appointment`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `department` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `doctor` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `username` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `register_day` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `day` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `time` int NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of appointment
-- ----------------------------
INSERT INTO `appointment` VALUES (1, '皮肤科', '刘杰', 'whu', '2025-04-16', '2025-04-15', 1744793679);
INSERT INTO `appointment` VALUES (2, '儿科', '李涛', 'whu', '2025-04-16', '2025-04-15', 1744793951);

-- ----------------------------
-- Table structure for doctors
-- ----------------------------
DROP TABLE IF EXISTS `doctors`;
CREATE TABLE `doctors`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `department` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `doctor` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `detail` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `state` int NOT NULL,
  `work_date` date NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 129 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of doctors
-- ----------------------------
INSERT INTO `doctors` VALUES (1, '内科', '李华', '擅长治疗高血压和糖尿病等常见慢性病，关注慢性病患者的长期管理。', 5, '2025-04-11');
INSERT INTO `doctors` VALUES (2, '儿科', '张娜', '在儿童传染病和免疫接种方面具有丰富经验，尤其擅长处理小儿流感和肺炎。', 2, '2025-04-11');
INSERT INTO `doctors` VALUES (3, '外科', '刘建国', '资深外科专家，擅长急腹症手术和大肠肿瘤手术治疗。', 0, '2025-04-11');
INSERT INTO `doctors` VALUES (4, '眼科', '张旭', '眼科专家，擅长白内障手术和老年人眼科疾病的治疗。', 1, '2025-04-11');
INSERT INTO `doctors` VALUES (5, '皮肤科', '黄婷', '皮肤病专家，精通过敏性皮肤病和皮肤肿瘤的治疗。', 3, '2025-04-11');
INSERT INTO `doctors` VALUES (6, '内科', '李洪', '擅长高血压、冠心病、糖尿病等内科常见疾病的诊治。', 4, '2025-04-11');
INSERT INTO `doctors` VALUES (7, '儿科', '王芳', '专注于儿童心脏病、肺病的诊治，擅长新生儿护理。', 0, '2025-04-11');
INSERT INTO `doctors` VALUES (8, '外科', '赵强', '擅长消化系统外科手术，特别是胃肠道肿瘤的手术治疗。', 7, '2025-04-11');
INSERT INTO `doctors` VALUES (9, '眼科', '杨磊', '眼科专家，专注于视网膜疾病、青光眼的早期诊断与治疗。', 2, '2025-04-11');
INSERT INTO `doctors` VALUES (10, '皮肤科', '陈丽', '皮肤病专家，主要研究湿疹、银屑病等过敏性皮肤病。', 0, '2025-04-11');
INSERT INTO `doctors` VALUES (11, '内科', '王伟', '擅长诊治心血管疾病、糖尿病、呼吸系统疾病等。', 3, '2025-04-11');
INSERT INTO `doctors` VALUES (12, '儿科', '李涛', '专注于儿童生长发育、免疫接种、常见传染病的诊疗。', 1, '2025-04-11');
INSERT INTO `doctors` VALUES (13, '内科', '王华', '心血管内科专家，擅长高血压、心脏病及其并发症的管理。', 0, '2025-04-12');
INSERT INTO `doctors` VALUES (14, '儿科', '李俊', '儿童急性呼吸道感染的诊治专家，擅长治疗儿童哮喘和肺炎。', 4, '2025-04-12');
INSERT INTO `doctors` VALUES (15, '外科', '陈亮', '骨科专家，擅长关节置换手术和骨折修复。', 2, '2025-04-12');
INSERT INTO `doctors` VALUES (16, '眼科', '赵婷', '屈光手术专家，擅长近视激光治疗及眼底疾病的诊治。', 0, '2025-04-12');
INSERT INTO `doctors` VALUES (17, '皮肤科', '刘强', '皮肤科专家，专注于过敏性皮肤病的诊治。', 6, '2025-04-12');
INSERT INTO `doctors` VALUES (18, '内科', '郑刚', '擅长内科慢性病管理，如糖尿病、慢性支气管炎等疾病。', 0, '2025-04-12');
INSERT INTO `doctors` VALUES (19, '儿科', '朱琳', '从事儿童神经疾病的研究，擅长癫痫和脑瘫的治疗。', 1, '2025-04-12');
INSERT INTO `doctors` VALUES (20, '外科', '李超', '擅长微创手术，尤其是在甲状腺和乳腺疾病方面有丰富经验。', 3, '2025-04-12');
INSERT INTO `doctors` VALUES (21, '眼科', '周波', '擅长视力矫正，特别是在青少年近视方面有深厚的研究。', 2, '2025-04-12');
INSERT INTO `doctors` VALUES (22, '皮肤科', '赵丽', '皮肤美容专家，擅长治疗皮肤病和提供皮肤美容服务。', 0, '2025-04-12');
INSERT INTO `doctors` VALUES (23, '内科', '高强', '专注于呼吸疾病的治疗，尤其是哮喘和肺气肿的诊治。', 4, '2025-04-12');
INSERT INTO `doctors` VALUES (24, '儿科', '王林', '专注于儿童免疫学，尤其是疫苗接种与传染病的预防。', 3, '2025-04-12');
INSERT INTO `doctors` VALUES (25, '内科', '孙杰', '对内科疑难杂症的治疗有深厚的经验，擅长处理肺部疾病。', 2, '2025-04-13');
INSERT INTO `doctors` VALUES (26, '儿科', '周波', '专长儿童体检与疾病预防，擅长儿童免疫接种和常见传染病的治疗。', 1, '2025-04-13');
INSERT INTO `doctors` VALUES (27, '外科', '王春', '腹腔镜手术专家，擅长肝胆胰外科手术。', 0, '2025-04-13');
INSERT INTO `doctors` VALUES (28, '眼科', '林志强', '近视激光矫正专家，擅长眼科激光治疗和白内障手术。', 3, '2025-04-13');
INSERT INTO `doctors` VALUES (29, '皮肤科', '张芳', '擅长皮肤病治疗，尤其在湿疹和痤疮治疗方面具有丰富经验。', 0, '2025-04-13');
INSERT INTO `doctors` VALUES (30, '内科', '刘江', '心内科专家，擅长诊治心肌梗塞和心力衰竭等疾病。', 3, '2025-04-13');
INSERT INTO `doctors` VALUES (31, '儿科', '黄颖', '专注于儿童生长发育及常见儿童疾病的治疗。', 4, '2025-04-13');
INSERT INTO `doctors` VALUES (32, '外科', '赵琳', '外科专家，尤其擅长胃肠道手术和消化道肿瘤的治疗。', 1, '2025-04-13');
INSERT INTO `doctors` VALUES (33, '眼科', '周丽', '专注于眼底疾病，擅长糖尿病视网膜病变的诊治。', 0, '2025-04-13');
INSERT INTO `doctors` VALUES (34, '皮肤科', '吴丽', '擅长诊治皮肤过敏，特别是在皮肤激光治疗方面有丰富经验。', 5, '2025-04-13');
INSERT INTO `doctors` VALUES (35, '内科', '田刚', '内科疾病，特别是呼吸系统疾病的诊治专家。', 0, '2025-04-13');
INSERT INTO `doctors` VALUES (36, '儿科', '张丽', '儿童营养专家，擅长小儿营养与疾病预防。', 2, '2025-04-13');
INSERT INTO `doctors` VALUES (37, '内科', '杨青', '肾脏病专家，擅长治疗慢性肾脏病及肾透析的管理。', 1, '2025-04-15');
INSERT INTO `doctors` VALUES (38, '儿科', '高鑫', '在儿童发育和成长方面有深入研究，擅长婴儿体重管理。', 2, '2025-04-14');
INSERT INTO `doctors` VALUES (39, '外科', '邱峰', '胸外科专家，擅长肺癌和食道癌的手术治疗。', 3, '2025-04-14');
INSERT INTO `doctors` VALUES (40, '眼科', '孙悦', '致力于近视、白内障及眼底病的临床诊治与手术。', 4, '2025-04-14');
INSERT INTO `doctors` VALUES (41, '皮肤科', '黄志强', '专注皮肤病学，擅长银屑病、白癜风等治疗。', 0, '2025-04-14');
INSERT INTO `doctors` VALUES (42, '内科', '邓亮', '精通心脏病的诊治，擅长冠状动脉支架置入术。', 3, '2025-04-14');
INSERT INTO `doctors` VALUES (43, '儿科', '李凯', '专注于小儿呼吸系统疾病的诊断与治疗。', 1, '2025-04-14');
INSERT INTO `doctors` VALUES (44, '外科', '郑伟', '在脊柱和关节手术方面有丰富经验，擅长骨折修复。', 2, '2025-04-14');
INSERT INTO `doctors` VALUES (45, '眼科', '刘伟', '擅长白内障和青光眼手术，及视网膜疾病的诊治。', 3, '2025-04-14');
INSERT INTO `doctors` VALUES (46, '皮肤科', '李婷', '皮肤病专家，擅长激光治疗各种皮肤病。', 1, '2025-04-14');
INSERT INTO `doctors` VALUES (47, '内科', '蒋涛', '内科专家，擅长处理糖尿病、高血压等常见内科病。', 0, '2025-04-14');
INSERT INTO `doctors` VALUES (48, '儿科', '王杰', '擅长儿童免疫学，尤其是预防接种和过敏性疾病。', 4, '2025-04-14');
INSERT INTO `doctors` VALUES (49, '内科', '王婷', '擅长处理糖尿病、脂肪肝等代谢性疾病的治疗和管理。', 4, '2025-04-15');
INSERT INTO `doctors` VALUES (50, '儿科', '张博', '在儿童心理健康和行为问题的处理方面有丰富经验。', 1, '2025-04-15');
INSERT INTO `doctors` VALUES (51, '外科', '赵峰', '外科手术专家，擅长腹部手术及胆囊切除手术。', 2, '2025-04-15');
INSERT INTO `doctors` VALUES (52, '眼科', '黄晓明', '专注于视网膜疾病的诊治，擅长糖尿病视网膜病变的治疗。', 1, '2025-04-15');
INSERT INTO `doctors` VALUES (53, '皮肤科', '陈波', '皮肤科专家，尤其擅长痤疮和激光脱毛。', 3, '2025-04-15');
INSERT INTO `doctors` VALUES (54, '内科', '贾磊', '心血管内科专家，擅长高血压、冠心病的诊治。', 1, '2025-04-15');
INSERT INTO `doctors` VALUES (55, '儿科', '李飞', '专注于小儿生长发育和常见疾病的预防与治疗。', 2, '2025-04-15');
INSERT INTO `doctors` VALUES (56, '外科', '黄珊', '外科手术专家，尤其擅长妇科手术和乳腺癌治疗。', 3, '2025-04-15');
INSERT INTO `doctors` VALUES (57, '眼科', '唐敏', '青光眼专家，擅长眼科手术和眼病的早期诊断。', 2, '2025-04-15');
INSERT INTO `doctors` VALUES (58, '皮肤科', '刘杰', '皮肤病专家，擅长治疗湿疹、皮肤瘙痒等常见问题。', 1, '2025-04-15');
INSERT INTO `doctors` VALUES (59, '内科', '吴志', '老年病专家，擅长治疗各种老年慢性病。', 4, '2025-04-15');
INSERT INTO `doctors` VALUES (60, '儿科', '李涛', '专注于儿童胃肠病和呼吸系统疾病。', 1, '2025-04-15');
INSERT INTO `doctors` VALUES (61, '内科', '何亮', '内科专家，擅长呼吸系统疾病的诊治，尤其是哮喘和COPD的管理。', 1, '2025-04-16');
INSERT INTO `doctors` VALUES (62, '儿科', '李磊', '儿童免疫学专家，擅长管理儿童的疫苗接种与预防接种。', 1, '2025-04-16');
INSERT INTO `doctors` VALUES (63, '外科', '程宇', '胃肠外科专家，擅长消化道肿瘤的外科手术治疗。', 5, '2025-04-16');
INSERT INTO `doctors` VALUES (64, '眼科', '邓子豪', '擅长青光眼、视网膜脱落的诊断与治疗。', 3, '2025-04-16');
INSERT INTO `doctors` VALUES (65, '皮肤科', '吴敏', '专注于过敏性皮肤病，尤其擅长荨麻疹和湿疹的治疗。', 2, '2025-04-16');
INSERT INTO `doctors` VALUES (66, '内科', '唐涛', '专注于肾脏病和糖尿病管理。', 2, '2025-04-16');
INSERT INTO `doctors` VALUES (67, '儿科', '刘英', '擅长儿童神经系统疾病，尤其是癫痫。', 1, '2025-04-16');
INSERT INTO `doctors` VALUES (68, '外科', '沈波', '擅长泌尿系统手术和妇科手术。', 1, '2025-04-16');
INSERT INTO `doctors` VALUES (69, '眼科', '蒋晓', '眼科专家，专注于眼睛的屈光手术和常见眼病治疗。', 4, '2025-04-16');
INSERT INTO `doctors` VALUES (70, '皮肤科', '任敏', '皮肤美容专家，专注治疗各种皮肤问题，如痤疮和皮肤过敏。', 1, '2025-04-16');
INSERT INTO `doctors` VALUES (71, '内科', '赵倩', '专注于心血管疾病和呼吸系统疾病的治疗。', 3, '2025-04-16');
INSERT INTO `doctors` VALUES (72, '儿科', '陈波', '擅长小儿哮喘、过敏性疾病的诊治。', 0, '2025-04-16');
INSERT INTO `doctors` VALUES (73, '内科', '蒋勇', '精通各类呼吸系统疾病的诊疗，尤其是支气管炎和肺气肿。', 1, '2025-04-17');
INSERT INTO `doctors` VALUES (74, '儿科', '何雅', '儿童神经科专家，擅长癫痫和脑性麻痹的治疗。', 0, '2025-04-17');
INSERT INTO `doctors` VALUES (75, '外科', '郑丽', '擅长各类创伤手术及骨科修复手术。', 3, '2025-04-17');
INSERT INTO `doctors` VALUES (76, '眼科', '徐涛', '眼科专家，擅长眼科疾病的早期诊断与综合治疗。', 2, '2025-04-17');
INSERT INTO `doctors` VALUES (77, '皮肤科', '曹俊', '擅长治疗银屑病、湿疹等常见皮肤病，尤其注重个体化治疗。', 4, '2025-04-17');
INSERT INTO `doctors` VALUES (78, '内科', '蔡晨', '肾脏内科专家，擅长慢性肾病及透析治疗。', 0, '2025-04-17');
INSERT INTO `doctors` VALUES (79, '儿科', '李馨', '专注儿童呼吸道疾病，尤其擅长哮喘治疗。', 1, '2025-04-17');
INSERT INTO `doctors` VALUES (80, '外科', '赵萍', '擅长脊柱手术及关节置换手术。', 2, '2025-04-17');
INSERT INTO `doctors` VALUES (81, '眼科', '孙燕', '专长视网膜疾病，尤其是黄斑病变的治疗。', 3, '2025-04-17');
INSERT INTO `doctors` VALUES (82, '皮肤科', '王思', '皮肤科专家，主要研究湿疹、银屑病等皮肤病。', 5, '2025-04-17');
INSERT INTO `doctors` VALUES (83, '内科', '王静', '心脏病专家，专长冠心病、高血压的诊治。', 2, '2025-04-17');
INSERT INTO `doctors` VALUES (84, '儿科', '吴浩', '专注儿童消化系统疾病的治疗，擅长处理小儿肠胃病。', 1, '2025-04-17');

DROP TABLE IF EXISTS `comments`;
CREATE TABLE `comments` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `doctor` VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `content` TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `rating` INT NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

INSERT INTO `comments` (`doctor`, `content`, `rating`) VALUES
('李华', '李华医生非常专业，对高血压和糖尿病的治疗很有经验，让我感觉很安心。', 5),
('张娜', '张娜医生对儿童传染病的处理非常专业，孩子生病找她很放心。', 4),
('刘建国', '刘建国医生是资深外科专家，手术做得很好，术后恢复也很快。', 5),
('张旭', '张旭医生对白内障手术很熟练，术后视力恢复很好。', 4),
('黄婷', '黄婷医生对皮肤病的治疗很有经验，尤其是湿疹和银屑病。', 3),
('李洪', '李洪医生对高血压、冠心病的治疗很有经验，解释得很清楚。', 5),
('王芳', '王芳医生对儿童心脏病的治疗很有经验，孩子在她这里治疗很放心。', 4),
('赵强', '赵强医生对胃肠道肿瘤的手术治疗很有经验，手术很成功。', 5),
('杨磊', '杨磊医生对视网膜疾病和青光眼的治疗很有经验，检查很仔细。', 4),
('陈丽', '陈丽医生对湿疹和银屑病的治疗很有经验，药方很有效。', 3),
('王伟', '王伟医生对心血管疾病和糖尿病的治疗很有经验，很受患者欢迎。', 5),
('李涛', '李涛医生对儿童生长发育和常见传染病的治疗很有经验，很受家长好评。', 4),
('王华', '王华医生对高血压和心脏病的管理很有经验，治疗效果很好。', 5),
('李俊', '李俊医生对儿童哮喘和肺炎的治疗很有经验，孩子恢复得很好。', 4),
('陈亮', '陈亮医生对关节置换手术和骨折修复很有经验，手术很成功。', 5),
('赵婷', '赵婷医生对近视激光治疗和眼底疾病的诊治很有经验，技术很熟练。', 4),
('刘强', '刘强医生对过敏性皮肤病的诊治很有经验，治疗效果很好。', 5),
('郑刚', '郑刚医生对内科慢性病的管理很有经验，治疗很有效。', 4),
('朱琳', '朱琳医生对儿童神经疾病的治疗很有经验，尤其是癫痫和脑瘫。', 3),
('李超', '李超医生对微创手术很有经验，甲状腺和乳腺疾病治疗效果很好。', 5),
('周波', '周波医生对视力矫正和青少年近视的研究很深，治疗很有效。', 4),
('赵丽', '赵丽医生对皮肤病和皮肤美容服务很有经验，治疗效果很好。', 3),
('高强', '高强医生对呼吸疾病的治疗很有经验，尤其是哮喘和肺气肿。', 5),
('王林', '王林医生对儿童免疫学和传染病预防很有经验，很受家长好评。', 4),
('孙杰', '孙杰医生对内科疑难杂症的治疗很有经验，尤其是肺部疾病。', 5),
('周波', '周波医生对儿童体检和常见传染病的治疗很有经验，很受家长好评。', 4),
('王春', '王春医生对腹腔镜手术和肝胆胰外科手术很有经验，手术很成功。', 5),
('林志强', '林志强医生对近视激光矫正和白内障手术很有经验，技术很熟练。', 4),
('张芳', '张芳医生对皮肤病的治疗很有经验，尤其是湿疹和痤疮。', 3),
('刘江', '刘江医生对心肌梗塞和心力衰竭的治疗很有经验，很受患者好评。', 5),
('黄颖', '黄颖医生对儿童生长发育和常见儿童疾病的治疗很有经验，很受家长好评。', 4),
('赵琳', '赵琳医生对胃肠道手术和消化道肿瘤的治疗很有经验，手术很成功。', 5),
('周丽', '周丽医生对眼底疾病和糖尿病视网膜病变的诊治很有经验，治疗效果很好。', 4),
('吴丽', '吴丽医生对皮肤过敏和皮肤激光治疗很有经验，治疗效果很好。', 5),
('田刚', '田刚医生对呼吸系统疾病的诊治很有经验，很受患者好评。', 4),
('张丽', '张丽医生对儿童营养和疾病预防很有经验，很受家长好评。', 3),
('杨青', '杨青医生对肾脏病和肾透析的管理很有经验，治疗效果很好。', 5),
('高鑫', '高鑫医生对儿童发育和成长的研究很深，擅长婴儿体重管理。', 4),
('邱峰', '邱峰医生对肺癌和食道癌的手术治疗很有经验，手术很成功。', 5),
('孙悦', '孙悦医生对近视、白内障及眼底病的临床诊治和手术很有经验，技术很熟练。', 4),
('黄志强', '黄志强医生对银屑病和白癜风的治疗很有经验，治疗效果很好。', 3),
('邓亮', '邓亮医生对心脏病的诊治和冠状动脉支架置入术很有经验，治疗效果很好。', 5),
('李凯', '李凯医生对小儿呼吸系统疾病的诊断和治疗很有经验，很受家长好评。', 4),
('郑伟', '郑伟医生对脊柱和关节手术很有经验，骨折修复效果很好。', 5),
('刘伟', '刘伟医生对白内障和青光眼手术及视网膜疾病的诊治很有经验，技术很熟练。', 4),
('李婷', '李婷医生对皮肤病和皮肤激光治疗很有经验，治疗效果很好。', 3),
('蒋涛', '蒋涛医生对糖尿病和高血压等常见内科病的治疗很有经验，很受患者好评。', 5),
('王杰', '王杰医生对儿童免疫学和过敏性疾病的治疗很有经验，很受家长好评。', 4),
('王婷', '王婷医生对糖尿病和脂肪肝等代谢性疾病的治疗和管理很有经验，治疗效果很好。', 5),
('张博', '张博医生对儿童心理健康和行为问题的处理很有经验，很受家长好评。', 4),
('赵峰', '赵峰医生对腹部手术和胆囊切除手术很有经验，手术很成功。', 5),
('黄晓明', '黄晓明医生对视网膜疾病的诊治和糖尿病视网膜病变的治疗很有经验，技术很熟练。', 4),
('陈波', '陈波医生对痤疮和激光脱毛的治疗很有经验，治疗效果很好。', 3),
('贾磊', '贾磊医生对高血压和冠心病的诊治很有经验，很受患者好评。', 5),
('李飞', '李飞医生对小儿生长发育和常见疾病的预防与治疗很有经验，很受家长好评。', 4),
('黄珊', '黄珊医生对妇科手术和乳腺癌治疗很有经验，手术很成功。', 5),
('唐敏', '唐敏医生对青光眼和眼科手术很有经验，治疗效果很好。', 4),
('刘杰', '刘杰医生对湿疹和皮肤瘙痒等常见问题的治疗很有经验，治疗效果很好。', 3),
('吴志', '吴志医生对老年慢性病的治疗很有经验，很受患者好评。', 5),
('李涛', '李涛医生对儿童胃肠病和呼吸系统疾病的治疗很有经验，很受家长好评。', 4),
('何亮', '何亮医生对呼吸系统疾病的诊治和哮喘、COPD的管理很有经验，治疗效果很好。', 5),
('李磊', '李磊医生对儿童疫苗接种和预防接种的管理很有经验，很受家长好评。', 4),
('程宇', '程宇医生对胃肠外科手术和消化道肿瘤的治疗很有经验，手术很成功。', 5),
('邓子豪', '邓子豪医生对青光眼和视网膜脱落的诊断与治疗很有经验，技术很熟练。', 4),
('吴敏', '吴敏医生对过敏性皮肤病和荨麻疹、湿疹的治疗很有经验，治疗效果很好。', 3),
('唐涛', '唐涛医生对肾脏病和糖尿病的管理很有经验，治疗效果很好。', 5),
('刘英', '刘英医生对儿童神经系统疾病和癫痫的治疗很有经验，很受家长好评。', 4),
('沈波', '沈波医生对泌尿系统手术和妇科手术很有经验，手术很成功。', 5),
('蒋晓', '蒋晓医生对眼睛的屈光手术和常见眼病的治疗很有经验，技术很熟练。', 4),
('任敏', '任敏医生对皮肤美容和痤疮、皮肤过敏的治疗很有经验，治疗效果很好。', 3),
('赵倩', '赵倩医生对心血管疾病和呼吸系统疾病的治疗很有经验，很受患者好评。', 5),
('陈波', '陈波医生对小儿哮喘和过敏性疾病的诊治很有经验，很受家长好评。', 4),
('蒋勇', '蒋勇医生对呼吸系统疾病的诊疗和支气管炎、肺气肿的管理很有经验，治疗效果很好。', 5),
('何雅', '何雅医生对儿童神经疾病和癫痫、脑性麻痹的治疗很有经验，很受家长好评。', 4),
('郑丽', '郑丽医生对创伤手术和骨科修复手术很有经验，手术很成功。', 5),
('徐涛', '徐涛医生对眼科疾病的早期诊断和综合治疗很有经验，技术很熟练。', 4),
('曹俊', '曹俊医生对银屑病和湿疹的治疗很有经验，注重个体化治疗，效果很好。', 5),
('蔡晨', '蔡晨医生对慢性肾病和透析治疗很有经验，治疗效果很好。', 4),
('李馨', '李馨医生对儿童呼吸道疾病和哮喘的治疗很有经验，很受家长好评。', 5),
('赵萍', '赵萍医生对脊柱手术和关节置换手术很有经验，手术很成功。', 4),
('孙燕', '孙燕医生对视网膜疾病和黄斑病变的治疗很有经验，技术很熟练。', 5),
('王思', '王思医生对湿疹和银屑病的治疗很有经验，治疗效果很好。', 4),
('王静', '王静医生对心脏病和冠心病、高血压的诊治很有经验，很受患者好评。', 5),
('吴浩', '吴浩医生对儿童消化系统疾病的治疗很有经验，擅长处理小儿肠胃病。', 4);





-- ----------------------------
-- Table structure for doctors1
-- ----------------------------
DROP TABLE IF EXISTS `doctors1`;
CREATE TABLE `doctors1`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `department` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `doctor` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `detail` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `state` int NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 13 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of doctors1
-- ----------------------------
INSERT INTO `doctors1` VALUES (1, '内科', '李明', '擅长治疗高血压和糖尿病等常见慢性病，关注慢性病患者的长期管理。', 5);
INSERT INTO `doctors1` VALUES (2, '儿科', '张娜', '在儿童传染病和免疫接种方面具有丰富经验，尤其擅长处理小儿流感和肺炎。', 2);
INSERT INTO `doctors1` VALUES (3, '外科', '刘建国', '资深外科专家，擅长急腹症手术和大肠肿瘤手术治疗。', 0);
INSERT INTO `doctors1` VALUES (4, '眼科', '张旭', '眼科专家，擅长白内障手术和老年人眼科疾病的治疗。', 1);
INSERT INTO `doctors1` VALUES (5, '皮肤科', '黄婷', '皮肤病专家，精通过敏性皮肤病和皮肤肿瘤的治疗。', 3);
INSERT INTO `doctors1` VALUES (6, '内科', '李洪', '擅长高血压、冠心病、糖尿病等内科常见疾病的诊治。', 4);
INSERT INTO `doctors1` VALUES (7, '儿科', '王芳', '专注于儿童心脏病、肺病的诊治，擅长新生儿护理。', 0);
INSERT INTO `doctors1` VALUES (8, '外科', '赵强', '擅长消化系统外科手术，特别是胃肠道肿瘤的手术治疗。', 7);
INSERT INTO `doctors1` VALUES (9, '眼科', '杨磊', '眼科专家，专注于视网膜疾病、青光眼的早期诊断与治疗。', 2);
INSERT INTO `doctors1` VALUES (10, '皮肤科', '陈丽', '皮肤病专家，主要研究湿疹、银屑病等过敏性皮肤病。', 0);
INSERT INTO `doctors1` VALUES (11, '内科', '王伟', '擅长诊治心血管疾病、糖尿病、呼吸系统疾病等。', 3);
INSERT INTO `doctors1` VALUES (12, '儿科', '李涛', '专注于儿童生长发育、免疫接种、常见传染病的诊疗。', 1);

-- ----------------------------
-- Table structure for doctors2
-- ----------------------------
DROP TABLE IF EXISTS `doctors2`;
CREATE TABLE `doctors2`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `department` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `doctor` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `detail` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `state` int NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 13 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of doctors2
-- ----------------------------
INSERT INTO `doctors2` VALUES (1, '内科', '王华', '心血管内科专家，擅长高血压、心脏病及其并发症的管理。', 0);
INSERT INTO `doctors2` VALUES (2, '儿科', '李俊', '儿童急性呼吸道感染的诊治专家，擅长治疗儿童哮喘和肺炎。', 4);
INSERT INTO `doctors2` VALUES (3, '外科', '陈亮', '骨科专家，擅长关节置换手术和骨折修复。', 2);
INSERT INTO `doctors2` VALUES (4, '眼科', '赵婷', '屈光手术专家，擅长近视激光治疗及眼底疾病的诊治。', 0);
INSERT INTO `doctors2` VALUES (5, '皮肤科', '刘强', '皮肤科专家，专注于过敏性皮肤病的诊治。', 6);
INSERT INTO `doctors2` VALUES (6, '内科', '郑刚', '擅长内科慢性病管理，如糖尿病、慢性支气管炎等疾病。', 0);
INSERT INTO `doctors2` VALUES (7, '儿科', '朱琳', '从事儿童神经疾病的研究，擅长癫痫和脑瘫的治疗。', 1);
INSERT INTO `doctors2` VALUES (8, '外科', '李超', '擅长微创手术，尤其是在甲状腺和乳腺疾病方面有丰富经验。', 3);
INSERT INTO `doctors2` VALUES (9, '眼科', '周波', '擅长视力矫正，特别是在青少年近视方面有深厚的研究。', 2);
INSERT INTO `doctors2` VALUES (10, '皮肤科', '赵丽', '皮肤美容专家，擅长治疗皮肤病和提供皮肤美容服务。', 0);
INSERT INTO `doctors2` VALUES (11, '内科', '高强', '专注于呼吸疾病的治疗，尤其是哮喘和肺气肿的诊治。', 4);
INSERT INTO `doctors2` VALUES (12, '儿科', '王林', '专注于儿童免疫学，尤其是疫苗接种与传染病的预防。', 3);

-- ----------------------------
-- Table structure for doctors3
-- ----------------------------
DROP TABLE IF EXISTS `doctors3`;
CREATE TABLE `doctors3`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `department` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `doctor` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `detail` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `state` int NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 13 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of doctors3
-- ----------------------------
INSERT INTO `doctors3` VALUES (1, '内科', '孙杰', '对内科疑难杂症的治疗有深厚的经验，擅长处理肺部疾病。', 2);
INSERT INTO `doctors3` VALUES (2, '儿科', '周波', '专长儿童体检与疾病预防，擅长儿童免疫接种和常见传染病的治疗。', 1);
INSERT INTO `doctors3` VALUES (3, '外科', '王春', '腹腔镜手术专家，擅长肝胆胰外科手术。', 0);
INSERT INTO `doctors3` VALUES (4, '眼科', '林志强', '近视激光矫正专家，擅长眼科激光治疗和白内障手术。', 3);
INSERT INTO `doctors3` VALUES (5, '皮肤科', '张芳', '擅长皮肤病治疗，尤其在湿疹和痤疮治疗方面具有丰富经验。', 0);
INSERT INTO `doctors3` VALUES (6, '内科', '刘江', '心内科专家，擅长诊治心肌梗塞和心力衰竭等疾病。', 3);
INSERT INTO `doctors3` VALUES (7, '儿科', '黄颖', '专注于儿童生长发育及常见儿童疾病的治疗。', 4);
INSERT INTO `doctors3` VALUES (8, '外科', '赵琳', '外科专家，尤其擅长胃肠道手术和消化道肿瘤的治疗。', 1);
INSERT INTO `doctors3` VALUES (9, '眼科', '周丽', '专注于眼底疾病，擅长糖尿病视网膜病变的诊治。', 0);
INSERT INTO `doctors3` VALUES (10, '皮肤科', '吴丽', '擅长诊治皮肤过敏，特别是在皮肤激光治疗方面有丰富经验。', 5);
INSERT INTO `doctors3` VALUES (11, '内科', '田刚', '内科疾病，特别是呼吸系统疾病的诊治专家。', 0);
INSERT INTO `doctors3` VALUES (12, '儿科', '张丽', '儿童营养专家，擅长小儿营养与疾病预防。', 2);

-- ----------------------------
-- Table structure for doctors4
-- ----------------------------
DROP TABLE IF EXISTS `doctors4`;
CREATE TABLE `doctors4`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `department` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `doctor` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `detail` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `state` int NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 13 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of doctors4
-- ----------------------------
INSERT INTO `doctors4` VALUES (1, '内科', '杨青', '肾脏病专家，擅长治疗慢性肾脏病及肾透析的管理。', 1);
INSERT INTO `doctors4` VALUES (2, '儿科', '高鑫', '在儿童发育和成长方面有深入研究，擅长婴儿体重管理。', 2);
INSERT INTO `doctors4` VALUES (3, '外科', '邱峰', '胸外科专家，擅长肺癌和食道癌的手术治疗。', 3);
INSERT INTO `doctors4` VALUES (4, '眼科', '孙悦', '致力于近视、白内障及眼底病的临床诊治与手术。', 4);
INSERT INTO `doctors4` VALUES (5, '皮肤科', '黄志强', '专注皮肤病学，擅长银屑病、白癜风等治疗。', 0);
INSERT INTO `doctors4` VALUES (6, '内科', '邓亮', '精通心脏病的诊治，擅长冠状动脉支架置入术。', 3);
INSERT INTO `doctors4` VALUES (7, '儿科', '李凯', '专注于小儿呼吸系统疾病的诊断与治疗。', 1);
INSERT INTO `doctors4` VALUES (8, '外科', '郑伟', '在脊柱和关节手术方面有丰富经验，擅长骨折修复。', 2);
INSERT INTO `doctors4` VALUES (9, '眼科', '刘伟', '擅长白内障和青光眼手术，及视网膜疾病的诊治。', 3);
INSERT INTO `doctors4` VALUES (10, '皮肤科', '李婷', '皮肤病专家，擅长激光治疗各种皮肤病。', 1);
INSERT INTO `doctors4` VALUES (11, '内科', '蒋涛', '内科专家，擅长处理糖尿病、高血压等常见内科病。', 0);
INSERT INTO `doctors4` VALUES (12, '儿科', '王杰', '擅长儿童免疫学，尤其是预防接种和过敏性疾病。', 4);

-- ----------------------------
-- Table structure for doctors5
-- ----------------------------
DROP TABLE IF EXISTS `doctors5`;
CREATE TABLE `doctors5`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `department` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `doctor` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `detail` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `state` int NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 13 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of doctors5
-- ----------------------------
INSERT INTO `doctors5` VALUES (1, '内科', '王婷', '擅长处理糖尿病、脂肪肝等代谢性疾病的治疗和管理。', 4);
INSERT INTO `doctors5` VALUES (2, '儿科', '张博', '在儿童心理健康和行为问题的处理方面有丰富经验。', 1);
INSERT INTO `doctors5` VALUES (3, '外科', '赵峰', '外科手术专家，擅长腹部手术及胆囊切除手术。', 2);
INSERT INTO `doctors5` VALUES (4, '眼科', '黄晓明', '专注于视网膜疾病的诊治，擅长糖尿病视网膜病变的治疗。', 1);
INSERT INTO `doctors5` VALUES (5, '皮肤科', '陈波', '皮肤科专家，尤其擅长痤疮和激光脱毛。', 3);
INSERT INTO `doctors5` VALUES (6, '内科', '贾磊', '心血管内科专家，擅长高血压、冠心病的诊治。', 1);
INSERT INTO `doctors5` VALUES (7, '儿科', '李飞', '专注于小儿生长发育和常见疾病的预防与治疗。', 2);
INSERT INTO `doctors5` VALUES (8, '外科', '黄珊', '外科手术专家，尤其擅长妇科手术和乳腺癌治疗。', 3);
INSERT INTO `doctors5` VALUES (9, '眼科', '唐敏', '青光眼专家，擅长眼科手术和眼病的早期诊断。', 2);
INSERT INTO `doctors5` VALUES (10, '皮肤科', '刘杰', '皮肤病专家，擅长治疗湿疹、皮肤瘙痒等常见问题。', 0);
INSERT INTO `doctors5` VALUES (11, '内科', '吴志', '老年病专家，擅长治疗各种老年慢性病。', 4);
INSERT INTO `doctors5` VALUES (12, '儿科', '李涛', '专注于儿童胃肠病和呼吸系统疾病。', 0);

-- ----------------------------
-- Table structure for doctors6
-- ----------------------------
DROP TABLE IF EXISTS `doctors6`;
CREATE TABLE `doctors6`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `department` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `doctor` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `detail` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `state` int NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 13 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of doctors6
-- ----------------------------
INSERT INTO `doctors6` VALUES (1, '内科', '何亮', '内科专家，擅长呼吸系统疾病的诊治，尤其是哮喘和COPD的管理。', 0);
INSERT INTO `doctors6` VALUES (2, '儿科', '李磊', '儿童免疫学专家，擅长管理儿童的疫苗接种与预防接种。', 0);
INSERT INTO `doctors6` VALUES (3, '外科', '程宇', '胃肠外科专家，擅长消化道肿瘤的外科手术治疗。', 5);
INSERT INTO `doctors6` VALUES (4, '眼科', '邓子豪', '擅长青光眼、视网膜脱落的诊断与治疗。', 3);
INSERT INTO `doctors6` VALUES (5, '皮肤科', '吴敏', '专注于过敏性皮肤病，尤其擅长荨麻疹和湿疹的治疗。', 2);
INSERT INTO `doctors6` VALUES (6, '内科', '唐涛', '专注于肾脏病和糖尿病管理。', 2);
INSERT INTO `doctors6` VALUES (7, '儿科', '刘英', '擅长儿童神经系统疾病，尤其是癫痫。', 1);
INSERT INTO `doctors6` VALUES (8, '外科', '沈波', '擅长泌尿系统手术和妇科手术。', 0);
INSERT INTO `doctors6` VALUES (9, '眼科', '蒋晓', '眼科专家，专注于眼睛的屈光手术和常见眼病治疗。', 4);
INSERT INTO `doctors6` VALUES (10, '皮肤科', '任敏', '皮肤美容专家，专注治疗各种皮肤问题，如痤疮和皮肤过敏。', 1);
INSERT INTO `doctors6` VALUES (11, '内科', '赵倩', '专注于心血管疾病和呼吸系统疾病的治疗。', 3);
INSERT INTO `doctors6` VALUES (12, '儿科', '陈波', '擅长小儿哮喘、过敏性疾病的诊治。', 0);

-- ----------------------------
-- Table structure for doctors7
-- ----------------------------
DROP TABLE IF EXISTS `doctors7`;
CREATE TABLE `doctors7`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `department` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `doctor` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `detail` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `state` int NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 13 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of doctors7
-- ----------------------------
INSERT INTO `doctors7` VALUES (1, '内科', '蒋勇', '精通各类呼吸系统疾病的诊疗，尤其是支气管炎和肺气肿。', 1);
INSERT INTO `doctors7` VALUES (2, '儿科', '何雅', '儿童神经科专家，擅长癫痫和脑性麻痹的治疗。', 0);
INSERT INTO `doctors7` VALUES (3, '外科', '郑丽', '擅长各类创伤手术及骨科修复手术。', 3);
INSERT INTO `doctors7` VALUES (4, '眼科', '徐涛', '眼科专家，擅长眼科疾病的早期诊断与综合治疗。', 2);
INSERT INTO `doctors7` VALUES (5, '皮肤科', '曹俊', '擅长治疗银屑病、湿疹等常见皮肤病，尤其注重个体化治疗。', 4);
INSERT INTO `doctors7` VALUES (6, '内科', '蔡晨', '肾脏内科专家，擅长慢性肾病及透析治疗。', 0);
INSERT INTO `doctors7` VALUES (7, '儿科', '李馨', '专注儿童呼吸道疾病，尤其擅长哮喘治疗。', 1);
INSERT INTO `doctors7` VALUES (8, '外科', '赵萍', '擅长脊柱手术及关节置换手术。', 2);
INSERT INTO `doctors7` VALUES (9, '眼科', '孙燕', '专长视网膜疾病，尤其是黄斑病变的治疗。', 3);
INSERT INTO `doctors7` VALUES (10, '皮肤科', '王思', '皮肤科专家，主要研究湿疹、银屑病等皮肤病。', 5);
INSERT INTO `doctors7` VALUES (11, '内科', '王静', '心脏病专家，专长冠心病、高血压的诊治。', 2);
INSERT INTO `doctors7` VALUES (12, '儿科', '吴浩', '专注儿童消化系统疾病的治疗，擅长处理小儿肠胃病。', 1);

-- ----------------------------
-- Table structure for users
-- ----------------------------
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `password` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `email` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `role` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of users
-- ----------------------------
INSERT INTO `users` VALUES (1, 'wyf', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', '2022302111088@whu.edu.cn', 'admin');
INSERT INTO `users` VALUES (2, 'whu', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', '2022302111088@whu.edu.cn', 'user');
INSERT INTO `users` VALUES (3, 'www', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', '2022302111088@whu.edu.cn', 'user');

SET FOREIGN_KEY_CHECKS = 1;
