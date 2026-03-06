CREATE DATABASE  IF NOT EXISTS `railway` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `railway`;
-- MySQL dump 10.13  Distrib 8.0.44, for Win64 (x86_64)
--
-- Host: nozomi.proxy.rlwy.net    Database: railway
-- ------------------------------------------------------
-- Server version	9.4.0

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `admission_entries`
--

DROP TABLE IF EXISTS `admission_entries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `admission_entries` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `admission_id` bigint unsigned NOT NULL,
  `user_id` bigint unsigned DEFAULT NULL,
  `bp` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `pulse` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `temp` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `spo2` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `note` text COLLATE utf8mb4_unicode_ci,
  `recorded_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `admission_entries_user_id_foreign` (`user_id`),
  KEY `admission_entries_admission_id_recorded_at_index` (`admission_id`,`recorded_at`),
  CONSTRAINT `admission_entries_admission_id_foreign` FOREIGN KEY (`admission_id`) REFERENCES `admissions` (`id`) ON DELETE CASCADE,
  CONSTRAINT `admission_entries_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `admission_entries`
--

LOCK TABLES `admission_entries` WRITE;
/*!40000 ALTER TABLE `admission_entries` DISABLE KEYS */;
INSERT INTO `admission_entries` VALUES (1,2,NULL,'120/70','70','36.6','98%',NULL,'2026-03-05 20:51:00','2026-03-05 17:51:35','2026-03-05 17:51:35');
/*!40000 ALTER TABLE `admission_entries` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `admissions`
--

DROP TABLE IF EXISTS `admissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `admissions` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `patient_id` bigint unsigned NOT NULL,
  `doctor_id` bigint unsigned DEFAULT NULL,
  `ward` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `bed` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `admission_type` enum('general','maternity') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'general',
  `payment_type` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `reason` text COLLATE utf8mb4_unicode_ci,
  `status` enum('active','discharged','transferred') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `admitted_at` timestamp NULL DEFAULT NULL,
  `discharged_at` timestamp NULL DEFAULT NULL,
  `discharge_note` text COLLATE utf8mb4_unicode_ci,
  `created_by` bigint unsigned DEFAULT NULL,
  `updated_by` bigint unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `admissions_doctor_id_foreign` (`doctor_id`),
  KEY `admissions_patient_id_status_index` (`patient_id`,`status`),
  CONSTRAINT `admissions_doctor_id_foreign` FOREIGN KEY (`doctor_id`) REFERENCES `doctors` (`id`) ON DELETE SET NULL,
  CONSTRAINT `admissions_patient_id_foreign` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `admissions`
--

LOCK TABLES `admissions` WRITE;
/*!40000 ALTER TABLE `admissions` DISABLE KEYS */;
INSERT INTO `admissions` VALUES (1,3,NULL,'Medical','Room 2','general','insurance','Severe Malaria','active','2026-03-05 04:57:15',NULL,NULL,2,NULL,'2026-03-05 04:57:15','2026-03-05 04:57:15'),(2,4,5,'Medical','3','general','cash',NULL,'active','2026-03-05 17:50:12',NULL,NULL,2,NULL,'2026-03-05 17:50:12','2026-03-05 17:50:12');
/*!40000 ALTER TABLE `admissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `appointments`
--

DROP TABLE IF EXISTS `appointments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `appointments` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `patient_id` bigint unsigned NOT NULL,
  `doctor_id` bigint unsigned NOT NULL,
  `appointment_time` timestamp NOT NULL,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Scheduled',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_appointments_patient_id` (`patient_id`),
  KEY `idx_appointments_doctor_id` (`doctor_id`),
  KEY `idx_appointments_status` (`status`),
  KEY `idx_appointments_time` (`appointment_time`),
  CONSTRAINT `appointments_doctor_id_foreign` FOREIGN KEY (`doctor_id`) REFERENCES `doctors` (`id`) ON DELETE CASCADE,
  CONSTRAINT `appointments_patient_id_foreign` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `appointments`
--

LOCK TABLES `appointments` WRITE;
/*!40000 ALTER TABLE `appointments` DISABLE KEYS */;
/*!40000 ALTER TABLE `appointments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bill_items`
--

DROP TABLE IF EXISTS `bill_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bill_items` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `bill_id` bigint unsigned NOT NULL,
  `category` enum('consultation','prescription','lab','lab_test','service','custom') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'custom',
  `description` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `prescription_id` bigint unsigned DEFAULT NULL,
  `prescription_item_id` bigint unsigned DEFAULT NULL,
  `inventory_item_id` bigint unsigned DEFAULT NULL,
  `lab_request_id` bigint unsigned DEFAULT NULL,
  `lab_test_id` bigint unsigned DEFAULT NULL,
  `pharmacy_dispensation_id` bigint unsigned DEFAULT NULL,
  `pharmacy_dispensation_item_id` bigint unsigned DEFAULT NULL,
  `quantity` int unsigned NOT NULL DEFAULT '1',
  `amount` decimal(10,2) NOT NULL,
  `subtotal` decimal(10,2) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `bill_items_bill_id_category_index` (`bill_id`,`category`),
  KEY `bill_items_pharmacy_dispensation_id_index` (`pharmacy_dispensation_id`),
  KEY `bill_items_pharmacy_dispensation_item_id_index` (`pharmacy_dispensation_item_id`),
  CONSTRAINT `bill_items_bill_id_foreign` FOREIGN KEY (`bill_id`) REFERENCES `bills` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bill_items`
--

LOCK TABLES `bill_items` WRITE;
/*!40000 ALTER TABLE `bill_items` DISABLE KEYS */;
INSERT INTO `bill_items` VALUES (1,3,'consultation','Consultation Fee',NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,300.00,300.00,'2026-03-06 12:03:16','2026-03-06 12:03:16'),(7,3,'prescription','Paracetamol 500mg (tablet) - 500mg',7,7,NULL,NULL,NULL,NULL,NULL,1,5.00,5.00,'2026-03-06 12:12:53','2026-03-06 12:12:53'),(10,5,'consultation','Consultation Fee',NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,300.00,300.00,'2026-03-06 12:36:17','2026-03-06 12:36:17'),(11,5,'lab_test','Complete Blood Count',NULL,NULL,NULL,6,6,NULL,NULL,1,800.00,800.00,'2026-03-06 12:40:03','2026-03-06 12:40:03'),(12,5,'lab_test','Blood Grouping',NULL,NULL,NULL,6,7,NULL,NULL,1,200.00,200.00,'2026-03-06 12:40:03','2026-03-06 12:40:03'),(13,5,'prescription','Paracetamol 500mg (tablet) - 500 mg',9,9,NULL,NULL,NULL,NULL,NULL,1,5.00,5.00,'2026-03-06 12:57:56','2026-03-06 12:57:56');
/*!40000 ALTER TABLE `bill_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bills`
--

DROP TABLE IF EXISTS `bills`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bills` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `patient_id` bigint unsigned NOT NULL,
  `treatment_id` bigint unsigned DEFAULT NULL,
  `admission_id` bigint unsigned DEFAULT NULL,
  `doctor_id` bigint unsigned DEFAULT NULL,
  `subtotal` decimal(10,2) NOT NULL DEFAULT '0.00',
  `discount` decimal(10,2) NOT NULL DEFAULT '0.00',
  `tax` decimal(10,2) NOT NULL DEFAULT '0.00',
  `total_amount` decimal(10,2) NOT NULL DEFAULT '0.00',
  `status` enum('unpaid','partial','paid') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'unpaid',
  `bill_type` enum('outpatient','inpatient') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'outpatient',
  `payment_method` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `created_by` bigint unsigned DEFAULT NULL,
  `updated_by` bigint unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `bills_doctor_id_foreign` (`doctor_id`),
  KEY `bills_patient_id_treatment_id_status_index` (`patient_id`,`treatment_id`,`status`),
  KEY `bills_created_by_foreign` (`created_by`),
  KEY `bills_updated_by_foreign` (`updated_by`),
  KEY `idx_bills_patient_id` (`patient_id`),
  KEY `idx_bills_treatment_id` (`treatment_id`),
  KEY `idx_bills_status` (`status`),
  KEY `idx_bills_created_at` (`created_at`),
  KEY `bills_admission_id_foreign` (`admission_id`),
  CONSTRAINT `bills_admission_id_foreign` FOREIGN KEY (`admission_id`) REFERENCES `admissions` (`id`) ON DELETE SET NULL,
  CONSTRAINT `bills_created_by_foreign` FOREIGN KEY (`created_by`) REFERENCES `staff` (`id`) ON DELETE SET NULL,
  CONSTRAINT `bills_doctor_id_foreign` FOREIGN KEY (`doctor_id`) REFERENCES `doctors` (`id`) ON DELETE SET NULL,
  CONSTRAINT `bills_patient_id_foreign` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`id`) ON DELETE CASCADE,
  CONSTRAINT `bills_treatment_id_foreign` FOREIGN KEY (`treatment_id`) REFERENCES `treatments` (`id`) ON DELETE SET NULL,
  CONSTRAINT `bills_updated_by_foreign` FOREIGN KEY (`updated_by`) REFERENCES `staff` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bills`
--

LOCK TABLES `bills` WRITE;
/*!40000 ALTER TABLE `bills` DISABLE KEYS */;
INSERT INTO `bills` VALUES (3,6,5,NULL,6,305.00,0.00,0.00,305.00,'unpaid','outpatient','Insurance',NULL,'2026-03-06 12:03:16','2026-03-06 12:12:53',NULL,NULL),(5,7,6,NULL,4,1305.00,0.00,0.00,1305.00,'unpaid','outpatient','Bank Transfer',NULL,'2026-03-06 12:36:17','2026-03-06 12:57:56',NULL,NULL);
/*!40000 ALTER TABLE `bills` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cache`
--

DROP TABLE IF EXISTS `cache`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cache` (
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `value` mediumtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` int NOT NULL,
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cache`
--

LOCK TABLES `cache` WRITE;
/*!40000 ALTER TABLE `cache` DISABLE KEYS */;
INSERT INTO `cache` VALUES ('laravel-cache-lab_draft_2_2_4','a:3:{s:10:\"parameters\";a:6:{i:0;a:2:{s:12:\"parameter_id\";i:1;s:5:\"value\";s:1:\"5\";}i:1;a:2:{s:12:\"parameter_id\";i:2;s:5:\"value\";s:1:\"5\";}i:2;a:2:{s:12:\"parameter_id\";i:3;s:5:\"value\";s:2:\"14\";}i:3;a:2:{s:12:\"parameter_id\";i:4;s:5:\"value\";s:2:\"40\";}i:4;a:2:{s:12:\"parameter_id\";i:5;s:5:\"value\";s:3:\"350\";}i:5;a:2:{s:12:\"parameter_id\";i:6;s:5:\"value\";s:2:\"90\";}}s:15:\"overall_comment\";s:0:\"\";s:8:\"saved_at\";s:19:\"2026-03-04 18:26:15\";}',1773253575);
/*!40000 ALTER TABLE `cache` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cache_locks`
--

DROP TABLE IF EXISTS `cache_locks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cache_locks` (
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `owner` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` int NOT NULL,
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cache_locks`
--

LOCK TABLES `cache_locks` WRITE;
/*!40000 ALTER TABLE `cache_locks` DISABLE KEYS */;
/*!40000 ALTER TABLE `cache_locks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `diagnoses`
--

DROP TABLE IF EXISTS `diagnoses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `diagnoses` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `treatment_id` bigint unsigned NOT NULL,
  `diagnosis` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `diagnosis_category` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `diagnosis_subcategory` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_primary` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `diagnoses_treatment_id_foreign` (`treatment_id`),
  CONSTRAINT `diagnoses_treatment_id_foreign` FOREIGN KEY (`treatment_id`) REFERENCES `treatments` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `diagnoses`
--

LOCK TABLES `diagnoses` WRITE;
/*!40000 ALTER TABLE `diagnoses` DISABLE KEYS */;
/*!40000 ALTER TABLE `diagnoses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `doctors`
--

DROP TABLE IF EXISTS `doctors`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `doctors` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `first_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `specialization` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `doctors_email_unique` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `doctors`
--

LOCK TABLES `doctors` WRITE;
/*!40000 ALTER TABLE `doctors` DISABLE KEYS */;
INSERT INTO `doctors` VALUES (4,'Moses','Simiyu',NULL,'0757144358','moses@naitirijambo.com','2026-03-04 18:11:07','2026-03-04 18:11:07'),(5,'Bravin','Wanjala',NULL,'0790679873','bravin@naitirijambo.com','2026-03-05 05:09:41','2026-03-05 05:09:41'),(6,'Benard','Ngichabe',NULL,'0726427775','benard@naitirijambo.com','2026-03-05 05:10:52','2026-03-05 05:10:52'),(7,'Brevin','Wanjala',NULL,'0790679873','brevin@naitirijambo.com','2026-03-05 05:09:41','2026-03-06 12:57:27');
/*!40000 ALTER TABLE `doctors` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `facility_profiles`
--

DROP TABLE IF EXISTS `facility_profiles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `facility_profiles` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `facility_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `moh_code` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `keph_level` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `county` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `sub_county` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `ward` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `physical_address` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ownership` enum('public','faith_based','private','ngo') COLLATE utf8mb4_unicode_ci NOT NULL,
  `services_offered` json NOT NULL,
  `phone` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `facility_incharge` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `incharge_phone` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `facility_profiles_moh_code_unique` (`moh_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `facility_profiles`
--

LOCK TABLES `facility_profiles` WRITE;
/*!40000 ALTER TABLE `facility_profiles` DISABLE KEYS */;
/*!40000 ALTER TABLE `facility_profiles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `failed_jobs`
--

DROP TABLE IF EXISTS `failed_jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `failed_jobs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `uuid` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `connection` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `queue` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `exception` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `failed_jobs`
--

LOCK TABLES `failed_jobs` WRITE;
/*!40000 ALTER TABLE `failed_jobs` DISABLE KEYS */;
/*!40000 ALTER TABLE `failed_jobs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `idsr_diseases`
--

DROP TABLE IF EXISTS `idsr_diseases`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `idsr_diseases` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `disease_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `disease_code` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_priority` tinyint(1) NOT NULL DEFAULT '0',
  `is_immediately_notifiable` tinyint(1) NOT NULL DEFAULT '0',
  `case_definition` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idsr_diseases_disease_name_unique` (`disease_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `idsr_diseases`
--

LOCK TABLES `idsr_diseases` WRITE;
/*!40000 ALTER TABLE `idsr_diseases` DISABLE KEYS */;
/*!40000 ALTER TABLE `idsr_diseases` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inventory_items`
--

DROP TABLE IF EXISTS `inventory_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inventory_items` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `item_code` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `category` enum('Medicine','Equipment','Consumable') COLLATE utf8mb4_unicode_ci NOT NULL,
  `subcategory` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `quantity` int unsigned NOT NULL DEFAULT '0',
  `unit` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `reorder_level` int unsigned DEFAULT NULL,
  `unit_price` decimal(10,2) NOT NULL DEFAULT '0.00',
  `supplier_id` bigint unsigned DEFAULT NULL,
  `pharmacy_drug_id` bigint unsigned DEFAULT NULL,
  `expiry_date` date DEFAULT NULL,
  `batch_no` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `location` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `inventory_items_item_code_unique` (`item_code`),
  KEY `inventory_items_supplier_id_foreign` (`supplier_id`),
  KEY `inventory_items_pharmacy_drug_id_foreign` (`pharmacy_drug_id`),
  CONSTRAINT `inventory_items_pharmacy_drug_id_foreign` FOREIGN KEY (`pharmacy_drug_id`) REFERENCES `pharmacy_drugs` (`id`) ON DELETE SET NULL,
  CONSTRAINT `inventory_items_supplier_id_foreign` FOREIGN KEY (`supplier_id`) REFERENCES `suppliers` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=103 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inventory_items`
--

LOCK TABLES `inventory_items` WRITE;
/*!40000 ALTER TABLE `inventory_items` DISABLE KEYS */;
INSERT INTO `inventory_items` VALUES (1,'MED-00001','Dextrose','Medicine',NULL,4,'bottles',10,500.00,1,NULL,'2026-01-01','BATCH-A','Pharmacy A','2026-03-04 07:29:55','2026-03-05 06:28:53','2026-03-05 06:28:53'),(2,'EQP-00002','Syringe 5ml','Equipment',NULL,300,'piece',50,0.80,1,NULL,NULL,NULL,'Store Room','2026-03-04 07:29:55','2026-03-04 07:29:55',NULL),(3,'CON-00003','Bandage Roll','Consumable',NULL,75,'roll',20,1.20,1,NULL,NULL,NULL,'Store Room','2026-03-04 07:29:55','2026-03-04 07:29:55',NULL),(4,'MED-00004','Dextrose','Medicine',NULL,4,'bottles',10,500.00,2,4,'2026-01-01','BATCH-A',NULL,'2026-03-05 06:29:33','2026-03-05 09:58:49',NULL),(5,'MED-00005','Glibenclamide','Medicine',NULL,0,'tablets',100,10.00,2,5,NULL,NULL,NULL,'2026-03-05 07:41:28','2026-03-05 09:17:37',NULL),(6,'MED-00006','Metformin','Medicine',NULL,0,'tablets',100,10.00,2,6,NULL,NULL,NULL,'2026-03-05 07:43:37','2026-03-05 09:44:56',NULL),(7,'MED-00007','Metformin','Medicine',NULL,0,'tablets',7,10.00,2,7,NULL,NULL,NULL,'2026-03-05 07:44:37','2026-03-05 09:41:32',NULL),(8,'MED-00008','Folic Acid','Medicine',NULL,0,'tablets',100,10.00,2,8,NULL,NULL,NULL,'2026-03-05 07:49:58','2026-03-05 09:28:07',NULL),(9,'MED-00009','IFAS','Medicine',NULL,0,'tablets',100,10.00,2,9,NULL,NULL,NULL,'2026-03-05 07:52:43','2026-03-05 09:37:55',NULL),(10,'MED-00010','Nifedipine','Medicine',NULL,0,'tablets',100,5.00,2,10,NULL,NULL,NULL,'2026-03-05 07:54:02','2026-03-05 09:50:36',NULL),(11,'MED-00011','Atenolol','Medicine',NULL,0,'tablets',20,5.00,2,11,NULL,NULL,NULL,'2026-03-05 07:57:23','2026-03-05 09:19:50',NULL),(12,'MED-00012','Losartan H','Medicine',NULL,0,'tablets',20,10.00,2,12,NULL,NULL,NULL,'2026-03-05 07:58:37','2026-03-05 09:40:18',NULL),(13,'MED-00013','Losartan P','Medicine',NULL,0,'tablets',20,10.00,2,13,NULL,NULL,NULL,'2026-03-05 07:59:16','2026-03-05 09:41:12',NULL),(14,'MED-00014','Montelukast','Medicine',NULL,0,'tablets',20,5.00,2,14,NULL,NULL,NULL,'2026-03-05 08:00:29','2026-03-05 09:50:10',NULL),(15,'MED-00015','Atorvastatin','Medicine',NULL,0,'tablets',20,5.00,2,15,NULL,NULL,NULL,'2026-03-05 08:02:17','2026-03-05 09:22:05',NULL),(16,'MED-00016','Furosemide','Medicine',NULL,0,'tablets',20,10.00,2,16,NULL,NULL,NULL,'2026-03-05 08:05:07','2026-03-05 09:31:27',NULL),(17,'MED-00017','HCTZ','Medicine',NULL,0,'tablets',100,5.00,2,17,NULL,NULL,NULL,'2026-03-05 08:08:23','2026-03-05 09:35:39',NULL),(18,'MED-00018','Pyridoxine','Medicine',NULL,0,'tablets',100,5.00,2,18,NULL,NULL,NULL,'2026-03-05 08:10:06','2026-03-05 09:51:28',NULL),(19,'MED-00019','Bisacodyl','Medicine',NULL,0,'tablets',100,5.00,2,19,NULL,NULL,NULL,'2026-03-05 08:12:35','2026-03-05 09:23:07',NULL),(20,'MED-00020','Metoclopramide','Medicine',NULL,0,'tablets',50,5.00,2,20,NULL,NULL,NULL,'2026-03-05 08:14:03','2026-03-05 09:49:40',NULL),(21,'MED-00021','Diazepam','Medicine',NULL,0,'tablets',30,5.00,2,21,NULL,NULL,NULL,'2026-03-05 08:15:22','2026-03-05 09:25:38',NULL),(22,'MED-00022','Sulbutamol','Medicine',NULL,0,'tablets',100,5.00,2,22,NULL,NULL,NULL,'2026-03-05 08:18:14','2026-03-05 09:51:49',NULL),(23,'MED-00023','Clotrimazole','Medicine',NULL,0,'tablets',10,100.00,2,23,NULL,NULL,NULL,'2026-03-05 08:25:27','2026-03-05 09:23:56',NULL),(24,'MED-00024','Clotrimazole Vaginal Pessaris','Medicine',NULL,12,'tablets',10,30.00,2,24,NULL,NULL,NULL,'2026-03-05 08:27:41','2026-03-05 08:27:41',NULL),(25,'MED-00025','Andrin Nasal Drops','Medicine',NULL,0,'bottles',10,50.00,2,25,NULL,NULL,NULL,'2026-03-05 08:30:27','2026-03-05 09:24:18',NULL),(26,'MED-00026','Tetracycline Hydrochloride Eye Ointment','Medicine',NULL,0,'bottles',10,50.00,2,26,NULL,NULL,NULL,'2026-03-05 08:34:06','2026-03-05 09:14:06',NULL),(27,'MED-00027','Chlorhexidine Digluconate','Medicine',NULL,0,'sachets',10,100.00,2,27,NULL,NULL,NULL,'2026-03-05 08:40:31','2026-03-05 09:13:30',NULL),(28,'MED-00028','Sayana Press','Medicine',NULL,0,'pieces',10,200.00,2,28,NULL,NULL,NULL,'2026-03-05 08:45:36','2026-03-05 09:10:29',NULL),(29,'MED-00029','Depo','Medicine',NULL,0,'vials',10,200.00,2,29,NULL,NULL,NULL,'2026-03-05 08:49:03','2026-03-05 09:11:18',NULL),(30,'MED-00030','Levonorgestrel','Medicine',NULL,0,'tablets',10,50.00,2,30,NULL,NULL,NULL,'2026-03-05 08:54:50','2026-03-05 09:11:40',NULL),(31,'MED-00031','Femiplan Pills','Medicine',NULL,0,'tablets',28,5.00,2,31,NULL,NULL,NULL,'2026-03-05 09:03:04','2026-03-05 09:09:58',NULL),(32,'MED-00032','Ringers Lactate','Medicine',NULL,0,'bottles',10,500.00,2,32,NULL,NULL,NULL,'2026-03-05 09:07:07','2026-03-05 09:08:38',NULL),(33,'MED-00033','Normal Saline','Medicine',NULL,0,'bottles',10,500.00,2,33,NULL,NULL,NULL,'2026-03-05 09:56:56','2026-03-06 11:38:58',NULL),(34,'MED-00034','Hydrocortisone','Medicine',NULL,0,'vials',10,500.00,2,34,NULL,NULL,NULL,'2026-03-05 10:07:05','2026-03-05 10:07:56',NULL),(35,'MED-00035','Benzyl Penicillin (XPEN)','Medicine',NULL,100,'vials',10,200.00,1,35,NULL,NULL,NULL,'2026-03-05 11:24:59','2026-03-06 11:37:50',NULL),(36,'MED-00036','Dexamethasone','Medicine',NULL,0,'pieces',10,200.00,2,36,NULL,NULL,NULL,'2026-03-05 11:27:11','2026-03-05 15:44:19',NULL),(37,'MED-00037','Diclofenac','Medicine',NULL,0,'pieces',10,200.00,2,37,NULL,NULL,NULL,'2026-03-05 11:30:18','2026-03-05 11:34:57',NULL),(38,'MED-00038','Ceftriaxone','Medicine',NULL,0,'vials',10,250.00,2,38,NULL,NULL,NULL,'2026-03-05 11:38:07','2026-03-05 11:38:37',NULL),(39,'MED-00039','Gentamycin','Medicine',NULL,0,'pieces',10,100.00,2,39,NULL,NULL,NULL,'2026-03-05 11:43:12','2026-03-05 11:43:40',NULL),(40,'MED-00040','Aminophylline','Medicine',NULL,0,'pieces',10,300.00,2,40,NULL,NULL,NULL,'2026-03-05 11:49:07','2026-03-05 11:49:37',NULL),(41,'MED-00041','Fluphenazine Decanoate','Medicine',NULL,0,'pieces',10,1000.00,2,41,NULL,NULL,NULL,'2026-03-05 11:53:48','2026-03-05 11:54:22',NULL),(42,'MED-00042','Diazepam','Medicine',NULL,0,'pieces',10,200.00,2,42,NULL,NULL,NULL,'2026-03-05 12:01:07','2026-03-05 12:01:36',NULL),(43,'MED-00043','Frusemide(Lasix)','Medicine',NULL,0,'pieces',10,100.00,2,43,NULL,NULL,NULL,'2026-03-05 12:08:55','2026-03-05 12:09:15',NULL),(44,'MED-00044','Atropine','Medicine',NULL,0,'pieces',10,500.00,2,44,NULL,NULL,NULL,'2026-03-05 12:17:02','2026-03-05 12:25:38',NULL),(45,'MED-00045','Adrenaline','Medicine',NULL,0,'pieces',5,300.00,2,45,NULL,NULL,NULL,'2026-03-05 12:29:21','2026-03-05 12:29:37',NULL),(46,'MED-00046','Metoclopramide (Plasil)','Medicine',NULL,0,'pieces',5,100.00,2,46,NULL,NULL,NULL,'2026-03-05 12:33:20','2026-03-05 12:35:33',NULL),(47,'MED-00047','Lidocaine','Medicine',NULL,0,'bottles',0,300.00,NULL,47,NULL,NULL,NULL,'2026-03-05 12:43:58','2026-03-05 12:44:27',NULL),(48,'MED-00048','Metronidazole','Medicine',NULL,0,'bottles',0,300.00,2,48,NULL,NULL,NULL,'2026-03-05 12:48:03','2026-03-05 12:48:23',NULL),(49,'MED-00049','Iv Paracetamol','Medicine',NULL,0,'bottles',10,300.00,2,49,NULL,NULL,NULL,'2026-03-05 12:54:11','2026-03-05 12:54:44',NULL),(50,'MED-00050','Ciprofloxacin','Medicine',NULL,0,'bottles',10,300.00,2,50,NULL,NULL,NULL,'2026-03-05 12:59:38','2026-03-05 12:59:53',NULL),(51,'MED-00051','Quinine Dihydrochloride','Medicine',NULL,0,'pieces',10,200.00,2,51,NULL,NULL,NULL,'2026-03-05 13:05:00','2026-03-05 13:05:16',NULL),(52,'MED-00052','Im Artemether','Medicine',NULL,0,'pieces',10,100.00,2,52,NULL,NULL,NULL,'2026-03-05 13:08:28','2026-03-05 13:08:48',NULL),(53,'MED-00053','AL','Medicine',NULL,0,'tablets',48,5.00,2,53,NULL,NULL,NULL,'2026-03-05 13:14:55','2026-03-05 13:15:13',NULL),(54,'MED-00054','P-Alaxin','Medicine',NULL,0,'bottles',10,50.00,2,54,NULL,NULL,NULL,'2026-03-05 13:20:00','2026-03-05 13:21:13',NULL),(55,'MED-00055','Artemether & Lumefantrine','Medicine',NULL,0,'bottles',0,50.00,NULL,55,NULL,NULL,NULL,'2026-03-05 13:25:23','2026-03-05 13:25:36',NULL),(56,'MED-00056','Amoxicillin & Clavulanate Potassium','Medicine',NULL,0,'tablets',20,35.00,2,56,NULL,NULL,NULL,'2026-03-05 13:33:45','2026-03-05 13:34:10',NULL),(57,'MED-00057','Amoxicillin & Clavulanate Potassium','Medicine',NULL,0,'tablets',20,35.00,2,57,NULL,NULL,NULL,'2026-03-05 13:36:00','2026-03-05 13:37:05',NULL),(58,'MED-00058','Ciprofloxacin','Medicine',NULL,0,'tablets',100,10.00,2,58,NULL,NULL,NULL,'2026-03-05 13:39:46','2026-03-05 13:53:58',NULL),(59,'MED-00059','Benzathine Benzylpenicillin (2.4mega)','Medicine',NULL,0,'vials',20,300.00,2,59,NULL,NULL,NULL,'2026-03-05 13:43:42','2026-03-05 13:44:04',NULL),(60,'MED-00060','Streptomycin Sulphate','Medicine',NULL,0,'vials',10,200.00,2,60,NULL,NULL,NULL,'2026-03-05 13:46:57','2026-03-05 13:47:19',NULL),(61,'MED-00061','Artesunate','Medicine',NULL,0,'pieces',10,200.00,2,61,NULL,NULL,NULL,'2026-03-05 13:51:15','2026-03-05 13:51:30',NULL),(62,'MED-00062','Doxycycline','Medicine',NULL,0,'capsules',100,5.00,2,62,NULL,NULL,NULL,'2026-03-05 13:56:59','2026-03-05 13:57:20',NULL),(63,'MED-00063','Ampiclox','Medicine',NULL,0,'capsules',100,5.00,2,63,NULL,NULL,NULL,'2026-03-05 13:59:48','2026-03-05 14:00:09',NULL),(64,'MED-00064','Amoxicillin','Medicine',NULL,0,'capsules',100,5.00,2,64,NULL,NULL,NULL,'2026-03-05 14:03:02','2026-03-05 14:07:34',NULL),(65,'MED-00065','Amoxicillin DT','Medicine',NULL,0,'tablets',100,5.00,1,65,NULL,NULL,NULL,'2026-03-05 14:05:44','2026-03-06 11:09:29',NULL),(66,'MED-00066','Metronidazole','Medicine',NULL,0,'tablets',100,5.00,NULL,66,NULL,NULL,NULL,'2026-03-05 14:10:16','2026-03-05 14:11:35',NULL),(67,'MED-00067','Tinidazole','Medicine',NULL,0,'tablets',50,5.00,2,67,NULL,NULL,NULL,'2026-03-05 14:14:24','2026-03-05 14:14:42',NULL),(68,'MED-00068','Co-Trimoxazole','Medicine',NULL,0,'tablets',50,5.00,1,68,NULL,NULL,NULL,'2026-03-05 14:17:38','2026-03-06 11:21:14',NULL),(69,'MED-00069','Iv Esomeprazole','Medicine',NULL,0,'vials',10,200.00,2,69,NULL,NULL,NULL,'2026-03-05 14:20:11','2026-03-05 14:21:09',NULL),(70,'MED-00070','Omeprazole','Medicine',NULL,0,'capsules',100,10.00,NULL,70,NULL,NULL,NULL,'2026-03-05 14:26:51','2026-03-05 14:27:08',NULL),(71,'MED-00071','Nystatin','Medicine',NULL,0,'bottles',100,100.00,NULL,71,NULL,NULL,NULL,'2026-03-05 14:29:36','2026-03-05 14:29:51',NULL),(72,'MED-00072','Secnidazole','Medicine',NULL,0,'tablets',20,25.00,2,72,NULL,NULL,NULL,'2026-03-05 14:32:24','2026-03-05 14:32:40',NULL),(73,'MED-00073','Albendazole (ABZ)','Medicine',NULL,0,'tablets',20,20.00,2,73,NULL,NULL,NULL,'2026-03-05 14:35:43','2026-03-05 14:36:00',NULL),(74,'MED-00074','Fluconazole','Medicine',NULL,0,'capsules',20,20.00,2,74,NULL,NULL,NULL,'2026-03-05 14:38:56','2026-03-05 14:39:19',NULL),(75,'MED-00075','Salorex','Medicine',NULL,0,'bottles',20,150.00,2,75,NULL,NULL,NULL,'2026-03-05 14:43:10','2026-03-05 14:43:36',NULL),(76,'MED-00076','Vitaglobin','Medicine',NULL,0,'bottles',10,450.00,2,76,NULL,NULL,NULL,'2026-03-05 14:47:56','2026-03-05 14:48:11',NULL),(77,'MED-00077','Promivit','Medicine',NULL,0,'bottles',10,150.00,2,77,NULL,NULL,NULL,'2026-03-05 14:50:00','2026-03-05 14:50:15',NULL),(78,'MED-00078','Piroxicam','Medicine',NULL,0,'capsules',100,5.00,2,78,NULL,NULL,NULL,'2026-03-05 14:53:31','2026-03-05 14:53:45',NULL),(79,'MED-00079','Paracetamol','Medicine',NULL,0,'pieces',10,50.00,2,79,NULL,NULL,NULL,'2026-03-05 14:57:07','2026-03-05 14:57:35',NULL),(80,'MED-00080','Paracetamol','Medicine',NULL,0,'pieces',10,50.00,2,80,NULL,NULL,NULL,'2026-03-05 14:58:06','2026-03-05 14:58:23',NULL),(81,'MED-00081','Cetrizine','Medicine',NULL,0,'tablets',100,5.00,2,81,NULL,NULL,NULL,'2026-03-05 15:01:39','2026-03-05 15:02:01',NULL),(82,'MED-00082','Piriton','Medicine',NULL,0,'tablets',100,5.00,2,82,NULL,NULL,NULL,'2026-03-05 15:03:06','2026-03-05 15:03:29',NULL),(83,'MED-00083','Paracetamol','Medicine',NULL,0,'tablets',100,5.00,2,83,NULL,NULL,NULL,'2026-03-05 15:04:58','2026-03-05 15:05:16',NULL),(84,'MED-00084','Ibuprofen','Medicine',NULL,0,'tablets',100,5.00,2,84,NULL,NULL,NULL,'2026-03-05 15:07:02','2026-03-05 15:07:27',NULL),(85,'MED-00085','Ibuprofen','Medicine',NULL,0,'tablets',100,5.00,2,85,NULL,NULL,NULL,'2026-03-05 15:08:22','2026-03-05 15:08:38',NULL),(86,'MED-00086','Metronidazole','Medicine',NULL,0,'bottles',50,100.00,2,86,NULL,NULL,NULL,'2026-03-05 15:11:50','2026-03-05 15:12:14',NULL),(87,'MED-00087','Metronidazole','Medicine',NULL,0,'bottles',20,150.00,2,87,NULL,NULL,NULL,'2026-03-05 15:13:54','2026-03-05 15:14:22',NULL),(88,'MED-00088','Zinc Sulphate','Medicine',NULL,60,'tablets',20,15.00,2,88,NULL,NULL,NULL,'2026-03-05 15:16:12','2026-03-05 15:16:12',NULL),(89,'MED-00089','Oral Rehydration Salts (ORS)','Medicine',NULL,0,'sachets',20,30.00,2,89,NULL,NULL,NULL,'2026-03-05 15:19:30','2026-03-05 15:19:46',NULL),(90,'MED-00090','Azithromycin','Medicine',NULL,0,'bottles',20,50.00,2,90,NULL,NULL,NULL,'2026-03-05 15:21:54','2026-03-05 15:22:14',NULL),(91,'MED-00091','Amoxiclav','Medicine',NULL,0,'bottles',20,100.00,2,91,NULL,NULL,NULL,'2026-03-05 15:24:48','2026-03-05 15:25:07',NULL),(92,'MED-00092','Ibuprofen','Medicine',NULL,0,'bottles',20,100.00,2,92,NULL,NULL,NULL,'2026-03-05 15:28:13','2026-03-05 15:28:27',NULL),(93,'MED-00093','Co-Trimoxazole','Medicine',NULL,0,'bottles',20,100.00,2,93,NULL,NULL,NULL,'2026-03-05 15:30:21','2026-03-05 15:30:39',NULL),(94,'MED-00094','Piriton','Medicine',NULL,0,'bottles',20,100.00,2,94,NULL,NULL,NULL,'2026-03-05 15:31:51','2026-03-05 15:32:05',NULL),(95,'MED-00095','Paracetamol','Medicine',NULL,0,'bottles',20,100.00,2,95,NULL,NULL,NULL,'2026-03-05 15:33:40','2026-03-05 15:34:00',NULL),(96,'MED-00096','Sulbutamol','Medicine',NULL,0,'bottles',20,50.00,2,96,NULL,NULL,NULL,'2026-03-05 15:36:13','2026-03-05 15:36:28',NULL),(97,'MED-00097','Promethazine Hydrochloride','Medicine',NULL,0,'bottles',15,50.00,NULL,97,NULL,NULL,NULL,'2026-03-05 15:41:15','2026-03-05 15:41:33',NULL),(98,'MED-00098','Cetrizine','Medicine',NULL,0,'bottles',10,50.00,2,98,NULL,NULL,NULL,'2026-03-05 15:42:40','2026-03-05 15:42:57',NULL),(99,'MED-00099','Glysit (Dapagliflozin)','Medicine',NULL,0,'tablets',0,100.00,1,99,NULL,NULL,NULL,'2026-03-06 11:19:56','2026-03-06 11:20:09',NULL),(100,'MED-00100','Nelgra (Viagra gen)','Medicine',NULL,0,'tablets',20,20.00,1,100,NULL,NULL,NULL,'2026-03-06 11:33:52','2026-03-06 11:34:07',NULL),(101,'MED-00101','Prednisolone','Medicine',NULL,0,'tablets',20,5.00,1,101,NULL,NULL,NULL,'2026-03-06 11:37:02','2026-03-06 11:37:20',NULL),(102,'MED-00102','Calamine Lotion','Medicine',NULL,0,'pieces',10,100.00,1,102,NULL,NULL,NULL,'2026-03-06 11:40:48','2026-03-06 11:41:11',NULL);
/*!40000 ALTER TABLE `inventory_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inventory_transactions`
--

DROP TABLE IF EXISTS `inventory_transactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inventory_transactions` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `item_id` bigint unsigned NOT NULL,
  `type` enum('in','out','adjustment') COLLATE utf8mb4_unicode_ci NOT NULL,
  `quantity` int NOT NULL,
  `balance_after` int NOT NULL,
  `reason` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `reference` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `performed_by` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `inventory_transactions_item_id_foreign` (`item_id`),
  CONSTRAINT `inventory_transactions_item_id_foreign` FOREIGN KEY (`item_id`) REFERENCES `inventory_items` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=220 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inventory_transactions`
--

LOCK TABLES `inventory_transactions` WRITE;
/*!40000 ALTER TABLE `inventory_transactions` DISABLE KEYS */;
INSERT INTO `inventory_transactions` VALUES (1,1,'in',120,120,'Seed stock',NULL,'seeder','2026-03-04 07:29:55','2026-03-04 07:29:55'),(2,2,'in',300,300,'Seed stock',NULL,'seeder','2026-03-04 07:29:55','2026-03-04 07:29:55'),(3,3,'in',75,75,'Seed stock',NULL,'seeder','2026-03-04 07:29:55','2026-03-04 07:29:55'),(4,1,'out',116,4,'Main Store quantity adjustment',NULL,'system','2026-03-05 05:56:46','2026-03-05 05:56:46'),(5,4,'in',4,4,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 06:29:33','2026-03-05 06:29:33'),(6,5,'in',1090,1090,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 07:41:28','2026-03-05 07:41:28'),(7,6,'in',400,400,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 07:43:37','2026-03-05 07:43:37'),(8,7,'in',20,20,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 07:44:37','2026-03-05 07:44:37'),(9,5,'in',112,1202,'Main Store quantity adjustment',NULL,'system','2026-03-05 07:46:50','2026-03-05 07:46:50'),(10,8,'in',299,299,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 07:49:58','2026-03-05 07:49:58'),(11,9,'in',400,400,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 07:52:43','2026-03-05 07:52:43'),(12,10,'in',400,400,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 07:54:02','2026-03-05 07:54:02'),(13,11,'in',28,28,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 07:57:23','2026-03-05 07:57:23'),(14,12,'in',28,28,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 07:58:37','2026-03-05 07:58:37'),(15,13,'in',28,28,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 07:59:16','2026-03-05 07:59:16'),(16,14,'in',60,60,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 08:00:29','2026-03-05 08:00:29'),(17,15,'in',60,60,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 08:02:17','2026-03-05 08:02:17'),(18,15,'in',30,90,'Main Store quantity adjustment',NULL,'system','2026-03-05 08:03:39','2026-03-05 08:03:39'),(19,16,'in',44,44,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 08:05:07','2026-03-05 08:05:07'),(20,17,'in',490,490,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 08:08:23','2026-03-05 08:08:23'),(21,18,'in',180,180,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 08:10:06','2026-03-05 08:10:06'),(22,19,'in',59,59,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 08:12:35','2026-03-05 08:12:35'),(23,20,'in',90,90,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 08:14:03','2026-03-05 08:14:03'),(24,21,'in',40,40,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 08:15:22','2026-03-05 08:15:22'),(25,22,'in',1100,1100,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 08:18:14','2026-03-05 08:18:14'),(26,10,'in',1200,1600,'Main Store quantity adjustment',NULL,'system','2026-03-05 08:21:56','2026-03-05 08:21:56'),(27,23,'in',11,11,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 08:25:27','2026-03-05 08:25:27'),(28,24,'in',12,12,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 08:27:41','2026-03-05 08:27:41'),(29,25,'in',4,4,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 08:30:27','2026-03-05 08:30:27'),(30,25,'out',4,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 08:30:59','2026-03-05 08:30:59'),(31,26,'in',8,8,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 08:34:06','2026-03-05 08:34:06'),(32,26,'out',8,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 08:34:29','2026-03-05 08:34:29'),(33,27,'in',6,6,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 08:40:31','2026-03-05 08:40:31'),(34,27,'out',6,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 08:40:55','2026-03-05 08:40:55'),(35,28,'in',35,35,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 08:45:36','2026-03-05 08:45:36'),(36,28,'out',35,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 08:46:06','2026-03-05 08:46:06'),(37,29,'in',6,6,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 08:49:03','2026-03-05 08:49:03'),(38,29,'out',6,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 08:49:47','2026-03-05 08:49:47'),(39,30,'in',6,6,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 08:54:50','2026-03-05 08:54:50'),(40,30,'out',6,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 08:55:17','2026-03-05 08:55:17'),(41,31,'in',504,504,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 09:03:04','2026-03-05 09:03:04'),(42,31,'out',504,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 09:03:40','2026-03-05 09:03:40'),(43,32,'in',29,29,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 09:07:07','2026-03-05 09:07:07'),(44,32,'out',29,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 09:07:30','2026-03-05 09:07:30'),(45,4,'out',4,0,'Dispensed to Pharmacy - Batch: BATCH-A',NULL,'2','2026-03-05 09:15:20','2026-03-05 09:15:20'),(46,5,'out',1202,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 09:16:34','2026-03-05 09:16:34'),(47,11,'out',28,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 09:19:31','2026-03-05 09:19:31'),(48,15,'out',90,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 09:21:47','2026-03-05 09:21:47'),(49,19,'out',59,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 09:22:50','2026-03-05 09:22:50'),(50,23,'out',11,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 09:23:36','2026-03-05 09:23:36'),(51,21,'out',40,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 09:25:13','2026-03-05 09:25:13'),(52,8,'out',299,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 09:27:37','2026-03-05 09:27:37'),(53,16,'out',44,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 09:31:27','2026-03-05 09:31:27'),(54,17,'out',490,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 09:35:39','2026-03-05 09:35:39'),(55,9,'out',400,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 09:37:16','2026-03-05 09:37:16'),(56,12,'out',28,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 09:38:56','2026-03-05 09:38:56'),(57,13,'out',28,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 09:40:52','2026-03-05 09:40:52'),(58,7,'out',20,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 09:41:32','2026-03-05 09:41:32'),(59,6,'out',400,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 09:44:56','2026-03-05 09:44:56'),(60,20,'out',90,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 09:49:40','2026-03-05 09:49:40'),(61,14,'out',60,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 09:50:10','2026-03-05 09:50:10'),(62,10,'out',1600,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 09:50:36','2026-03-05 09:50:36'),(63,18,'out',180,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 09:51:28','2026-03-05 09:51:28'),(64,22,'out',1100,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 09:51:49','2026-03-05 09:51:49'),(65,33,'in',9,9,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 09:56:56','2026-03-05 09:56:56'),(66,33,'out',9,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 09:57:24','2026-03-05 09:57:24'),(67,4,'in',4,4,'Main Store quantity adjustment',NULL,'system','2026-03-05 09:58:49','2026-03-05 09:58:49'),(68,34,'in',15,15,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 10:07:05','2026-03-05 10:07:05'),(69,34,'out',15,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 10:07:56','2026-03-05 10:07:56'),(70,35,'in',10,10,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 11:24:59','2026-03-05 11:24:59'),(71,36,'in',50,50,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 11:27:11','2026-03-05 11:27:11'),(72,37,'in',100,100,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 11:30:18','2026-03-05 11:30:18'),(73,35,'out',10,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 11:31:42','2026-03-05 11:31:42'),(74,37,'in',20,120,'Main Store quantity adjustment',NULL,'system','2026-03-05 11:34:23','2026-03-05 11:34:23'),(75,37,'out',120,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 11:34:57','2026-03-05 11:34:57'),(76,38,'in',30,30,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 11:38:07','2026-03-05 11:38:07'),(77,38,'out',30,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 11:38:37','2026-03-05 11:38:37'),(78,39,'in',140,140,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 11:43:12','2026-03-05 11:43:12'),(79,39,'out',140,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 11:43:40','2026-03-05 11:43:40'),(80,40,'in',4,4,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 11:49:07','2026-03-05 11:49:07'),(81,40,'out',4,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 11:49:37','2026-03-05 11:49:37'),(82,41,'in',1,1,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 11:53:48','2026-03-05 11:53:48'),(83,41,'out',1,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 11:54:22','2026-03-05 11:54:22'),(84,42,'in',4,4,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 12:01:07','2026-03-05 12:01:07'),(85,42,'out',4,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 12:01:36','2026-03-05 12:01:36'),(86,43,'in',6,6,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 12:08:55','2026-03-05 12:08:55'),(87,43,'out',6,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 12:09:15','2026-03-05 12:09:15'),(88,44,'in',12,12,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 12:17:02','2026-03-05 12:17:02'),(89,44,'out',12,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 12:25:38','2026-03-05 12:25:38'),(90,45,'in',5,5,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 12:29:21','2026-03-05 12:29:21'),(91,45,'out',5,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 12:29:37','2026-03-05 12:29:37'),(92,46,'in',3,3,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 12:33:20','2026-03-05 12:33:20'),(93,46,'out',2,1,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 12:34:30','2026-03-05 12:34:30'),(94,46,'out',1,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 12:35:33','2026-03-05 12:35:33'),(95,47,'in',21,21,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 12:43:58','2026-03-05 12:43:58'),(96,47,'out',21,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 12:44:27','2026-03-05 12:44:27'),(97,48,'in',7,7,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 12:48:03','2026-03-05 12:48:03'),(98,48,'out',7,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 12:48:23','2026-03-05 12:48:23'),(99,49,'in',9,9,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 12:54:11','2026-03-05 12:54:11'),(100,49,'out',9,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 12:54:44','2026-03-05 12:54:44'),(101,50,'in',18,18,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 12:59:38','2026-03-05 12:59:38'),(102,50,'out',18,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 12:59:53','2026-03-05 12:59:53'),(103,51,'in',80,80,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 13:05:00','2026-03-05 13:05:00'),(104,51,'out',80,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 13:05:16','2026-03-05 13:05:16'),(105,52,'in',54,54,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 13:08:28','2026-03-05 13:08:28'),(106,52,'out',54,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 13:08:48','2026-03-05 13:08:48'),(107,53,'in',456,456,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 13:14:55','2026-03-05 13:14:55'),(108,53,'out',456,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 13:15:13','2026-03-05 13:15:13'),(109,54,'in',3,3,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 13:20:00','2026-03-05 13:20:00'),(110,54,'out',3,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 13:21:13','2026-03-05 13:21:13'),(111,55,'in',21,21,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 13:25:23','2026-03-05 13:25:23'),(112,55,'out',21,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 13:25:36','2026-03-05 13:25:36'),(113,56,'in',10,10,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 13:33:45','2026-03-05 13:33:45'),(114,56,'out',10,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 13:34:10','2026-03-05 13:34:10'),(115,57,'in',10,10,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 13:36:00','2026-03-05 13:36:00'),(116,57,'in',20,30,'Main Store quantity adjustment',NULL,'system','2026-03-05 13:36:48','2026-03-05 13:36:48'),(117,57,'out',30,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 13:37:05','2026-03-05 13:37:05'),(118,58,'in',80,80,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 13:39:46','2026-03-05 13:39:46'),(119,58,'out',80,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 13:40:00','2026-03-05 13:40:00'),(120,59,'in',30,30,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 13:43:42','2026-03-05 13:43:42'),(121,59,'out',30,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 13:44:04','2026-03-05 13:44:04'),(122,60,'in',19,19,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 13:46:57','2026-03-05 13:46:57'),(123,60,'out',19,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 13:47:19','2026-03-05 13:47:19'),(124,61,'in',19,19,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 13:51:15','2026-03-05 13:51:15'),(125,61,'out',19,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 13:51:30','2026-03-05 13:51:30'),(126,58,'in',400,400,'Main Store quantity adjustment',NULL,'system','2026-03-05 13:53:15','2026-03-05 13:53:15'),(127,58,'out',400,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 13:53:58','2026-03-05 13:53:58'),(128,62,'in',500,500,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 13:56:59','2026-03-05 13:56:59'),(129,62,'out',500,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 13:57:20','2026-03-05 13:57:20'),(130,63,'in',400,400,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 13:59:48','2026-03-05 13:59:48'),(131,63,'out',400,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 14:00:09','2026-03-05 14:00:09'),(132,64,'in',100,100,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 14:03:02','2026-03-05 14:03:02'),(133,64,'out',100,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 14:03:19','2026-03-05 14:03:19'),(134,65,'in',100,100,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 14:05:44','2026-03-05 14:05:44'),(135,65,'out',100,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 14:06:02','2026-03-05 14:06:02'),(136,64,'in',800,800,'Main Store quantity adjustment',NULL,'system','2026-03-05 14:07:18','2026-03-05 14:07:18'),(137,64,'out',800,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 14:07:34','2026-03-05 14:07:34'),(138,66,'in',400,400,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 14:10:16','2026-03-05 14:10:16'),(139,66,'out',400,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 14:11:14','2026-03-05 14:11:14'),(140,67,'in',84,84,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 14:14:24','2026-03-05 14:14:24'),(141,67,'out',84,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 14:14:42','2026-03-05 14:14:42'),(142,68,'in',200,200,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 14:17:38','2026-03-05 14:17:38'),(143,68,'out',200,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 14:17:56','2026-03-05 14:17:56'),(144,69,'in',200,200,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 14:20:11','2026-03-05 14:20:11'),(145,69,'out',195,5,'Main Store quantity adjustment',NULL,'system','2026-03-05 14:20:32','2026-03-05 14:20:32'),(146,69,'out',5,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 14:21:09','2026-03-05 14:21:09'),(147,70,'in',690,690,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 14:26:51','2026-03-05 14:26:51'),(148,70,'out',690,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 14:27:08','2026-03-05 14:27:08'),(149,71,'in',7,7,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 14:29:36','2026-03-05 14:29:36'),(150,71,'out',7,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 14:29:51','2026-03-05 14:29:51'),(151,72,'in',24,24,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 14:32:24','2026-03-05 14:32:24'),(152,72,'out',24,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 14:32:40','2026-03-05 14:32:40'),(153,73,'in',46,46,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 14:35:43','2026-03-05 14:35:43'),(154,73,'out',46,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 14:36:00','2026-03-05 14:36:00'),(155,74,'in',24,24,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 14:38:56','2026-03-05 14:38:56'),(156,74,'out',24,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 14:39:19','2026-03-05 14:39:19'),(157,75,'in',15,15,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 14:43:10','2026-03-05 14:43:10'),(158,75,'out',15,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 14:43:36','2026-03-05 14:43:36'),(159,76,'in',8,8,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 14:47:56','2026-03-05 14:47:56'),(160,76,'out',8,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 14:48:11','2026-03-05 14:48:11'),(161,77,'in',26,26,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 14:50:00','2026-03-05 14:50:00'),(162,77,'out',26,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 14:50:15','2026-03-05 14:50:15'),(163,78,'in',700,700,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 14:53:31','2026-03-05 14:53:31'),(164,78,'out',700,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 14:53:45','2026-03-05 14:53:45'),(165,79,'in',10,10,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 14:57:07','2026-03-05 14:57:07'),(166,79,'out',10,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 14:57:35','2026-03-05 14:57:35'),(167,80,'in',20,20,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 14:58:06','2026-03-05 14:58:06'),(168,80,'out',20,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 14:58:23','2026-03-05 14:58:23'),(169,81,'in',1200,1200,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 15:01:39','2026-03-05 15:01:39'),(170,81,'out',1200,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 15:02:01','2026-03-05 15:02:01'),(171,82,'in',500,500,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 15:03:06','2026-03-05 15:03:06'),(172,82,'out',500,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 15:03:29','2026-03-05 15:03:29'),(173,83,'in',600,600,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 15:04:58','2026-03-05 15:04:58'),(174,83,'out',600,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 15:05:16','2026-03-05 15:05:16'),(175,84,'in',600,600,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 15:07:02','2026-03-05 15:07:02'),(176,84,'out',600,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 15:07:27','2026-03-05 15:07:27'),(177,85,'in',700,700,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 15:08:22','2026-03-05 15:08:22'),(178,85,'out',700,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 15:08:38','2026-03-05 15:08:38'),(179,86,'in',40,40,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 15:11:50','2026-03-05 15:11:50'),(180,86,'out',40,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 15:12:14','2026-03-05 15:12:14'),(181,87,'in',11,11,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 15:13:54','2026-03-05 15:13:54'),(182,87,'out',11,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 15:14:22','2026-03-05 15:14:22'),(183,88,'in',60,60,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 15:16:12','2026-03-05 15:16:12'),(184,89,'in',55,55,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 15:19:30','2026-03-05 15:19:30'),(185,89,'out',55,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 15:19:46','2026-03-05 15:19:46'),(186,90,'in',22,22,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 15:21:54','2026-03-05 15:21:54'),(187,90,'out',22,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 15:22:14','2026-03-05 15:22:14'),(188,91,'in',6,6,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 15:24:48','2026-03-05 15:24:48'),(189,91,'out',6,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 15:25:07','2026-03-05 15:25:07'),(190,92,'in',11,11,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 15:28:13','2026-03-05 15:28:13'),(191,92,'out',11,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 15:28:27','2026-03-05 15:28:27'),(192,93,'in',15,15,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 15:30:21','2026-03-05 15:30:21'),(193,93,'out',15,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 15:30:39','2026-03-05 15:30:39'),(194,94,'in',15,15,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 15:31:51','2026-03-05 15:31:51'),(195,94,'out',15,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 15:32:05','2026-03-05 15:32:05'),(196,95,'in',11,11,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 15:33:40','2026-03-05 15:33:40'),(197,95,'out',11,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 15:34:00','2026-03-05 15:34:00'),(198,96,'in',15,15,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 15:36:13','2026-03-05 15:36:13'),(199,96,'out',15,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 15:36:28','2026-03-05 15:36:28'),(200,97,'in',18,18,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 15:41:15','2026-03-05 15:41:15'),(201,97,'out',18,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 15:41:33','2026-03-05 15:41:33'),(202,98,'in',9,9,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-05 15:42:40','2026-03-05 15:42:40'),(203,98,'out',9,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 15:42:57','2026-03-05 15:42:57'),(204,36,'out',50,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-05 15:44:19','2026-03-05 15:44:19'),(205,65,'in',200,200,'Main Store quantity adjustment',NULL,'system','2026-03-06 11:09:07','2026-03-06 11:09:07'),(206,65,'out',200,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-06 11:09:29','2026-03-06 11:09:29'),(207,99,'in',56,56,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-06 11:19:56','2026-03-06 11:19:56'),(208,99,'out',56,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-06 11:20:09','2026-03-06 11:20:09'),(209,68,'in',600,600,'Main Store quantity adjustment',NULL,'system','2026-03-06 11:20:58','2026-03-06 11:20:58'),(210,68,'out',600,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-06 11:21:14','2026-03-06 11:21:14'),(211,100,'in',80,80,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-06 11:33:52','2026-03-06 11:33:52'),(212,100,'out',80,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-06 11:34:07','2026-03-06 11:34:07'),(213,101,'in',1900,1900,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-06 11:37:02','2026-03-06 11:37:02'),(214,101,'out',1900,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-06 11:37:20','2026-03-06 11:37:20'),(215,35,'in',100,100,'Main Store quantity adjustment',NULL,'system','2026-03-06 11:37:50','2026-03-06 11:37:50'),(216,33,'in',30,30,'Main Store quantity adjustment',NULL,'system','2026-03-06 11:38:39','2026-03-06 11:38:39'),(217,33,'out',30,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-06 11:38:58','2026-03-06 11:38:58'),(218,102,'in',15,15,'Initial stock - Drug created from Main Store',NULL,'system','2026-03-06 11:40:48','2026-03-06 11:40:48'),(219,102,'out',15,0,'Dispensed to Pharmacy - Batch: ',NULL,'2','2026-03-06 11:41:11','2026-03-06 11:41:11');
/*!40000 ALTER TABLE `inventory_transactions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `job_batches`
--

DROP TABLE IF EXISTS `job_batches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `job_batches` (
  `id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `total_jobs` int NOT NULL,
  `pending_jobs` int NOT NULL,
  `failed_jobs` int NOT NULL,
  `failed_job_ids` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `options` mediumtext COLLATE utf8mb4_unicode_ci,
  `cancelled_at` int DEFAULT NULL,
  `created_at` int NOT NULL,
  `finished_at` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `job_batches`
--

LOCK TABLES `job_batches` WRITE;
/*!40000 ALTER TABLE `job_batches` DISABLE KEYS */;
/*!40000 ALTER TABLE `job_batches` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `jobs`
--

DROP TABLE IF EXISTS `jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `jobs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `queue` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `attempts` tinyint unsigned NOT NULL,
  `reserved_at` int unsigned DEFAULT NULL,
  `available_at` int unsigned NOT NULL,
  `created_at` int unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `jobs_queue_index` (`queue`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `jobs`
--

LOCK TABLES `jobs` WRITE;
/*!40000 ALTER TABLE `jobs` DISABLE KEYS */;
/*!40000 ALTER TABLE `jobs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `kenya_locations`
--

DROP TABLE IF EXISTS `kenya_locations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `kenya_locations` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `county` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `sub_county` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `ward` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `kenya_locations_county_index` (`county`),
  KEY `kenya_locations_county_sub_county_index` (`county`,`sub_county`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `kenya_locations`
--

LOCK TABLES `kenya_locations` WRITE;
/*!40000 ALTER TABLE `kenya_locations` DISABLE KEYS */;
/*!40000 ALTER TABLE `kenya_locations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lab_request_tests`
--

DROP TABLE IF EXISTS `lab_request_tests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `lab_request_tests` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `lab_request_id` bigint unsigned NOT NULL,
  `test_template_id` bigint unsigned NOT NULL,
  `status` enum('pending','processing','completed') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `priority` enum('routine','urgent','stat') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'routine',
  `notes` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `lab_request_tests_test_template_id_foreign` (`test_template_id`),
  KEY `lab_request_tests_lab_request_id_status_index` (`lab_request_id`,`status`),
  KEY `lab_request_tests_status_index` (`status`),
  CONSTRAINT `lab_request_tests_lab_request_id_foreign` FOREIGN KEY (`lab_request_id`) REFERENCES `lab_requests` (`id`) ON DELETE CASCADE,
  CONSTRAINT `lab_request_tests_test_template_id_foreign` FOREIGN KEY (`test_template_id`) REFERENCES `lab_test_templates` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lab_request_tests`
--

LOCK TABLES `lab_request_tests` WRITE;
/*!40000 ALTER TABLE `lab_request_tests` DISABLE KEYS */;
INSERT INTO `lab_request_tests` VALUES (1,1,5,'pending','routine',NULL,'2026-03-04 18:18:54','2026-03-04 18:18:54'),(2,2,1,'pending','routine',NULL,'2026-03-04 18:22:39','2026-03-04 18:22:39'),(3,3,7,'pending','routine',NULL,'2026-03-06 12:03:19','2026-03-06 12:03:19'),(4,4,6,'pending','routine',NULL,'2026-03-06 12:06:15','2026-03-06 12:06:15'),(5,5,6,'pending','routine',NULL,'2026-03-06 12:36:32','2026-03-06 12:36:32'),(6,6,1,'completed','routine',NULL,'2026-03-06 12:37:15','2026-03-06 12:39:47'),(7,6,16,'completed','routine',NULL,'2026-03-06 12:37:15','2026-03-06 12:40:03');
/*!40000 ALTER TABLE `lab_request_tests` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lab_requests`
--

DROP TABLE IF EXISTS `lab_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `lab_requests` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `request_number` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `patient_id` bigint unsigned NOT NULL,
  `doctor_id` bigint unsigned NOT NULL,
  `treatment_id` bigint unsigned DEFAULT NULL,
  `visit_id` bigint unsigned DEFAULT NULL,
  `priority` enum('routine','urgent','stat') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'routine',
  `clinical_notes` text COLLATE utf8mb4_unicode_ci COMMENT 'Symptoms, suspected diagnosis',
  `request_date` timestamp NOT NULL,
  `status` enum('pending','sample_collected','processing','completed','cancelled','rejected') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `lab_technician_id` bigint unsigned DEFAULT NULL,
  `reviewed_by` bigint unsigned DEFAULT NULL,
  `reviewed_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `created_by` bigint unsigned DEFAULT NULL,
  `updated_by` bigint unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `lab_requests_request_number_unique` (`request_number`),
  KEY `lab_requests_lab_technician_id_foreign` (`lab_technician_id`),
  KEY `lab_requests_reviewed_by_foreign` (`reviewed_by`),
  KEY `lab_requests_patient_id_status_index` (`patient_id`,`status`),
  KEY `lab_requests_created_at_priority_index` (`created_at`,`priority`),
  KEY `lab_requests_visit_id_index` (`visit_id`),
  KEY `lab_requests_priority_index` (`priority`),
  KEY `lab_requests_request_date_index` (`request_date`),
  KEY `lab_requests_status_index` (`status`),
  KEY `lab_requests_doctor_id_foreign` (`doctor_id`),
  KEY `idx_lab_requests_created_at` (`created_at`),
  KEY `lab_requests_created_by_foreign` (`created_by`),
  KEY `lab_requests_updated_by_foreign` (`updated_by`),
  KEY `idx_lab_requests_patient_id` (`patient_id`),
  KEY `idx_lab_requests_treatment_id` (`treatment_id`),
  KEY `idx_lab_requests_status` (`status`),
  CONSTRAINT `lab_requests_created_by_foreign` FOREIGN KEY (`created_by`) REFERENCES `staff` (`id`) ON DELETE SET NULL,
  CONSTRAINT `lab_requests_doctor_id_foreign` FOREIGN KEY (`doctor_id`) REFERENCES `doctors` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `lab_requests_lab_technician_id_foreign` FOREIGN KEY (`lab_technician_id`) REFERENCES `staff` (`id`) ON DELETE SET NULL,
  CONSTRAINT `lab_requests_patient_id_foreign` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `lab_requests_reviewed_by_foreign` FOREIGN KEY (`reviewed_by`) REFERENCES `staff` (`id`) ON DELETE SET NULL,
  CONSTRAINT `lab_requests_treatment_id_foreign` FOREIGN KEY (`treatment_id`) REFERENCES `treatments` (`id`) ON DELETE SET NULL,
  CONSTRAINT `lab_requests_updated_by_foreign` FOREIGN KEY (`updated_by`) REFERENCES `staff` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lab_requests`
--

LOCK TABLES `lab_requests` WRITE;
/*!40000 ALTER TABLE `lab_requests` DISABLE KEYS */;
INSERT INTO `lab_requests` VALUES (1,'LAB-20260304-0001',1,4,2,NULL,'routine','Fever','2026-03-04 18:18:54','processing',NULL,NULL,NULL,'2026-03-04 18:18:54','2026-03-04 18:19:38',NULL,NULL),(2,'LAB-20260304-0002',1,4,2,NULL,'routine','Fever','2026-03-04 18:22:39','processing',NULL,NULL,NULL,'2026-03-04 18:22:39','2026-03-04 18:25:16',NULL,NULL),(3,'LAB-20260306-0001',6,6,5,NULL,'routine',NULL,'2026-03-06 12:03:19','processing',NULL,NULL,NULL,'2026-03-06 12:03:19','2026-03-06 12:04:06',NULL,NULL),(4,'LAB-20260306-0002',6,6,5,NULL,'routine',NULL,'2026-03-06 12:06:15','processing',NULL,NULL,NULL,'2026-03-06 12:06:15','2026-03-06 12:06:42',NULL,NULL),(5,'LAB-20260306-0003',7,4,6,NULL,'routine',NULL,'2026-03-06 12:36:32','pending',NULL,NULL,NULL,'2026-03-06 12:36:32','2026-03-06 12:36:32',NULL,NULL),(6,'LAB-20260306-0004',7,4,7,NULL,'routine',NULL,'2026-03-06 12:37:15','completed',NULL,NULL,'2026-03-06 12:40:03','2026-03-06 12:37:15','2026-03-06 12:40:03',NULL,NULL);
/*!40000 ALTER TABLE `lab_requests` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lab_result_parameters`
--

DROP TABLE IF EXISTS `lab_result_parameters`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `lab_result_parameters` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `lab_result_id` bigint unsigned NOT NULL,
  `parameter_id` bigint unsigned NOT NULL,
  `value` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `unit` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_abnormal` tinyint(1) NOT NULL DEFAULT '0',
  `abnormal_flag` enum('','L','H','LL','HH') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'L=Low, H=High, LL=Critical Low, HH=Critical High',
  `reference_range` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `comment` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `lab_result_parameters_parameter_id_foreign` (`parameter_id`),
  KEY `lab_result_parameters_lab_result_id_is_abnormal_index` (`lab_result_id`,`is_abnormal`),
  KEY `lab_result_parameters_is_abnormal_index` (`is_abnormal`),
  CONSTRAINT `lab_result_parameters_lab_result_id_foreign` FOREIGN KEY (`lab_result_id`) REFERENCES `lab_results` (`id`) ON DELETE CASCADE,
  CONSTRAINT `lab_result_parameters_parameter_id_foreign` FOREIGN KEY (`parameter_id`) REFERENCES `lab_test_parameters` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=51 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lab_result_parameters`
--

LOCK TABLES `lab_result_parameters` WRITE;
/*!40000 ALTER TABLE `lab_result_parameters` DISABLE KEYS */;
INSERT INTO `lab_result_parameters` VALUES (30,11,38,'4','10⁹/L',0,'','4.000 - 10.000 10⁹/L',NULL,'2026-03-06 12:39:47','2026-03-06 12:39:47'),(31,11,39,'6','10⁹/L',0,'','1.800 - 7.000 10⁹/L',NULL,'2026-03-06 12:39:47','2026-03-06 12:39:47'),(32,11,40,'7','10⁹/L',1,'H','0.800 - 4.000 10⁹/L',NULL,'2026-03-06 12:39:47','2026-03-06 12:39:47'),(33,11,41,'9','10⁹/L',1,'H','0.100 - 1.200 10⁹/L',NULL,'2026-03-06 12:39:47','2026-03-06 12:39:47'),(34,11,42,'2','%',1,'L','40.000 - 75.000 %',NULL,'2026-03-06 12:39:47','2026-03-06 12:39:47'),(35,11,43,'2','%',1,'L','20.000 - 50.000 %',NULL,'2026-03-06 12:39:47','2026-03-06 12:39:47'),(36,11,44,'2','%',1,'L','3.000 - 12.000 %',NULL,'2026-03-06 12:39:47','2026-03-06 12:39:47'),(37,11,45,'2','10¹²/L',1,'L','3.500 - 5.800 10¹²/L',NULL,'2026-03-06 12:39:47','2026-03-06 12:39:47'),(38,11,46,'2','g/dl',1,'L','11.000 - 17.469 g/dl',NULL,'2026-03-06 12:39:47','2026-03-06 12:39:47'),(39,11,47,'5','%',1,'L','35.000 - 54.000 %',NULL,'2026-03-06 12:39:47','2026-03-06 12:39:47'),(40,11,48,'5','fL',1,'L','80.000 - 100.000 fL',NULL,'2026-03-06 12:39:47','2026-03-06 12:39:47'),(41,11,49,'6','pg',1,'L','27.000 - 34.000 pg',NULL,'2026-03-06 12:39:47','2026-03-06 12:39:47'),(42,11,50,'6','g/dl',1,'L','32.000 - 36.000 g/dl',NULL,'2026-03-06 12:39:47','2026-03-06 12:39:47'),(43,11,51,'6','%',1,'L','10.000 - 20.000 %',NULL,'2026-03-06 12:39:47','2026-03-06 12:39:47'),(44,11,52,'6','fL',1,'L','35.000 - 56.000 fL',NULL,'2026-03-06 12:39:47','2026-03-06 12:39:47'),(45,11,53,'6','10⁹/L',1,'L','100.000 - 350.000 10⁹/L',NULL,'2026-03-06 12:39:47','2026-03-06 12:39:47'),(46,11,54,'6','fL',1,'L','6.500 - 12.000 fL',NULL,'2026-03-06 12:39:47','2026-03-06 12:39:47'),(47,11,55,'7','fL',1,'L','9.000 - 20.000 fL',NULL,'2026-03-06 12:39:47','2026-03-06 12:39:47'),(48,11,56,'7','%',1,'H','0.108 - 0.350 %',NULL,'2026-03-06 12:39:47','2026-03-06 12:39:47'),(49,11,57,'4','%',1,'L','11.000 - 45.000 %',NULL,'2026-03-06 12:39:47','2026-03-06 12:39:47'),(50,11,58,'6','10³/µL',1,'L','20.000 - 200.000 10³/µL',NULL,'2026-03-06 12:39:47','2026-03-06 12:39:47');
/*!40000 ALTER TABLE `lab_result_parameters` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lab_results`
--

DROP TABLE IF EXISTS `lab_results`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `lab_results` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `lab_request_test_id` bigint unsigned NOT NULL,
  `lab_request_id` bigint unsigned NOT NULL,
  `test_template_id` bigint unsigned NOT NULL,
  `performed_by` bigint unsigned DEFAULT NULL,
  `verified_by` bigint unsigned DEFAULT NULL,
  `performed_at` timestamp NOT NULL,
  `verified_at` timestamp NULL DEFAULT NULL,
  `status` enum('draft','submitted','verified') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'draft',
  `overall_comment` text COLLATE utf8mb4_unicode_ci,
  `quality_control_passed` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `lab_results_lab_request_test_id_foreign` (`lab_request_test_id`),
  KEY `lab_results_test_template_id_foreign` (`test_template_id`),
  KEY `lab_results_performed_by_foreign` (`performed_by`),
  KEY `lab_results_verified_by_foreign` (`verified_by`),
  KEY `lab_results_lab_request_id_status_index` (`lab_request_id`,`status`),
  KEY `lab_results_performed_at_index` (`performed_at`),
  KEY `lab_results_status_index` (`status`),
  CONSTRAINT `lab_results_lab_request_id_foreign` FOREIGN KEY (`lab_request_id`) REFERENCES `lab_requests` (`id`) ON DELETE CASCADE,
  CONSTRAINT `lab_results_lab_request_test_id_foreign` FOREIGN KEY (`lab_request_test_id`) REFERENCES `lab_request_tests` (`id`) ON DELETE CASCADE,
  CONSTRAINT `lab_results_performed_by_foreign` FOREIGN KEY (`performed_by`) REFERENCES `staff` (`id`) ON DELETE SET NULL,
  CONSTRAINT `lab_results_test_template_id_foreign` FOREIGN KEY (`test_template_id`) REFERENCES `lab_test_templates` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `lab_results_verified_by_foreign` FOREIGN KEY (`verified_by`) REFERENCES `staff` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lab_results`
--

LOCK TABLES `lab_results` WRITE;
/*!40000 ALTER TABLE `lab_results` DISABLE KEYS */;
INSERT INTO `lab_results` VALUES (11,6,6,1,1,NULL,'2026-03-06 12:39:47',NULL,'submitted','Commentt',1,'2026-03-06 12:39:47','2026-03-06 12:39:47'),(12,7,6,16,1,NULL,'2026-03-06 12:40:03',NULL,'submitted','Comment2',1,'2026-03-06 12:40:03','2026-03-06 12:40:03');
/*!40000 ALTER TABLE `lab_results` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lab_samples`
--

DROP TABLE IF EXISTS `lab_samples`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `lab_samples` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `lab_request_id` bigint unsigned NOT NULL,
  `sample_number` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Barcode/unique ID',
  `sample_type` enum('blood','urine','stool','sputum','csf','tissue','swab','fluid','other') COLLATE utf8mb4_unicode_ci NOT NULL,
  `collection_date` timestamp NOT NULL,
  `collected_by` bigint unsigned DEFAULT NULL,
  `volume` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `container_type` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `storage_location` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('collected','received','processing','completed','rejected') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'collected',
  `rejection_reason` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `lab_samples_sample_number_unique` (`sample_number`),
  KEY `lab_samples_lab_request_id_foreign` (`lab_request_id`),
  KEY `lab_samples_collected_by_foreign` (`collected_by`),
  KEY `lab_samples_collection_date_index` (`collection_date`),
  KEY `lab_samples_status_index` (`status`),
  CONSTRAINT `lab_samples_collected_by_foreign` FOREIGN KEY (`collected_by`) REFERENCES `staff` (`id`) ON DELETE SET NULL,
  CONSTRAINT `lab_samples_lab_request_id_foreign` FOREIGN KEY (`lab_request_id`) REFERENCES `lab_requests` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lab_samples`
--

LOCK TABLES `lab_samples` WRITE;
/*!40000 ALTER TABLE `lab_samples` DISABLE KEYS */;
INSERT INTO `lab_samples` VALUES (1,1,'SMP-20260304-00001','urine','2026-03-04 18:19:38',4,'50ml','Sterile urine container',NULL,'collected',NULL,'2026-03-04 18:19:38','2026-03-04 18:19:38'),(2,2,'SMP-20260304-00002','blood','2026-03-04 18:25:16',4,'3ml','EDTA tube (purple top)',NULL,'collected',NULL,'2026-03-04 18:25:16','2026-03-04 18:25:16'),(3,3,'SMP-20260306-00001','blood','2026-03-06 12:04:06',10,NULL,'Microscope Slide',NULL,'collected',NULL,'2026-03-06 12:04:06','2026-03-06 12:04:06'),(4,4,'SMP-20260306-00002','blood','2026-03-06 12:06:42',10,'2ml','Gray top (fluoride)',NULL,'collected',NULL,'2026-03-06 12:06:42','2026-03-06 12:06:42'),(5,6,'SMP-20260306-00003','blood','2026-03-06 12:39:06',1,'3ml','EDTA tube (purple top)',NULL,'collected',NULL,'2026-03-06 12:39:06','2026-03-06 12:39:06');
/*!40000 ALTER TABLE `lab_samples` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lab_test_categories`
--

DROP TABLE IF EXISTS `lab_test_categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `lab_test_categories` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `code` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `lab_test_categories_code_unique` (`code`),
  KEY `lab_test_categories_name_index` (`name`),
  KEY `lab_test_categories_is_active_index` (`is_active`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lab_test_categories`
--

LOCK TABLES `lab_test_categories` WRITE;
/*!40000 ALTER TABLE `lab_test_categories` DISABLE KEYS */;
INSERT INTO `lab_test_categories` VALUES (1,'Hematology','HEM','Blood-related tests',1,'2026-03-04 07:29:43','2026-03-04 07:29:43'),(2,'Biochemistry','BIO','Biochemical analysis',1,'2026-03-04 07:29:43','2026-03-04 07:29:43'),(3,'Microbiology','MICRO','Microbiological analysis',1,'2026-03-04 07:29:43','2026-03-04 07:29:43'),(4,'Serology / Immunology','SERO','Immunological and serological tests',1,'2026-03-04 07:29:43','2026-03-04 07:29:43'),(5,'Pathology','PATH','Tissue and cellular analysis',1,'2026-03-04 07:29:43','2026-03-04 07:29:43'),(6,'Urinalysis','URINE','Urine tests',1,'2026-03-04 07:29:43','2026-03-04 07:29:43'),(7,'Stool Analysis','STOOL','Stool tests',1,'2026-03-04 07:29:43','2026-03-04 07:29:43'),(8,'Endocrinology','ENDO','Hormone and endocrine tests',1,'2026-03-04 07:29:43','2026-03-04 07:29:43'),(9,'Blood Bank','BB','Blood banking and transfusion tests',1,'2026-03-04 07:29:43','2026-03-04 07:29:43'),(10,'Other','OTHER','Other laboratory tests',1,'2026-03-04 07:29:43','2026-03-04 07:29:43'),(11,'Parasitology','PARA','Parasitic organism and infection tests',1,'2026-03-04 07:29:50','2026-03-04 07:29:50'),(12,'Virology','VIRO','Viral infection and detection tests',1,'2026-03-04 07:29:50','2026-03-04 07:29:50');
/*!40000 ALTER TABLE `lab_test_categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lab_test_parameters`
--

DROP TABLE IF EXISTS `lab_test_parameters`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `lab_test_parameters` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `test_template_id` bigint unsigned NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `code` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `result_type` enum('range','binary') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'range',
  `unit` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `normal_range_min` decimal(10,3) DEFAULT NULL,
  `normal_range_max` decimal(10,3) DEFAULT NULL,
  `critical_low` decimal(10,3) DEFAULT NULL,
  `critical_high` decimal(10,3) DEFAULT NULL,
  `decimal_places` int NOT NULL DEFAULT '2',
  `sort_order` int NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `lab_test_parameters_test_template_id_sort_order_index` (`test_template_id`,`sort_order`),
  KEY `lab_test_parameters_name_index` (`name`),
  CONSTRAINT `lab_test_parameters_test_template_id_foreign` FOREIGN KEY (`test_template_id`) REFERENCES `lab_test_templates` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=59 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lab_test_parameters`
--

LOCK TABLES `lab_test_parameters` WRITE;
/*!40000 ALTER TABLE `lab_test_parameters` DISABLE KEYS */;
INSERT INTO `lab_test_parameters` VALUES (1,1,'WBC (White Blood Cells)','WBC','range','10³/μL',4.500,11.000,2.000,20.000,2,1,'2026-03-04 07:29:55','2026-03-05 09:23:08','2026-03-05 09:23:08'),(2,1,'RBC (Red Blood Cells)','RBC','range','10⁶/μL',4.500,5.500,2.500,7.000,2,2,'2026-03-04 07:29:55','2026-03-05 09:26:02','2026-03-05 09:26:02'),(3,1,'Hemoglobin','HGB','range','g/dL',12.000,16.000,7.000,20.000,1,3,'2026-03-04 07:29:55','2026-03-05 09:26:12','2026-03-05 09:26:12'),(4,1,'Hematocrit','HCT','range','%',37.000,47.000,20.000,60.000,1,4,'2026-03-04 07:29:55','2026-03-05 09:26:28','2026-03-05 09:26:28'),(5,1,'Platelets','PLT','range','10³/μL',150.000,400.000,50.000,1000.000,0,5,'2026-03-04 07:29:56','2026-03-05 09:26:20','2026-03-05 09:26:20'),(6,1,'MCV (Mean Corpuscular Volume)','MCV','range','fL',80.000,100.000,NULL,NULL,1,6,'2026-03-04 07:29:56','2026-03-05 09:26:38','2026-03-05 09:26:38'),(7,2,'Total Cholesterol','CHOL','range','mg/dL',0.000,200.000,NULL,300.000,0,1,'2026-03-04 07:29:56','2026-03-04 07:29:56',NULL),(8,2,'HDL Cholesterol','HDL','range','mg/dL',40.000,60.000,20.000,NULL,0,2,'2026-03-04 07:29:56','2026-03-04 07:29:56',NULL),(9,2,'LDL Cholesterol','LDL','range','mg/dL',0.000,100.000,NULL,190.000,0,3,'2026-03-04 07:29:56','2026-03-04 07:29:56',NULL),(10,2,'Triglycerides','TRIG','range','mg/dL',0.000,150.000,NULL,500.000,0,4,'2026-03-04 07:29:56','2026-03-04 07:29:56',NULL),(11,3,'ALT (Alanine Aminotransferase)','ALT','range','U/L',7.000,56.000,NULL,300.000,0,1,'2026-03-04 07:29:56','2026-03-04 07:29:56',NULL),(12,3,'AST (Aspartate Aminotransferase)','AST','range','U/L',10.000,40.000,NULL,300.000,0,2,'2026-03-04 07:29:56','2026-03-04 07:29:56',NULL),(13,3,'ALP (Alkaline Phosphatase)','ALP','range','U/L',44.000,147.000,NULL,500.000,0,3,'2026-03-04 07:29:56','2026-03-04 07:29:56',NULL),(14,3,'Total Bilirubin','TBIL','range','mg/dL',0.100,1.200,NULL,10.000,2,4,'2026-03-04 07:29:56','2026-03-04 07:29:56',NULL),(15,3,'Albumin','ALB','range','g/dL',3.500,5.500,2.000,NULL,1,5,'2026-03-04 07:29:56','2026-03-04 07:29:56',NULL),(16,4,'Creatinine','CREAT','range','mg/dL',0.600,1.200,NULL,10.000,2,1,'2026-03-04 07:29:56','2026-03-04 07:29:56',NULL),(17,4,'Blood Urea Nitrogen (BUN)','BUN','range','mg/dL',7.000,20.000,NULL,100.000,0,2,'2026-03-04 07:29:56','2026-03-04 07:29:56',NULL),(18,4,'Sodium','NA','range','mEq/L',136.000,145.000,120.000,160.000,0,3,'2026-03-04 07:29:56','2026-03-04 07:29:56',NULL),(19,4,'Potassium','K','range','mEq/L',3.500,5.000,2.500,6.500,1,4,'2026-03-04 07:29:56','2026-03-04 07:29:56',NULL),(20,5,'pH','PH','range','',4.500,8.000,NULL,NULL,1,1,'2026-03-04 07:29:56','2026-03-04 07:29:56',NULL),(21,5,'Specific Gravity','SG','range','',1.005,1.030,NULL,NULL,3,2,'2026-03-04 07:29:56','2026-03-04 07:29:56',NULL),(22,5,'Protein','PROT','range','mg/dL',0.000,10.000,NULL,300.000,0,3,'2026-03-04 07:29:56','2026-03-04 07:29:56',NULL),(23,5,'Glucose','GLU','range','mg/dL',0.000,0.000,NULL,1000.000,0,4,'2026-03-04 07:29:56','2026-03-04 07:29:56',NULL),(24,6,'Glucose','GLU','range','mg/dL',70.000,100.000,40.000,400.000,0,1,'2026-03-04 07:29:56','2026-03-05 07:57:13','2026-03-05 07:57:13'),(25,7,'Bs For Mps','Bs','range','hpf',NULL,NULL,NULL,NULL,2,10,'2026-03-05 07:55:32','2026-03-05 07:55:32',NULL),(26,6,'Fasting Blood Sugar','FBS','range','mmol/L',4.000,35.000,NULL,NULL,2,10,'2026-03-05 07:57:53','2026-03-05 07:57:53',NULL),(27,6,'Random Blood Sugar','RBS','range','mmol/L',4.000,34.987,NULL,NULL,2,20,'2026-03-05 07:58:28','2026-03-05 07:58:41','2026-03-05 07:58:41'),(28,6,'Random Blood Sugar','RBS','range','mmol/L',4.000,35.000,NULL,NULL,2,20,'2026-03-05 07:59:14','2026-03-05 07:59:14',NULL),(29,11,'H Pylori','H.pylori','binary',NULL,NULL,NULL,NULL,NULL,2,10,'2026-03-05 08:05:39','2026-03-05 08:05:39',NULL),(30,8,'Pregnancy Detection Test','PDT','binary',NULL,NULL,NULL,NULL,NULL,2,10,'2026-03-05 08:06:07','2026-03-05 08:06:07',NULL),(31,10,'SAT','IgG','binary',NULL,NULL,NULL,NULL,NULL,2,10,'2026-03-05 08:06:46','2026-03-05 08:06:46',NULL),(32,10,'SAT','IgM','binary',NULL,NULL,NULL,NULL,NULL,2,20,'2026-03-05 08:07:06','2026-03-05 08:07:06',NULL),(33,9,'Arbortus','A','binary',NULL,NULL,NULL,NULL,NULL,2,10,'2026-03-05 08:08:44','2026-03-05 08:08:44',NULL),(34,9,'Melitensis','M','binary',NULL,NULL,NULL,NULL,NULL,2,20,'2026-03-05 08:09:03','2026-03-05 08:09:03',NULL),(35,14,'ASOT','ASOT','binary',NULL,NULL,NULL,NULL,NULL,2,10,'2026-03-05 08:30:11','2026-03-05 08:30:11',NULL),(36,13,'Rheumatoid Factor','RF','binary',NULL,NULL,NULL,NULL,NULL,2,10,'2026-03-05 08:30:41','2026-03-05 08:30:41',NULL),(37,15,'VDRL','VDRL','binary',NULL,NULL,NULL,NULL,NULL,2,10,'2026-03-05 08:32:14','2026-03-05 08:32:14',NULL),(38,1,'White Blood Cell Count','WBC','range','10⁹/L',4.000,10.000,NULL,NULL,2,16,'2026-03-05 09:24:16','2026-03-05 09:24:16',NULL),(39,1,'Neutrophils Absolute Count','Neu#','range','10⁹/L',1.800,7.000,NULL,NULL,2,26,'2026-03-05 09:25:43','2026-03-05 09:25:43',NULL),(40,1,'Lymphocytes Absolute Count','Lym#','range','10⁹/L',0.800,4.000,NULL,NULL,2,36,'2026-03-05 09:28:52','2026-03-05 09:28:52',NULL),(41,1,'Mixed Cells Absolute Count','Mxd#','range','10⁹/L',0.100,1.200,NULL,NULL,2,46,'2026-03-05 09:30:53','2026-03-05 09:30:53',NULL),(42,1,'Neutrophils Percentage','Neu%','range','%',40.000,75.000,NULL,NULL,2,56,'2026-03-05 09:34:11','2026-03-05 09:34:11',NULL),(43,1,'Lymphocytes Percentage','Lym%','range','%',20.000,50.000,NULL,NULL,2,66,'2026-03-05 09:34:59','2026-03-05 09:34:59',NULL),(44,1,'Mixed Cells Percentage','Mxd%','range','%',3.000,12.000,NULL,NULL,2,76,'2026-03-05 09:35:55','2026-03-05 09:35:55',NULL),(45,1,'Red Blood Cell Count','RBC','range','10¹²/L',3.500,5.800,NULL,NULL,2,86,'2026-03-05 09:37:22','2026-03-05 09:37:22',NULL),(46,1,'Hemoglobin','HGB','range','g/dl',11.000,17.469,NULL,NULL,2,96,'2026-03-05 09:39:33','2026-03-05 09:39:33',NULL),(47,1,'Hematocrit','HCT','range','%',35.000,54.000,NULL,NULL,2,106,'2026-03-05 09:41:56','2026-03-05 09:41:56',NULL),(48,1,'Mean Corpuscular Volume','MCV','range','fL',80.000,100.000,NULL,NULL,2,116,'2026-03-05 09:43:31','2026-03-05 09:43:31',NULL),(49,1,'Mean Corpuscular Hemoglobin','MCH','range','pg',27.000,34.000,NULL,NULL,2,126,'2026-03-05 09:45:12','2026-03-05 09:45:12',NULL),(50,1,'Mean Corpuscular Hemoglobin Concentration','MCHC','range','g/dl',32.000,36.000,NULL,NULL,2,136,'2026-03-05 09:46:39','2026-03-05 09:46:39',NULL),(51,1,'Red Cell Distribution Width, Coefficient of Variation','RDW-CV','range','%',10.000,20.000,NULL,NULL,2,146,'2026-03-05 09:49:03','2026-03-05 09:49:03',NULL),(52,1,'Red Cell Distribution Width, Standard Deviation','RDW-SD','range','fL',35.000,56.000,NULL,NULL,2,156,'2026-03-05 10:01:33','2026-03-05 10:01:33',NULL),(53,1,'Platelet Count','PLT','range','10⁹/L',100.000,350.000,NULL,NULL,2,166,'2026-03-05 10:02:41','2026-03-05 10:02:41',NULL),(54,1,'Mean Platelet Volume','MPV','range','fL',6.500,12.000,NULL,NULL,2,176,'2026-03-05 10:08:21','2026-03-05 10:08:21',NULL),(55,1,'Platelet Distribution Width','PDW','range','fL',9.000,20.000,NULL,NULL,2,186,'2026-03-05 10:11:13','2026-03-05 10:11:13',NULL),(56,1,'Plateletcrit','PCT','range','%',0.108,0.350,NULL,NULL,2,196,'2026-03-05 10:12:42','2026-03-05 10:12:42',NULL),(57,1,'Platelet Large Cell Ratio','P-LCR','range','%',11.000,45.000,NULL,NULL,2,206,'2026-03-05 10:14:38','2026-03-05 10:14:38',NULL),(58,1,'Platelet Large Cell Count','P-LCC','range','10³/µL',20.000,200.000,NULL,NULL,2,216,'2026-03-05 10:15:41','2026-03-05 10:15:41',NULL);
/*!40000 ALTER TABLE `lab_test_parameters` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lab_test_templates`
--

DROP TABLE IF EXISTS `lab_test_templates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `lab_test_templates` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `category_id` bigint unsigned NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `code` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `sample_type` enum('blood','urine','stool','sputum','csf','tissue','swab','fluid','other') COLLATE utf8mb4_unicode_ci NOT NULL,
  `sample_volume` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `container_type` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `preparation_instructions` text COLLATE utf8mb4_unicode_ci,
  `turn_around_time` int NOT NULL DEFAULT '24' COMMENT 'Hours',
  `price` decimal(10,2) NOT NULL DEFAULT '0.00',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `lab_test_templates_code_unique` (`code`),
  KEY `lab_test_templates_category_id_foreign` (`category_id`),
  KEY `lab_test_templates_name_index` (`name`),
  KEY `lab_test_templates_sample_type_index` (`sample_type`),
  KEY `lab_test_templates_is_active_index` (`is_active`),
  CONSTRAINT `lab_test_templates_category_id_foreign` FOREIGN KEY (`category_id`) REFERENCES `lab_test_categories` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lab_test_templates`
--

LOCK TABLES `lab_test_templates` WRITE;
/*!40000 ALTER TABLE `lab_test_templates` DISABLE KEYS */;
INSERT INTO `lab_test_templates` VALUES (1,1,'Complete Blood Count','CBC','Assesses  overall Health, dentifies conditions like anemia, infections and many other disorders','blood','3ml','EDTA tube (purple top)',NULL,2,800.00,1,'2026-03-04 07:29:55','2026-03-05 08:36:51',NULL),(2,2,'Lipid Profile','LIPID','Evaluates cardiovascular risk by measuring lipid levels  (cholestrol & triglycerides)','blood','5ml','SST tube (gold top)','Fasting for 12 hours required',4,1500.00,1,'2026-03-04 07:29:56','2026-03-05 08:42:43',NULL),(3,2,'Liver Function Tests','LFTs','Assess liver health anf Functions','blood','5ml','SST tube (gold top)',NULL,6,3500.00,1,'2026-03-04 07:29:56','2026-03-05 08:38:11',NULL),(4,2,'Kidney Function Tests','KFT','Assess kidney health','blood','5ml','SST tube (gold top)',NULL,6,900.00,1,'2026-03-04 07:29:56','2026-03-04 07:29:56',NULL),(5,6,'Urinalysis','URINE','Complete urine analysis','urine','50ml','Sterile urine container','Mid-stream clean catch sample',3,300.00,1,'2026-03-04 07:29:56','2026-03-04 07:29:56',NULL),(6,2,'Blood Glucose Levels','RBS/FBS','Measures blood glucose levels to diagnose and monitor diabetes.','blood','2ml','Gray top (fluoride)','Fasting for 8-12 hours required',1,200.00,1,'2026-03-04 07:29:56','2026-03-05 07:57:04',NULL),(7,11,'Bs For Mps','BS','Detects malaria parasites in blood and confirms malaria infection.','blood',NULL,'Microscope Slide',NULL,2,100.00,1,'2026-03-05 07:53:42','2026-03-05 07:53:42',NULL),(8,4,'Pregnancy Detection Test','PDT','Detects human chorionic gonadotropin hormone to confirm pregnancy.','urine',NULL,'Sterile Urine Bottle',NULL,2,100.00,1,'2026-03-05 07:54:55','2026-03-05 07:54:55',NULL),(9,4,'Brucellin Antigen Test','BAT','Detects antibodies against Brucella species to diagnose brucellosis.','blood',NULL,NULL,NULL,2,200.00,1,'2026-03-05 08:00:32','2026-03-05 08:00:32',NULL),(10,3,'Salmonella Antigen Test','SAT','Detects antibodies against Salmonella organisms, commonly used in typhoid diagnosis.','stool',NULL,NULL,NULL,24,500.00,1,'2026-03-05 08:01:45','2026-03-05 08:01:45',NULL),(11,3,'H. Pylori Test','H-pylori','Detects Helicobacter pylori infection linked to gastritis and peptic ulcers','stool',NULL,NULL,NULL,2,500.00,1,'2026-03-05 08:03:09','2026-03-05 08:03:09',NULL),(12,11,'Stool Analysis','O/C','Identifies intestinal parasites, ova, cysts, bacteria, and digestive','stool',NULL,NULL,NULL,2,200.00,1,'2026-03-05 08:13:49','2026-03-05 08:13:49',NULL),(13,4,'Rheumatoid Factor','RF','Detects rheumatoid factor antibodies associated with rheumatoid arthritis.','blood',NULL,NULL,NULL,2,200.00,1,'2026-03-05 08:26:27','2026-03-05 08:26:27',NULL),(14,4,'ASOT','ASOT','Detects antibodies against Streptococcus bacteria, linked to rheumatic fever and post-strep complications.','blood',NULL,NULL,NULL,2,200.00,1,'2026-03-05 08:27:24','2026-03-05 08:27:24',NULL),(15,4,'VDRL','VDRL','Screens for syphilis infection.','blood',NULL,NULL,NULL,24,200.00,1,'2026-03-05 08:31:50','2026-03-05 08:31:50',NULL),(16,1,'Blood Grouping','Blood Group','Determines ABO and Rh blood type for transfusion compatibility.','blood',NULL,NULL,NULL,24,200.00,1,'2026-03-05 08:33:22','2026-03-05 08:33:22',NULL),(17,1,'Hemoglobin Level','HB','Measures haemoglobin concentration to assess anemia or polycythemia.','blood',NULL,NULL,NULL,2,200.00,1,'2026-03-05 08:34:55','2026-03-05 08:34:55',NULL),(18,2,'Electrolyte Panel','UECs','Assesses kidney function and electrolyte balance.','blood',NULL,NULL,NULL,2,2000.00,1,'2026-03-05 08:39:44','2026-03-05 08:39:44',NULL),(19,2,'Thryroid Function Tests','TFTs','Evaluates thyroid gland function.','blood',NULL,NULL,NULL,3,3000.00,1,'2026-03-05 08:44:37','2026-03-05 08:44:37',NULL),(20,2,'Prostrate Antigen Test','PSA','Screens for prostate enlargement, inflammation, or cancer.','blood',NULL,NULL,NULL,24,2500.00,1,'2026-03-05 08:46:05','2026-03-05 08:46:05',NULL),(21,1,'HbA1c','HbA1c','Measures average blood glucose control over the past 2–3 months','blood',NULL,NULL,NULL,2,1500.00,1,'2026-03-05 08:48:31','2026-03-05 08:48:31',NULL);
/*!40000 ALTER TABLE `lab_test_templates` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `migrations`
--

DROP TABLE IF EXISTS `migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `migrations` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `migration` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `batch` int NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=91 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `migrations`
--

LOCK TABLES `migrations` WRITE;
/*!40000 ALTER TABLE `migrations` DISABLE KEYS */;
INSERT INTO `migrations` VALUES (1,'0001_01_01_000000_create_users_table',1),(2,'0001_01_01_000001_create_cache_table',1),(3,'0001_01_01_000002_create_jobs_table',1),(4,'2025_10_10_222933_create_patients_table',1),(5,'2025_10_10_233647_create_treatments_table',1),(6,'2025_10_20_140747_create_doctors_table',1),(7,'2025_10_20_150412_create_appointments_table',1),(8,'2025_10_23_111635_create_suppliers_table',1),(9,'2025_10_23_111636_create_inventory_items_table',1),(10,'2025_10_23_111637_create_inventory_transactions_table',1),(11,'2025_10_26_145745_create_prescriptions_table',1),(12,'2025_10_26_145746_create_prescription_items_table',1),(13,'2025_10_26_190240_add_doctor_id_to_treatments_table',1),(14,'2025_10_26_201006_create_bills_table',1),(15,'2025_10_26_201007_create_bill_items_table',1),(16,'2025_10_26_201008_create_payments_table',1),(17,'2025_10_28_000000_add_treatment_id_to_prescriptions_table',1),(18,'2025_11_01_182327_add_status_columns_to_related_tables',1),(19,'2025_11_02_234052_create_personal_access_tokens_table',1),(20,'2025_11_02_235741_create_staff_table',1),(21,'2025_11_02_235742_create_staff_documents_table',1),(22,'2025_11_12_055448_add_age_to_patients_table',1),(23,'2025_11_12_142200_sync_doctors_with_staff_triggers',1),(24,'2025_11_23_154600_create_queue_table',1),(25,'2025_12_06_034426_create_settings_table',1),(26,'2025_12_06_085915_create_pharmacy_orders_table',1),(27,'2025_12_06_141155_add_pharmacist_and_labtech_roles_to_staff_table',1),(28,'2025_12_06_142757_create_pharmacy_drugs_table',1),(29,'2025_12_06_142803_create_pharmacy_drug_batches_table',1),(30,'2025_12_06_142813_create_pharmacy_prescriptions_table',1),(31,'2025_12_06_142820_create_pharmacy_prescription_items_table',1),(32,'2025_12_06_142826_create_pharmacy_dispensations_table',1),(33,'2025_12_06_143016_create_pharmacy_dispensation_items_table',1),(34,'2025_12_06_143021_create_pharmacy_inventory_transactions_table',1),(35,'2025_12_06_143029_create_pharmacy_drug_interactions_table',1),(36,'2025_12_06_143038_create_pharmacy_stock_alerts_table',1),(37,'2025_12_07_200321_add_pharmacy_status_to_prescriptions_table',1),(38,'2025_12_07_200328_add_text_fields_to_prescription_items_table',1),(39,'2025_12_07_205706_make_inventory_item_id_nullable_in_prescription_items',1),(40,'2025_12_07_212825_add_current_stock_and_update_unit_of_measure_to_pharmacy_drugs',1),(41,'2025_12_07_221811_create_lab_test_categories_table',1),(42,'2025_12_07_221816_create_lab_test_templates_table',1),(43,'2025_12_07_221822_create_lab_test_parameters_table',1),(44,'2025_12_07_221828_create_lab_requests_table',1),(45,'2025_12_07_221836_create_lab_request_tests_table',1),(46,'2025_12_07_221856_create_lab_samples_table',1),(47,'2025_12_07_221904_create_lab_results_table',1),(48,'2025_12_07_221911_create_lab_result_parameters_table',1),(49,'2025_12_07_234405_fix_lab_requests_doctor_foreign_key',1),(50,'2025_12_08_030113_add_lab_fields_to_bill_items_table',1),(51,'2025_12_08_090526_add_notes_to_pharmacy_prescription_items_table',1),(52,'2025_12_08_121000_add_pharmacy_dispensation_refs_to_bill_items_table',1),(53,'2025_12_08_194918_add_index_to_lab_requests_created_at',1),(54,'2025_12_09_013016_add_dispensing_fields_to_prescriptions',1),(55,'2025_12_15_103104_create_triages_table',1),(56,'2025_12_15_141706_add_diagnosis_status_to_treatments_table',1),(57,'2025_12_18_123035_add_structured_notes_to_treatments_table',1),(58,'2025_12_18_140223_add_diagnosis_categories_to_treatments_table',1),(59,'2025_12_18_163739_add_result_type_to_lab_test_parameters_table',1),(60,'2025_12_18_201208_add_soft_deletes_to_lab_test_templates_table',1),(61,'2025_12_29_144952_add_moh_fields_to_treatments_table',1),(62,'2025_12_29_144958_add_geography_and_moh_fields_to_patients_table',1),(63,'2025_12_29_145002_create_moh_supporting_tables',1),(64,'2025_12_29_145008_add_audit_trail_to_other_tables',1),(65,'2026_01_03_144709_update_lab_test_categories_to_standard_list',1),(66,'2026_01_13_053404_add_dispensed_from_stock_to_prescription_items',1),(67,'2026_01_13_103457_add_manual_dispensation_support_to_prescriptions',1),(68,'2026_01_13_160904_add_facility_clerk_role_to_staff',1),(69,'2026_01_22_132908_add_soft_deletes_to_lab_test_parameters_table',1),(70,'2026_01_28_203247_add_pharmacy_drug_id_to_inventory_items_table',1),(71,'2026_01_29_223416_add_soft_deletes_to_prescriptions_table',1),(72,'2026_01_29_223418_add_soft_deletes_to_prescription_items_table',1),(73,'2026_02_06_120825_update_payment_type_enum_in_treatments_table',1),(74,'2026_02_06_134031_create_diagnoses_table',1),(75,'2026_02_09_130232_add_performance_indexes_to_all_tables',1),(76,'2026_02_10_193033_add_treatment_type_to_treatments_table',1),(77,'2026_02_10_193126_add_bill_id_to_treatments_table',1),(78,'2026_02_12_181710_add_payment_method_to_bills_table',1),(79,'2026_02_12_211126_add_parasitology_and_virology_lab_categories',1),(80,'2026_02_15_164842_add_soft_deletes_to_inventory_items',1),(81,'2026_02_15_171116_make_expiry_date_nullable_in_pharmacy_drug_batches_table',1),(82,'2026_02_15_174233_create_pharmacy_reorder_requests_table',1),(83,'2026_02_15_185209_make_batch_number_nullable_in_pharmacy_drug_batches_table',1),(84,'2026_02_15_185213_make_batch_number_nullable_in_pharmacy_drug_batches_table',1),(85,'2026_02_15_191602_make_reorder_level_nullable_in_inventory_items_table',1),(86,'2026_02_16_083547_add_quantity_to_pharmacy_reorder_requests_table',1),(87,'2026_02_25_000001_create_admissions_table',1),(88,'2026_02_25_000002_create_admission_entries_table',1),(89,'2026_02_25_000003_add_admission_id_to_bills_table',1),(90,'2026_02_06_150054_create_notifications_table',2);
/*!40000 ALTER TABLE `migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notifications`
--

DROP TABLE IF EXISTS `notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notifications` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notifications`
--

LOCK TABLES `notifications` WRITE;
/*!40000 ALTER TABLE `notifications` DISABLE KEYS */;
/*!40000 ALTER TABLE `notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `password_reset_tokens`
--

DROP TABLE IF EXISTS `password_reset_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `password_reset_tokens` (
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `password_reset_tokens`
--

LOCK TABLES `password_reset_tokens` WRITE;
/*!40000 ALTER TABLE `password_reset_tokens` DISABLE KEYS */;
/*!40000 ALTER TABLE `password_reset_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `patients`
--

DROP TABLE IF EXISTS `patients`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `patients` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `upid` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `national_id` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `first_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `gender` enum('M','F','O') COLLATE utf8mb4_unicode_ci NOT NULL,
  `dob` date DEFAULT NULL,
  `age` tinyint unsigned DEFAULT NULL,
  `phone` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `address` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `county` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sub_county` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ward` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `village` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `next_of_kin` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `next_of_kin_phone` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `pregnancy_status` enum('yes','no','unknown','na') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'na',
  `has_disability` tinyint(1) NOT NULL DEFAULT '0',
  `disability_type` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_by` bigint unsigned DEFAULT NULL,
  `updated_by` bigint unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `patients_upid_unique` (`upid`),
  UNIQUE KEY `patients_national_id_unique` (`national_id`),
  KEY `patients_created_by_foreign` (`created_by`),
  KEY `patients_updated_by_foreign` (`updated_by`),
  KEY `patients_county_index` (`county`),
  KEY `patients_county_sub_county_index` (`county`,`sub_county`),
  KEY `patients_ward_index` (`ward`),
  KEY `idx_patients_upid` (`upid`),
  KEY `idx_patients_phone` (`phone`),
  KEY `idx_patients_email` (`email`),
  KEY `idx_patients_national_id` (`national_id`),
  KEY `idx_patients_created_at` (`created_at`),
  CONSTRAINT `patients_created_by_foreign` FOREIGN KEY (`created_by`) REFERENCES `staff` (`id`) ON DELETE SET NULL,
  CONSTRAINT `patients_updated_by_foreign` FOREIGN KEY (`updated_by`) REFERENCES `staff` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `patients`
--

LOCK TABLES `patients` WRITE;
/*!40000 ALTER TABLE `patients` DISABLE KEYS */;
INSERT INTO `patients` VALUES (1,'HMS-69A7DF7370A79',NULL,'Samuel','Orwa','M','2017-02-01',NULL,'0543088033','samuel.orwa@example.com','Saudi Arabia, Dhahran',NULL,NULL,NULL,NULL,NULL,NULL,'na',0,NULL,NULL,NULL,'2026-03-04 07:29:55','2026-03-04 07:29:55'),(2,'HMS-69A7DF7370A91',NULL,'Mary','Achieng','F','1990-07-21',NULL,'0733333333','mary.achieng@example.com','Nairobi, Kenya',NULL,NULL,NULL,NULL,NULL,NULL,'na',0,NULL,NULL,NULL,'2026-03-04 07:29:55','2026-03-04 07:29:55'),(3,'BH-0001',NULL,'SAMMY WAFULA','SONGWA','M','2001-01-19',25,'0707379815','sammysongwa@gmail.com','Kimilili',NULL,NULL,NULL,NULL,NULL,NULL,'na',0,NULL,2,NULL,'2026-03-05 04:54:53','2026-03-05 04:54:53'),(4,'BH-0002',NULL,'Selina','Wanyama','F','2007-03-04',19,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'na',0,NULL,2,NULL,'2026-03-05 14:44:29','2026-03-05 14:44:29'),(5,'BH-0003',NULL,'Linet','Kachukha','F','1984-03-04',42,'0717273588',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'na',0,NULL,2,2,'2026-03-05 15:37:11','2026-03-06 11:55:05'),(6,'BH-0004',NULL,'Test','Patient 1','F','1994-03-05',32,'0701430851',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'na',0,NULL,2,NULL,'2026-03-06 05:34:30','2026-03-06 05:34:30'),(7,'BH-0005',NULL,'Test','Patient2','M','2014-03-05',12,'0701430850',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'na',0,NULL,1,NULL,'2026-03-06 12:35:43','2026-03-06 12:35:43'),(8,'BH-0006',NULL,'Sick','Patient','M','2022-03-05',4,NULL,'sickpatient1@gmail.com',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'na',0,NULL,1,NULL,'2026-03-06 12:59:32','2026-03-06 12:59:32');
/*!40000 ALTER TABLE `patients` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payments`
--

DROP TABLE IF EXISTS `payments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `payments` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `bill_id` bigint unsigned NOT NULL,
  `amount_paid` decimal(10,2) NOT NULL,
  `payment_method` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'cash',
  `transaction_ref` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `paid_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `created_by` bigint unsigned DEFAULT NULL,
  `updated_by` bigint unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `payments_bill_id_payment_method_index` (`bill_id`,`payment_method`),
  KEY `payments_created_by_foreign` (`created_by`),
  KEY `payments_updated_by_foreign` (`updated_by`),
  CONSTRAINT `payments_bill_id_foreign` FOREIGN KEY (`bill_id`) REFERENCES `bills` (`id`) ON DELETE CASCADE,
  CONSTRAINT `payments_created_by_foreign` FOREIGN KEY (`created_by`) REFERENCES `staff` (`id`) ON DELETE SET NULL,
  CONSTRAINT `payments_updated_by_foreign` FOREIGN KEY (`updated_by`) REFERENCES `staff` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payments`
--

LOCK TABLES `payments` WRITE;
/*!40000 ALTER TABLE `payments` DISABLE KEYS */;
/*!40000 ALTER TABLE `payments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `personal_access_tokens`
--

DROP TABLE IF EXISTS `personal_access_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `personal_access_tokens` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `tokenable_type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tokenable_id` bigint unsigned NOT NULL,
  `name` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `abilities` text COLLATE utf8mb4_unicode_ci,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `personal_access_tokens_token_unique` (`token`),
  KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`),
  KEY `personal_access_tokens_expires_at_index` (`expires_at`)
) ENGINE=InnoDB AUTO_INCREMENT=72 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `personal_access_tokens`
--

LOCK TABLES `personal_access_tokens` WRITE;
/*!40000 ALTER TABLE `personal_access_tokens` DISABLE KEYS */;
INSERT INTO `personal_access_tokens` VALUES (13,'App\\Models\\Staff',4,'auth_token','a6fd183a0ad724dd63cde6ed3739cbac0c1efbcffa2fc589e6e7abfede63223c','[\"*\"]','2026-03-04 18:26:51',NULL,'2026-03-04 18:24:32','2026-03-04 18:26:51'),(43,'App\\Models\\Staff',3,'auth_token','850947c616fc5a0594c9d569becad486734ceea4d190013389269e95cf215766','[\"*\"]','2026-03-05 17:53:34',NULL,'2026-03-05 17:53:08','2026-03-05 17:53:34'),(67,'App\\Models\\Staff',10,'auth_token','4857e1a63b42901b610657d0eebdd853d7c26c3df6933e11bf154185ee729fac','[\"*\"]','2026-03-06 12:49:42',NULL,'2026-03-06 12:01:12','2026-03-06 12:49:42'),(69,'App\\Models\\Staff',1,'auth_token','5a4c642da84112b756305bb76fe2eece9a58b60f5a5441d88bf95678a5a9ebac','[\"*\"]','2026-03-06 12:59:41',NULL,'2026-03-06 12:34:50','2026-03-06 12:59:41'),(70,'App\\Models\\Staff',5,'auth_token','33497150d8e18def17e25a857f2f433e89ac0f6b21b46144fa9f8ca4f8ee6616','[\"*\"]','2026-03-06 12:57:15',NULL,'2026-03-06 12:55:38','2026-03-06 12:57:15'),(71,'App\\Models\\Staff',2,'auth_token','129ae4b71da0991e0bafed2cc93a84411cf4b098fdc4366782f0835a4eedacf6','[\"*\"]','2026-03-06 13:30:17',NULL,'2026-03-06 12:56:41','2026-03-06 13:30:17');
/*!40000 ALTER TABLE `personal_access_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pharmacy_dispensation_items`
--

DROP TABLE IF EXISTS `pharmacy_dispensation_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pharmacy_dispensation_items` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `dispensation_id` bigint unsigned NOT NULL,
  `prescription_item_id` bigint unsigned NOT NULL,
  `drug_id` bigint unsigned NOT NULL,
  `batch_id` bigint unsigned NOT NULL COMMENT 'Which batch was used (FEFO)',
  `quantity_dispensed` int NOT NULL,
  `unit_price` decimal(10,2) NOT NULL COMMENT 'Actual price charged',
  `unit_cost` decimal(10,2) DEFAULT NULL COMMENT 'Cost from batch',
  `line_total` decimal(10,2) NOT NULL,
  `profit_margin` decimal(10,2) DEFAULT NULL COMMENT 'line_total - (quantity * unit_cost)',
  `discount_amount` decimal(10,2) NOT NULL DEFAULT '0.00',
  `vat_amount` decimal(10,2) NOT NULL DEFAULT '0.00',
  `expiry_date` date NOT NULL COMMENT 'Snapshot from batch',
  `batch_number` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Snapshot for audit',
  `storage_location` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `dosage_given` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `instructions_given` text COLLATE utf8mb4_unicode_ci,
  `warnings_given` text COLLATE utf8mb4_unicode_ci,
  `was_substituted` tinyint(1) NOT NULL DEFAULT '0',
  `original_drug_id` bigint unsigned DEFAULT NULL,
  `substitution_reason` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `pharmacy_dispensation_items_drug_id_foreign` (`drug_id`),
  KEY `pharmacy_dispensation_items_original_drug_id_foreign` (`original_drug_id`),
  KEY `pharmacy_dispensation_items_dispensation_id_drug_id_index` (`dispensation_id`,`drug_id`),
  KEY `pharmacy_dispensation_items_batch_id_index` (`batch_id`),
  KEY `pharmacy_dispensation_items_prescription_item_id_index` (`prescription_item_id`),
  CONSTRAINT `pharmacy_dispensation_items_batch_id_foreign` FOREIGN KEY (`batch_id`) REFERENCES `pharmacy_drug_batches` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `pharmacy_dispensation_items_dispensation_id_foreign` FOREIGN KEY (`dispensation_id`) REFERENCES `pharmacy_dispensations` (`id`) ON DELETE CASCADE,
  CONSTRAINT `pharmacy_dispensation_items_drug_id_foreign` FOREIGN KEY (`drug_id`) REFERENCES `pharmacy_drugs` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `pharmacy_dispensation_items_original_drug_id_foreign` FOREIGN KEY (`original_drug_id`) REFERENCES `pharmacy_drugs` (`id`) ON DELETE SET NULL,
  CONSTRAINT `pharmacy_dispensation_items_prescription_item_id_foreign` FOREIGN KEY (`prescription_item_id`) REFERENCES `pharmacy_prescription_items` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pharmacy_dispensation_items`
--

LOCK TABLES `pharmacy_dispensation_items` WRITE;
/*!40000 ALTER TABLE `pharmacy_dispensation_items` DISABLE KEYS */;
/*!40000 ALTER TABLE `pharmacy_dispensation_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pharmacy_dispensations`
--

DROP TABLE IF EXISTS `pharmacy_dispensations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pharmacy_dispensations` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `dispensation_number` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'DISP-20251206-0001',
  `prescription_id` bigint unsigned NOT NULL,
  `patient_id` bigint unsigned NOT NULL,
  `dispensation_type` enum('full','partial','refill','emergency') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'full',
  `dispensed_at` timestamp NOT NULL,
  `dispensed_by_staff_id` bigint unsigned NOT NULL COMMENT 'WHO actually dispensed (typically admin)',
  `assigned_pharmacist_id` bigint unsigned DEFAULT NULL COMMENT 'Pharmacist assigned for this dispensation',
  `verified_by_pharmacist_id` bigint unsigned DEFAULT NULL COMMENT 'Second pharmacist verification',
  `verification_status` enum('pending','verified','rejected') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `verified_at` timestamp NULL DEFAULT NULL,
  `verification_notes` text COLLATE utf8mb4_unicode_ci,
  `patient_collected` tinyint(1) NOT NULL DEFAULT '0',
  `collected_at` timestamp NULL DEFAULT NULL,
  `collection_method` enum('in_person','delivery','proxy') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'in_person',
  `collected_by_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'If proxy collection',
  `collected_by_id_number` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'ID verification',
  `collected_by_relationship` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `total_amount` decimal(10,2) NOT NULL,
  `amount_paid` decimal(10,2) NOT NULL DEFAULT '0.00',
  `amount_outstanding` decimal(10,2) GENERATED ALWAYS AS ((`total_amount` - `amount_paid`)) VIRTUAL,
  `payment_status` enum('unpaid','partially_paid','paid') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'unpaid',
  `patient_counseled` tinyint(1) NOT NULL DEFAULT '0',
  `counseling_notes` text COLLATE utf8mb4_unicode_ci,
  `patient_questions` text COLLATE utf8mb4_unicode_ci,
  `adverse_reactions_noted` text COLLATE utf8mb4_unicode_ci,
  `requires_follow_up` tinyint(1) NOT NULL DEFAULT '0',
  `follow_up_date` date DEFAULT NULL,
  `follow_up_instructions` text COLLATE utf8mb4_unicode_ci,
  `special_notes` text COLLATE utf8mb4_unicode_ci,
  `internal_notes` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `pharmacy_dispensations_dispensation_number_unique` (`dispensation_number`),
  KEY `pharmacy_dispensations_dispensed_by_staff_id_foreign` (`dispensed_by_staff_id`),
  KEY `pharmacy_dispensations_verified_by_pharmacist_id_foreign` (`verified_by_pharmacist_id`),
  KEY `pharmacy_dispensations_patient_id_dispensed_at_index` (`patient_id`,`dispensed_at`),
  KEY `pharmacy_dispensations_assigned_pharmacist_id_index` (`assigned_pharmacist_id`),
  KEY `pharmacy_dispensations_payment_status_index` (`payment_status`),
  KEY `pharmacy_dispensations_prescription_id_dispensation_type_index` (`prescription_id`,`dispensation_type`),
  CONSTRAINT `pharmacy_dispensations_assigned_pharmacist_id_foreign` FOREIGN KEY (`assigned_pharmacist_id`) REFERENCES `staff` (`id`) ON DELETE SET NULL,
  CONSTRAINT `pharmacy_dispensations_dispensed_by_staff_id_foreign` FOREIGN KEY (`dispensed_by_staff_id`) REFERENCES `staff` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `pharmacy_dispensations_patient_id_foreign` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `pharmacy_dispensations_prescription_id_foreign` FOREIGN KEY (`prescription_id`) REFERENCES `pharmacy_prescriptions` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `pharmacy_dispensations_verified_by_pharmacist_id_foreign` FOREIGN KEY (`verified_by_pharmacist_id`) REFERENCES `staff` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pharmacy_dispensations`
--

LOCK TABLES `pharmacy_dispensations` WRITE;
/*!40000 ALTER TABLE `pharmacy_dispensations` DISABLE KEYS */;
/*!40000 ALTER TABLE `pharmacy_dispensations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pharmacy_drug_batches`
--

DROP TABLE IF EXISTS `pharmacy_drug_batches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pharmacy_drug_batches` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `drug_id` bigint unsigned NOT NULL,
  `batch_number` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `supplier_id` bigint unsigned DEFAULT NULL,
  `purchase_order_number` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `manufacture_date` date DEFAULT NULL,
  `expiry_date` date DEFAULT NULL,
  `quantity_received` int NOT NULL COMMENT 'Initial quantity',
  `quantity_current` int NOT NULL DEFAULT '0' COMMENT 'Current available',
  `quantity_reserved` int NOT NULL DEFAULT '0' COMMENT 'Reserved for pending orders',
  `quantity_dispensed` int NOT NULL DEFAULT '0' COMMENT 'Total dispensed',
  `quantity_damaged` int NOT NULL DEFAULT '0',
  `quantity_expired` int NOT NULL DEFAULT '0',
  `quantity_returned` int NOT NULL DEFAULT '0',
  `unit_cost` decimal(10,2) NOT NULL COMMENT 'Purchase cost per unit',
  `unit_price` decimal(10,2) NOT NULL COMMENT 'Selling price per unit',
  `vat_percentage` decimal(5,2) NOT NULL DEFAULT '0.00',
  `markup_percentage` decimal(5,2) DEFAULT NULL,
  `storage_location` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Shelf A-3, Fridge 2, etc.',
  `storage_temp_min` decimal(5,2) DEFAULT NULL,
  `storage_temp_max` decimal(5,2) DEFAULT NULL,
  `requires_cold_chain` tinyint(1) NOT NULL DEFAULT '0',
  `quality_check_status` enum('pending','passed','failed') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'passed',
  `quality_check_notes` text COLLATE utf8mb4_unicode_ci,
  `quality_checked_at` timestamp NULL DEFAULT NULL,
  `quality_checked_by` bigint unsigned DEFAULT NULL,
  `status` enum('active','expired','recalled','depleted','quarantined') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `status_notes` text COLLATE utf8mb4_unicode_ci,
  `received_date` timestamp NOT NULL,
  `received_by` bigint unsigned DEFAULT NULL,
  `receiving_notes` text COLLATE utf8mb4_unicode_ci,
  `expiry_alert_days` int NOT NULL DEFAULT '180' COMMENT 'Alert X days before expiry',
  `expiry_alert_sent` tinyint(1) NOT NULL DEFAULT '0',
  `notes` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `pharmacy_drug_batches_batch_number_unique` (`batch_number`),
  KEY `pharmacy_drug_batches_supplier_id_foreign` (`supplier_id`),
  KEY `pharmacy_drug_batches_quality_checked_by_foreign` (`quality_checked_by`),
  KEY `pharmacy_drug_batches_received_by_foreign` (`received_by`),
  KEY `pharmacy_drug_batches_drug_id_status_index` (`drug_id`,`status`),
  KEY `pharmacy_drug_batches_drug_id_expiry_date_index` (`drug_id`,`expiry_date`),
  KEY `pharmacy_drug_batches_storage_location_index` (`storage_location`),
  KEY `pharmacy_drug_batches_expiry_date_index` (`expiry_date`),
  KEY `pharmacy_drug_batches_status_index` (`status`),
  CONSTRAINT `pharmacy_drug_batches_drug_id_foreign` FOREIGN KEY (`drug_id`) REFERENCES `pharmacy_drugs` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `pharmacy_drug_batches_quality_checked_by_foreign` FOREIGN KEY (`quality_checked_by`) REFERENCES `staff` (`id`) ON DELETE SET NULL,
  CONSTRAINT `pharmacy_drug_batches_received_by_foreign` FOREIGN KEY (`received_by`) REFERENCES `staff` (`id`) ON DELETE SET NULL,
  CONSTRAINT `pharmacy_drug_batches_supplier_id_foreign` FOREIGN KEY (`supplier_id`) REFERENCES `suppliers` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=115 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pharmacy_drug_batches`
--

LOCK TABLES `pharmacy_drug_batches` WRITE;
/*!40000 ALTER TABLE `pharmacy_drug_batches` DISABLE KEYS */;
INSERT INTO `pharmacy_drug_batches` VALUES (1,25,NULL,2,NULL,NULL,NULL,4,4,0,0,0,0,0,30.00,50.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 08:30:59',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00025)','2026-03-05 08:30:59','2026-03-05 08:30:59',NULL),(2,26,NULL,2,NULL,NULL,NULL,8,8,0,0,0,0,0,30.00,50.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 08:34:29',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00026)','2026-03-05 08:34:29','2026-03-05 08:34:29',NULL),(3,27,NULL,2,NULL,NULL,NULL,6,6,0,0,0,0,0,30.00,50.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 08:40:55',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00027)','2026-03-05 08:40:55','2026-03-05 08:40:55',NULL),(4,28,NULL,2,NULL,NULL,NULL,35,35,0,0,0,0,0,50.00,200.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 08:46:06',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00028)','2026-03-05 08:46:06','2026-03-05 08:46:06',NULL),(5,29,NULL,2,NULL,NULL,NULL,6,6,0,0,0,0,0,50.00,200.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 08:49:47',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00029)','2026-03-05 08:49:47','2026-03-05 08:49:47',NULL),(6,30,NULL,2,NULL,NULL,NULL,6,6,0,0,0,0,0,10.00,50.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 08:55:17',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00030)','2026-03-05 08:55:17','2026-03-05 08:55:17',NULL),(7,31,NULL,2,NULL,NULL,NULL,504,504,0,0,0,0,0,2.50,5.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 09:03:40',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00031)','2026-03-05 09:03:40','2026-03-05 09:03:40',NULL),(8,32,NULL,2,NULL,NULL,NULL,29,29,0,0,0,0,0,80.00,500.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 09:07:30',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00032)','2026-03-05 09:07:30','2026-03-05 09:07:30',NULL),(9,4,'BATCH-A',2,NULL,NULL,NULL,4,4,0,0,0,0,0,100.00,500.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 09:15:20',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00004)','2026-03-05 09:15:20','2026-03-05 09:15:20',NULL),(10,5,NULL,2,NULL,NULL,NULL,1202,1202,0,0,0,0,0,2.30,10.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 09:16:34',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00005)','2026-03-05 09:16:34','2026-03-05 09:16:34',NULL),(11,11,NULL,2,NULL,NULL,NULL,28,28,0,0,0,0,0,2.30,5.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 09:19:31',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00011)','2026-03-05 09:19:31','2026-03-05 09:19:31',NULL),(12,15,NULL,2,NULL,NULL,NULL,90,90,0,0,0,0,0,2.30,5.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 09:21:47',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00015)','2026-03-05 09:21:47','2026-03-05 09:21:47',NULL),(13,19,NULL,2,NULL,NULL,NULL,59,59,0,0,0,0,0,2.30,5.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 09:22:50',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00019)','2026-03-05 09:22:50','2026-03-05 09:22:50',NULL),(14,23,NULL,2,NULL,NULL,NULL,11,11,0,0,0,0,0,30.00,100.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 09:23:36',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00023)','2026-03-05 09:23:36','2026-03-05 09:23:36',NULL),(15,21,NULL,2,NULL,NULL,NULL,40,40,0,0,0,0,0,2.30,5.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 09:25:13',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00021)','2026-03-05 09:25:13','2026-03-05 09:25:13',NULL),(16,8,NULL,2,NULL,NULL,NULL,299,299,0,0,0,0,0,2.30,10.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 09:27:37',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00008)','2026-03-05 09:27:37','2026-03-05 09:27:37',NULL),(17,16,NULL,2,NULL,NULL,NULL,44,44,0,0,0,0,0,2.50,10.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 09:31:27',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00016)','2026-03-05 09:31:27','2026-03-05 09:31:27',NULL),(18,17,NULL,2,NULL,NULL,NULL,490,490,0,0,0,0,0,2.50,5.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 09:35:39',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00017)','2026-03-05 09:35:39','2026-03-05 09:35:39',NULL),(19,9,NULL,2,NULL,NULL,NULL,400,400,0,0,0,0,0,2.30,500.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 09:37:16',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00009)','2026-03-05 09:37:16','2026-03-05 09:37:16',NULL),(20,12,NULL,2,NULL,NULL,NULL,28,28,0,0,0,0,0,2.30,10.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 09:38:56',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00012)','2026-03-05 09:38:56','2026-03-05 09:38:56',NULL),(21,13,NULL,2,NULL,NULL,NULL,28,28,0,0,0,0,0,2.30,10.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 09:40:52',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00013)','2026-03-05 09:40:52','2026-03-05 09:40:52',NULL),(22,7,NULL,2,NULL,NULL,NULL,20,20,0,0,0,0,0,10.00,12.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 09:41:32',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00007)','2026-03-05 09:41:32','2026-03-05 09:41:32',NULL),(23,6,NULL,2,NULL,NULL,NULL,400,400,0,0,0,0,0,10.00,12.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 09:44:56',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00006)','2026-03-05 09:44:56','2026-03-05 09:44:56',NULL),(24,20,NULL,2,NULL,NULL,NULL,90,90,0,0,0,0,0,5.00,5.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 09:49:40',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00020)','2026-03-05 09:49:40','2026-03-05 09:49:40',NULL),(25,14,NULL,2,NULL,NULL,NULL,60,60,0,0,0,0,0,5.00,5.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 09:50:10',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00014)','2026-03-05 09:50:10','2026-03-05 09:50:10',NULL),(26,10,NULL,2,NULL,NULL,NULL,1600,1600,0,0,0,0,0,5.00,6.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 09:50:36',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00010)','2026-03-05 09:50:36','2026-03-05 09:50:36',NULL),(27,18,NULL,2,NULL,NULL,NULL,180,180,0,0,0,0,0,5.00,6.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 09:51:28',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00018)','2026-03-05 09:51:28','2026-03-05 09:51:28',NULL),(28,22,NULL,2,NULL,NULL,NULL,1100,1100,0,0,0,0,0,5.00,6.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 09:51:49',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00022)','2026-03-05 09:51:49','2026-03-05 09:51:49',NULL),(29,33,NULL,2,NULL,NULL,NULL,9,9,0,0,0,0,0,500.00,600.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 09:57:24',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00033)','2026-03-05 09:57:24','2026-03-05 09:57:24',NULL),(39,34,NULL,2,NULL,NULL,NULL,15,15,0,0,0,0,0,500.00,600.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 10:07:56',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00034)','2026-03-05 10:07:56','2026-03-05 10:07:56',NULL),(40,35,NULL,2,NULL,NULL,NULL,10,10,0,0,0,0,0,200.00,240.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 11:31:42',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00035)','2026-03-05 11:31:42','2026-03-05 11:31:42',NULL),(41,37,NULL,2,NULL,NULL,NULL,120,120,0,0,0,0,0,200.00,240.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 11:34:57',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00037)','2026-03-05 11:34:57','2026-03-05 11:34:57',NULL),(42,38,NULL,2,NULL,NULL,NULL,30,30,0,0,0,0,0,250.00,300.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 11:38:37',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00038)','2026-03-05 11:38:37','2026-03-05 11:38:37',NULL),(43,39,NULL,2,NULL,NULL,NULL,140,140,0,0,0,0,0,100.00,120.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 11:43:40',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00039)','2026-03-05 11:43:40','2026-03-05 11:43:40',NULL),(44,40,NULL,2,NULL,NULL,NULL,4,4,0,0,0,0,0,300.00,360.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 11:49:37',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00040)','2026-03-05 11:49:37','2026-03-05 11:49:37',NULL),(45,41,NULL,2,NULL,NULL,NULL,1,1,0,0,0,0,0,1000.00,1200.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 11:54:22',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00041)','2026-03-05 11:54:22','2026-03-05 11:54:22',NULL),(46,42,NULL,2,NULL,NULL,NULL,4,4,0,0,0,0,0,200.00,240.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 12:01:36',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00042)','2026-03-05 12:01:36','2026-03-05 12:01:36',NULL),(47,43,NULL,2,NULL,NULL,NULL,6,6,0,0,0,0,0,100.00,120.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 12:09:15',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00043)','2026-03-05 12:09:15','2026-03-05 12:09:15',NULL),(48,44,NULL,2,NULL,NULL,NULL,12,12,0,0,0,0,0,500.00,600.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 12:25:38',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00044)','2026-03-05 12:25:38','2026-03-05 12:25:38',NULL),(49,45,NULL,2,NULL,NULL,NULL,5,5,0,0,0,0,0,300.00,360.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 12:29:37',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00045)','2026-03-05 12:29:37','2026-03-05 12:29:37',NULL),(50,46,NULL,2,NULL,NULL,NULL,2,2,0,0,0,0,0,100.00,120.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 12:34:30',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00046)','2026-03-05 12:34:30','2026-03-05 12:34:30',NULL),(51,46,NULL,2,NULL,NULL,NULL,1,1,0,0,0,0,0,100.00,120.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 12:35:33',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00046)','2026-03-05 12:35:33','2026-03-05 12:35:33',NULL),(52,47,NULL,NULL,NULL,NULL,NULL,21,21,0,0,0,0,0,300.00,360.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 12:44:27',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00047)','2026-03-05 12:44:27','2026-03-05 12:44:27',NULL),(53,48,NULL,2,NULL,NULL,NULL,7,7,0,0,0,0,0,300.00,360.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 12:48:23',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00048)','2026-03-05 12:48:23','2026-03-05 12:48:23',NULL),(54,49,NULL,2,NULL,NULL,NULL,9,9,0,0,0,0,0,300.00,360.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 12:54:44',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00049)','2026-03-05 12:54:44','2026-03-05 12:54:44',NULL),(55,50,NULL,2,NULL,NULL,NULL,18,18,0,0,0,0,0,300.00,360.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 12:59:53',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00050)','2026-03-05 12:59:53','2026-03-05 12:59:53',NULL),(56,51,NULL,2,NULL,NULL,NULL,80,80,0,0,0,0,0,200.00,240.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 13:05:16',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00051)','2026-03-05 13:05:16','2026-03-05 13:05:16',NULL),(57,52,NULL,2,NULL,NULL,NULL,54,54,0,0,0,0,0,100.00,120.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 13:08:48',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00052)','2026-03-05 13:08:48','2026-03-05 13:08:48',NULL),(58,53,NULL,2,NULL,NULL,NULL,456,456,0,0,0,0,0,5.00,6.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 13:15:13',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00053)','2026-03-05 13:15:13','2026-03-05 13:15:13',NULL),(59,54,NULL,2,NULL,NULL,NULL,3,3,0,0,0,0,0,50.00,60.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 13:21:13',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00054)','2026-03-05 13:21:13','2026-03-05 13:21:13',NULL),(60,55,NULL,NULL,NULL,NULL,NULL,21,21,0,0,0,0,0,50.00,60.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 13:25:36',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00055)','2026-03-05 13:25:36','2026-03-05 13:25:36',NULL),(61,56,NULL,2,NULL,NULL,NULL,10,10,0,0,0,0,0,35.00,42.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 13:34:10',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00056)','2026-03-05 13:34:10','2026-03-05 13:34:10',NULL),(62,57,NULL,2,NULL,NULL,NULL,30,30,0,0,0,0,0,35.00,42.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 13:37:05',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00057)','2026-03-05 13:37:05','2026-03-05 13:37:05',NULL),(63,58,NULL,2,NULL,NULL,NULL,80,80,0,0,0,0,0,10.00,12.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 13:40:00',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00058)','2026-03-05 13:40:00','2026-03-05 13:40:00',NULL),(64,59,NULL,2,NULL,NULL,NULL,30,30,0,0,0,0,0,300.00,360.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 13:44:04',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00059)','2026-03-05 13:44:04','2026-03-05 13:44:04',NULL),(65,60,NULL,2,NULL,NULL,NULL,19,19,0,0,0,0,0,200.00,240.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 13:47:19',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00060)','2026-03-05 13:47:19','2026-03-05 13:47:19',NULL),(66,61,NULL,2,NULL,NULL,NULL,19,19,0,0,0,0,0,200.00,240.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 13:51:30',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00061)','2026-03-05 13:51:30','2026-03-05 13:51:30',NULL),(67,58,NULL,2,NULL,NULL,NULL,400,400,0,0,0,0,0,10.00,12.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 13:53:58',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00058)','2026-03-05 13:53:58','2026-03-05 13:53:58',NULL),(68,62,NULL,2,NULL,NULL,NULL,500,500,0,0,0,0,0,5.00,6.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 13:57:20',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00062)','2026-03-05 13:57:20','2026-03-05 13:57:20',NULL),(69,63,NULL,2,NULL,NULL,NULL,400,400,0,0,0,0,0,5.00,6.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 14:00:09',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00063)','2026-03-05 14:00:09','2026-03-05 14:00:09',NULL),(70,64,NULL,2,NULL,NULL,NULL,100,100,0,0,0,0,0,5.00,6.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 14:03:19',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00064)','2026-03-05 14:03:19','2026-03-05 14:03:19',NULL),(71,65,NULL,2,NULL,NULL,NULL,100,100,0,0,0,0,0,5.00,6.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 14:06:02',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00065)','2026-03-05 14:06:02','2026-03-05 14:06:02',NULL),(72,64,NULL,2,NULL,NULL,NULL,800,800,0,0,0,0,0,5.00,6.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 14:07:34',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00064)','2026-03-05 14:07:34','2026-03-05 14:07:34',NULL),(73,66,NULL,NULL,NULL,NULL,NULL,400,400,0,0,0,0,0,5.00,5.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 14:11:14',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00066)','2026-03-05 14:11:14','2026-03-05 14:11:14',NULL),(74,67,NULL,2,NULL,NULL,NULL,84,84,0,0,0,0,0,5.00,6.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 14:14:42',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00067)','2026-03-05 14:14:42','2026-03-05 14:14:42',NULL),(75,68,NULL,2,NULL,NULL,NULL,200,200,0,0,0,0,0,5.00,6.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 14:17:56',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00068)','2026-03-05 14:17:56','2026-03-05 14:17:56',NULL),(76,69,NULL,2,NULL,NULL,NULL,5,5,0,0,0,0,0,200.00,240.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 14:21:09',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00069)','2026-03-05 14:21:09','2026-03-05 14:21:09',NULL),(77,70,NULL,NULL,NULL,NULL,NULL,690,690,0,0,0,0,0,10.00,12.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 14:27:08',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00070)','2026-03-05 14:27:08','2026-03-05 14:27:08',NULL),(78,71,NULL,NULL,NULL,NULL,NULL,7,7,0,0,0,0,0,100.00,120.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 14:29:51',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00071)','2026-03-05 14:29:51','2026-03-05 14:29:51',NULL),(79,72,NULL,2,NULL,NULL,NULL,24,24,0,0,0,0,0,25.00,30.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 14:32:40',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00072)','2026-03-05 14:32:40','2026-03-05 14:32:40',NULL),(80,73,NULL,2,NULL,NULL,NULL,46,46,0,0,0,0,0,20.00,24.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 14:36:00',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00073)','2026-03-05 14:36:00','2026-03-05 14:36:00',NULL),(81,74,NULL,2,NULL,NULL,NULL,24,24,0,0,0,0,0,20.00,24.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 14:39:19',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00074)','2026-03-05 14:39:19','2026-03-05 14:39:19',NULL),(82,75,NULL,2,NULL,NULL,NULL,15,15,0,0,0,0,0,150.00,180.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 14:43:36',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00075)','2026-03-05 14:43:36','2026-03-05 14:43:36',NULL),(83,76,NULL,2,NULL,NULL,NULL,8,8,0,0,0,0,0,450.00,540.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 14:48:11',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00076)','2026-03-05 14:48:11','2026-03-05 14:48:11',NULL),(84,77,NULL,2,NULL,NULL,NULL,26,26,0,0,0,0,0,150.00,180.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 14:50:15',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00077)','2026-03-05 14:50:15','2026-03-05 14:50:15',NULL),(85,78,NULL,2,NULL,NULL,NULL,700,700,0,0,0,0,0,5.00,6.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 14:53:45',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00078)','2026-03-05 14:53:45','2026-03-05 14:53:45',NULL),(86,79,NULL,2,NULL,NULL,NULL,10,10,0,0,0,0,0,50.00,60.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 14:57:35',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00079)','2026-03-05 14:57:35','2026-03-05 14:57:35',NULL),(87,80,NULL,2,NULL,NULL,NULL,20,20,0,0,0,0,0,50.00,60.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 14:58:23',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00080)','2026-03-05 14:58:23','2026-03-05 14:58:23',NULL),(88,81,NULL,2,NULL,NULL,NULL,1200,1200,0,0,0,0,0,5.00,6.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 15:02:01',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00081)','2026-03-05 15:02:01','2026-03-05 15:02:01',NULL),(89,82,NULL,2,NULL,NULL,NULL,500,500,0,0,0,0,0,5.00,6.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 15:03:29',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00082)','2026-03-05 15:03:29','2026-03-05 15:03:29',NULL),(90,83,NULL,2,NULL,NULL,NULL,600,600,0,0,0,0,0,5.00,6.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 15:05:16',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00083)','2026-03-05 15:05:16','2026-03-05 15:05:16',NULL),(91,84,NULL,2,NULL,NULL,NULL,600,600,0,0,0,0,0,5.00,6.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 15:07:27',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00084)','2026-03-05 15:07:27','2026-03-05 15:07:27',NULL),(92,85,NULL,2,NULL,NULL,NULL,700,700,0,0,0,0,0,5.00,6.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 15:08:38',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00085)','2026-03-05 15:08:38','2026-03-05 15:08:38',NULL),(93,86,NULL,2,NULL,NULL,NULL,40,40,0,0,0,0,0,100.00,120.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 15:12:14',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00086)','2026-03-05 15:12:14','2026-03-05 15:12:14',NULL),(94,87,NULL,2,NULL,NULL,NULL,11,11,0,0,0,0,0,150.00,180.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 15:14:22',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00087)','2026-03-05 15:14:22','2026-03-05 15:14:22',NULL),(95,89,NULL,2,NULL,NULL,NULL,55,55,0,0,0,0,0,30.00,36.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 15:19:46',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00089)','2026-03-05 15:19:46','2026-03-05 15:19:46',NULL),(96,90,NULL,2,NULL,NULL,NULL,22,22,0,0,0,0,0,50.00,60.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 15:22:14',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00090)','2026-03-05 15:22:14','2026-03-05 15:22:14',NULL),(97,91,NULL,2,NULL,NULL,NULL,6,6,0,0,0,0,0,100.00,120.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 15:25:07',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00091)','2026-03-05 15:25:07','2026-03-05 15:25:07',NULL),(98,92,NULL,2,NULL,NULL,NULL,11,11,0,0,0,0,0,100.00,120.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 15:28:27',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00092)','2026-03-05 15:28:27','2026-03-05 15:28:27',NULL),(99,93,NULL,2,NULL,NULL,NULL,15,15,0,0,0,0,0,100.00,120.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 15:30:39',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00093)','2026-03-05 15:30:39','2026-03-05 15:30:39',NULL),(100,94,NULL,2,NULL,NULL,NULL,15,15,0,0,0,0,0,100.00,120.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 15:32:05',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00094)','2026-03-05 15:32:05','2026-03-05 15:32:05',NULL),(101,95,NULL,2,NULL,NULL,NULL,11,11,0,0,0,0,0,100.00,120.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 15:34:00',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00095)','2026-03-05 15:34:00','2026-03-05 15:34:00',NULL),(102,96,NULL,2,NULL,NULL,NULL,15,15,0,0,0,0,0,50.00,60.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 15:36:28',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00096)','2026-03-05 15:36:28','2026-03-05 15:36:28',NULL),(103,97,NULL,NULL,NULL,NULL,NULL,18,18,0,0,0,0,0,50.00,60.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 15:41:33',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00097)','2026-03-05 15:41:33','2026-03-05 15:41:33',NULL),(104,98,NULL,2,NULL,NULL,NULL,9,9,0,0,0,0,0,50.00,60.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 15:42:57',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00098)','2026-03-05 15:42:57','2026-03-05 15:42:57',NULL),(105,36,NULL,2,NULL,NULL,NULL,50,50,0,0,0,0,0,200.00,240.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-05 15:44:19',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00036)','2026-03-05 15:44:19','2026-03-05 15:44:19',NULL),(108,65,NULL,1,NULL,NULL,NULL,200,200,0,0,0,0,0,5.00,6.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-06 11:09:29',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00065)','2026-03-06 11:09:29','2026-03-06 11:09:29',NULL),(109,99,NULL,1,NULL,NULL,NULL,56,56,0,0,0,0,0,100.00,120.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-06 11:20:09',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00099)','2026-03-06 11:20:09','2026-03-06 11:20:09',NULL),(110,68,NULL,1,NULL,NULL,NULL,600,600,0,0,0,0,0,5.00,6.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-06 11:21:14',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00068)','2026-03-06 11:21:14','2026-03-06 11:21:14',NULL),(111,100,NULL,1,NULL,NULL,NULL,80,80,0,0,0,0,0,20.00,24.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-06 11:34:07',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00100)','2026-03-06 11:34:07','2026-03-06 11:34:07',NULL),(112,101,NULL,1,NULL,NULL,NULL,1900,1900,0,0,0,0,0,5.00,6.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-06 11:37:20',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00101)','2026-03-06 11:37:20','2026-03-06 11:37:20',NULL),(113,33,NULL,2,NULL,NULL,NULL,30,30,0,0,0,0,0,500.00,600.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-06 11:38:58',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00033)','2026-03-06 11:38:58','2026-03-06 11:38:58',NULL),(114,102,NULL,1,NULL,NULL,NULL,15,15,0,0,0,0,0,100.00,120.00,0.00,NULL,'Pharmacy',NULL,NULL,0,'passed',NULL,NULL,NULL,'active',NULL,'2026-03-06 11:41:11',NULL,NULL,180,0,'Dispensed from Main Store (Item: MED-00102)','2026-03-06 11:41:11','2026-03-06 11:41:11',NULL);
/*!40000 ALTER TABLE `pharmacy_drug_batches` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pharmacy_drug_interactions`
--

DROP TABLE IF EXISTS `pharmacy_drug_interactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pharmacy_drug_interactions` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `drug_a_id` bigint unsigned NOT NULL,
  `drug_b_id` bigint unsigned NOT NULL,
  `interaction_severity` enum('minor','moderate','major','contraindicated') COLLATE utf8mb4_unicode_ci NOT NULL,
  `interaction_description` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `clinical_effect` text COLLATE utf8mb4_unicode_ci COMMENT 'What happens when combined',
  `mechanism` text COLLATE utf8mb4_unicode_ci COMMENT 'How the interaction occurs',
  `management_recommendation` text COLLATE utf8mb4_unicode_ci,
  `monitoring_parameters` text COLLATE utf8mb4_unicode_ci,
  `evidence_level` enum('theoretical','case_report','study','established') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'theoretical',
  `references` text COLLATE utf8mb4_unicode_ci COMMENT 'Scientific references',
  `source` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Database or reference source',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `reviewed_at` timestamp NULL DEFAULT NULL,
  `reviewed_by` bigint unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `pharmacy_drug_interactions_drug_a_id_drug_b_id_unique` (`drug_a_id`,`drug_b_id`),
  KEY `pharmacy_drug_interactions_drug_b_id_foreign` (`drug_b_id`),
  KEY `pharmacy_drug_interactions_reviewed_by_foreign` (`reviewed_by`),
  KEY `pharmacy_drug_interactions_interaction_severity_index` (`interaction_severity`),
  KEY `pharmacy_drug_interactions_is_active_index` (`is_active`),
  CONSTRAINT `pharmacy_drug_interactions_drug_a_id_foreign` FOREIGN KEY (`drug_a_id`) REFERENCES `pharmacy_drugs` (`id`) ON DELETE CASCADE,
  CONSTRAINT `pharmacy_drug_interactions_drug_b_id_foreign` FOREIGN KEY (`drug_b_id`) REFERENCES `pharmacy_drugs` (`id`) ON DELETE CASCADE,
  CONSTRAINT `pharmacy_drug_interactions_reviewed_by_foreign` FOREIGN KEY (`reviewed_by`) REFERENCES `staff` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pharmacy_drug_interactions`
--

LOCK TABLES `pharmacy_drug_interactions` WRITE;
/*!40000 ALTER TABLE `pharmacy_drug_interactions` DISABLE KEYS */;
/*!40000 ALTER TABLE `pharmacy_drug_interactions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pharmacy_drugs`
--

DROP TABLE IF EXISTS `pharmacy_drugs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pharmacy_drugs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `drug_code` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'e.g., DRG-0001',
  `generic_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `brand_names` json DEFAULT NULL COMMENT '["Panadol", "Tylenol"]',
  `dosage_form` enum('tablet','capsule','syrup','suspension','injection','cream','ointment','gel','drops','inhaler','suppository','patch','powder','solution','lotion','spray') COLLATE utf8mb4_unicode_ci NOT NULL,
  `strength` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'e.g., 500mg, 5mg/ml',
  `route_of_administration` enum('oral','iv','im','sc','topical','inhalation','rectal','vaginal','ophthalmic','otic','nasal','transdermal') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `drug_category` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Analgesic, Antibiotic, etc.',
  `therapeutic_class` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `controlled_substance` tinyint(1) NOT NULL DEFAULT '0',
  `schedule` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Schedule I-V for controlled substances',
  `requires_prescription` tinyint(1) NOT NULL DEFAULT '1',
  `storage_conditions` text COLLATE utf8mb4_unicode_ci,
  `storage_temp_min` decimal(5,2) DEFAULT NULL,
  `storage_temp_max` decimal(5,2) DEFAULT NULL,
  `indications` text COLLATE utf8mb4_unicode_ci,
  `contraindications` text COLLATE utf8mb4_unicode_ci,
  `side_effects` text COLLATE utf8mb4_unicode_ci,
  `drug_interactions` json DEFAULT NULL COMMENT '[{"drug_id": 123, "severity": "major"}]',
  `warnings` text COLLATE utf8mb4_unicode_ci,
  `precautions` text COLLATE utf8mb4_unicode_ci,
  `pregnancy_category` enum('A','B','C','D','X','N/A') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'N/A',
  `safe_in_pregnancy` tinyint(1) NOT NULL DEFAULT '0',
  `safe_in_lactation` tinyint(1) NOT NULL DEFAULT '0',
  `pediatric_use` tinyint(1) NOT NULL DEFAULT '1',
  `geriatric_considerations` text COLLATE utf8mb4_unicode_ci,
  `renal_dosing` text COLLATE utf8mb4_unicode_ci,
  `hepatic_dosing` text COLLATE utf8mb4_unicode_ci,
  `manufacturer` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `active_ingredient` text COLLATE utf8mb4_unicode_ci,
  `inactive_ingredients` text COLLATE utf8mb4_unicode_ci,
  `unit_of_measure` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `default_unit_price` decimal(10,2) NOT NULL DEFAULT '0.00',
  `current_stock` int NOT NULL DEFAULT '0',
  `reorder_level` int NOT NULL DEFAULT '50' COMMENT 'Alert when stock below this',
  `reorder_quantity` int NOT NULL DEFAULT '100' COMMENT 'Suggested reorder quantity',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `deactivation_reason` text COLLATE utf8mb4_unicode_ci,
  `created_by` bigint unsigned DEFAULT NULL,
  `updated_by` bigint unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `pharmacy_drugs_drug_code_unique` (`drug_code`),
  KEY `pharmacy_drugs_created_by_foreign` (`created_by`),
  KEY `pharmacy_drugs_updated_by_foreign` (`updated_by`),
  KEY `pharmacy_drugs_generic_name_index` (`generic_name`),
  KEY `pharmacy_drugs_drug_category_index` (`drug_category`),
  KEY `pharmacy_drugs_controlled_substance_index` (`controlled_substance`),
  KEY `pharmacy_drugs_is_active_index` (`is_active`),
  CONSTRAINT `pharmacy_drugs_created_by_foreign` FOREIGN KEY (`created_by`) REFERENCES `staff` (`id`) ON DELETE SET NULL,
  CONSTRAINT `pharmacy_drugs_updated_by_foreign` FOREIGN KEY (`updated_by`) REFERENCES `staff` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=103 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pharmacy_drugs`
--

LOCK TABLES `pharmacy_drugs` WRITE;
/*!40000 ALTER TABLE `pharmacy_drugs` DISABLE KEYS */;
INSERT INTO `pharmacy_drugs` VALUES (4,'DRG-00001','Dextrose 5%','[]','injection','500mls',NULL,'Other',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,'bottles',500.00,4,10,100,1,NULL,NULL,NULL,'2026-03-05 06:29:33','2026-03-05 09:58:49',NULL),(5,'DRG-00005','Glibenclamide','[]','tablet','5mg',NULL,'Antidiabetics',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,'tablets',10.00,1202,100,100,1,NULL,NULL,NULL,'2026-03-05 07:41:28','2026-03-05 09:17:37',NULL),(6,'DRG-00006','Metformin','[]','tablet','500mg',NULL,'Antidiabetics',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,10.00,400,100,100,1,NULL,NULL,NULL,'2026-03-05 07:43:37','2026-03-05 09:44:56',NULL),(7,'DRG-00007','Metformin','[]','tablet','850mg',NULL,'Antidiabetics',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,10.00,20,7,100,1,NULL,NULL,NULL,'2026-03-05 07:44:37','2026-03-05 09:41:32',NULL),(8,'DRG-00008','Folic Acid','[]','tablet','5mg',NULL,'Supplements & Vitamins',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,'tablets',10.00,299,100,100,1,NULL,NULL,NULL,'2026-03-05 07:49:58','2026-03-05 09:28:07',NULL),(9,'DRG-00009','IFAS','[]','tablet','265mg',NULL,'Supplements & Vitamins',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,'tablets',10.00,400,100,100,1,NULL,NULL,NULL,'2026-03-05 07:52:43','2026-03-05 09:37:55',NULL),(10,'DRG-00010','Nifedipine','[]','tablet','20mg',NULL,'Antihypertensives',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,'tablets',5.00,1600,100,100,1,NULL,NULL,NULL,'2026-03-05 07:54:02','2026-03-05 09:50:36',NULL),(11,'DRG-00011','Atenol','[]','tablet','50mg',NULL,'Antihypertensives',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,'tablets',5.00,28,20,100,1,NULL,NULL,NULL,'2026-03-05 07:57:23','2026-03-05 09:19:50',NULL),(12,'DRG-00012','Losartan H','[]','tablet','62.5mg',NULL,'Antihypertensives',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,'tablets',10.00,28,20,100,1,NULL,NULL,NULL,'2026-03-05 07:58:37','2026-03-05 09:40:18',NULL),(13,'DRG-00013','Losartan P','[]','tablet','50mg',NULL,'Antihypertensives',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,'tablets',10.00,28,20,100,1,NULL,NULL,NULL,'2026-03-05 07:59:16','2026-03-05 09:41:12',NULL),(14,'DRG-00014','Montelukast','[]','tablet','10mg',NULL,'Antihypertensives',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,'tablets',5.00,60,20,100,1,NULL,NULL,NULL,'2026-03-05 08:00:29','2026-03-05 09:50:10',NULL),(15,'DRG-00015','Atorvastatin','[]','tablet','20mg',NULL,'Antihypertensives',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,'tablets',5.00,90,20,100,1,NULL,NULL,NULL,'2026-03-05 08:02:17','2026-03-05 09:22:05',NULL),(16,'DRG-00016','Furosemide','[]','tablet','40mg',NULL,'Antihypertensives',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,'tablets',10.00,44,20,100,1,NULL,NULL,NULL,'2026-03-05 08:05:07','2026-03-05 09:31:27',NULL),(17,'DRG-00017','HCTZ','[]','tablet','25mg',NULL,'Antihypertensives',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,'tablets',5.00,490,100,100,1,NULL,NULL,NULL,'2026-03-05 08:08:23','2026-03-05 09:35:39',NULL),(18,'DRG-00018','Pyridoxine','[]','tablet','50mg',NULL,'Antihypertensives',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,'tablets',5.00,180,100,100,1,NULL,NULL,NULL,'2026-03-05 08:10:06','2026-03-05 09:51:28',NULL),(19,'DRG-00019','Bisacodyl','[]','tablet','5mg',NULL,'Antihypertensives',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,'tablets',5.00,59,100,100,1,NULL,NULL,NULL,'2026-03-05 08:12:35','2026-03-05 09:23:07',NULL),(20,'DRG-00020','Metoclopramide','[]','tablet','10mg',NULL,'Antihypertensives',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,'tablets',5.00,90,50,100,1,NULL,NULL,NULL,'2026-03-05 08:14:03','2026-03-05 09:49:40',NULL),(21,'DRG-00021','Diazepam','[]','tablet','5mg',NULL,'Antihypertensives',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,'tablets',5.00,40,30,100,1,NULL,NULL,NULL,'2026-03-05 08:15:22','2026-03-05 09:25:38',NULL),(22,'DRG-00022','Sulbutamol','[]','tablet','5mg',NULL,'Other',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,'tablets',5.00,1100,100,100,1,NULL,NULL,NULL,'2026-03-05 08:18:14','2026-03-05 09:51:49',NULL),(23,'DRG-00023','Clotrimazole','[]','cream','20grams',NULL,'Antifungals',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,'tablets',100.00,11,10,100,1,NULL,NULL,NULL,'2026-03-05 08:25:27','2026-03-05 09:23:56',NULL),(24,'DRG-00024','Clotrimazole Vaginal Pessaris','[]','tablet','100mg',NULL,'Antifungals',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,30.00,0,10,100,1,NULL,NULL,NULL,'2026-03-05 08:27:41','2026-03-05 08:27:41',NULL),(25,'DRG-00025','Andrin Nasal Drops','[]','drops','10ml',NULL,'Antihistamines & Allergy',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,'bottles',50.00,4,10,100,1,NULL,NULL,NULL,'2026-03-05 08:30:27','2026-03-05 09:24:18',NULL),(26,'DRG-00026','Tetracycline Hydrochloride Eye Ointment','[]','ointment','5grams',NULL,'Antibiotics',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,'bottles',50.00,8,10,100,1,NULL,NULL,NULL,'2026-03-05 08:34:06','2026-03-05 09:14:06',NULL),(27,'DRG-00027','Chlorhexidine Digluconate','[]','gel','10grams',NULL,'Other',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,'sachets',100.00,6,10,100,1,NULL,NULL,NULL,'2026-03-05 08:40:31','2026-03-05 09:13:30',NULL),(28,'DRG-00028','Sayana Press','[]','suspension','104mg/0,65ml',NULL,'Other',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,'pieces',200.00,35,10,100,1,NULL,NULL,NULL,'2026-03-05 08:45:36','2026-03-05 09:10:29',NULL),(29,'DRG-00029','Depo','[]','injection','150mg',NULL,'Other',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,'vials',200.00,6,10,100,1,NULL,NULL,NULL,'2026-03-05 08:49:03','2026-03-05 09:11:18',NULL),(30,'DRG-00030','Levonorgestrel','[]','tablet','0.75mg',NULL,'Other',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,'tablets',50.00,6,10,100,1,NULL,NULL,NULL,'2026-03-05 08:54:50','2026-03-05 09:11:40',NULL),(31,'DRG-00031','Femiplan Pills','[]','tablet','0.03mg',NULL,'Other',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,'tablets',5.00,504,28,100,1,NULL,NULL,NULL,'2026-03-05 09:03:04','2026-03-05 09:09:58',NULL),(32,'DRG-00032','Ringers Lactate','[]','injection','500ml',NULL,'Other',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,'bottles',500.00,29,10,100,1,NULL,NULL,NULL,'2026-03-05 09:07:07','2026-03-05 09:08:38',NULL),(33,'DRG-00033','Normal Saline','[]','injection','500ml',NULL,'Other',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,'bottles',500.00,39,10,100,1,NULL,NULL,NULL,'2026-03-05 09:56:56','2026-03-06 11:38:58',NULL),(34,'DRG-00034','Hydrocortisone','[]','injection','100mg',NULL,'Other',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,500.00,15,10,100,1,NULL,NULL,NULL,'2026-03-05 10:07:05','2026-03-05 10:07:56',NULL),(35,'DRG-00035','Benzyl Penicillin (XPEN)','[]','injection','1mega',NULL,'Antibiotics',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,'vials',200.00,10,10,100,1,NULL,NULL,NULL,'2026-03-05 11:24:59','2026-03-06 11:37:50',NULL),(36,'DRG-00036','Dexamethasone','[]','injection','4mg',NULL,'Other',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,200.00,50,10,100,1,NULL,NULL,NULL,'2026-03-05 11:27:11','2026-03-05 15:44:19',NULL),(37,'DRG-00037','Diclofenac','[]','injection','75mg',NULL,'Other',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,'pieces',200.00,120,10,100,1,NULL,NULL,NULL,'2026-03-05 11:30:18','2026-03-05 11:34:57',NULL),(38,'DRG-00038','Ceftriaxone','[]','injection','1gram',NULL,'Antibiotics',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,250.00,30,10,100,1,NULL,NULL,NULL,'2026-03-05 11:38:07','2026-03-05 11:38:37',NULL),(39,'DRG-00039','Gentamycin','[]','injection','80mg',NULL,'Antibiotics',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,100.00,140,10,100,1,NULL,NULL,NULL,'2026-03-05 11:43:12','2026-03-05 11:43:40',NULL),(40,'DRG-00040','Aminophylline','[]','injection','250mg',NULL,'Respiratory',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,300.00,4,10,100,1,NULL,NULL,NULL,'2026-03-05 11:49:07','2026-03-05 11:49:37',NULL),(41,'DRG-00041','Fluphenazine Decanoate','[]','injection','25mg',NULL,'Other',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1000.00,1,10,100,1,NULL,NULL,NULL,'2026-03-05 11:53:48','2026-03-05 11:54:22',NULL),(42,'DRG-00042','Diazepam','[]','injection','5mg',NULL,'Other',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,200.00,4,10,100,1,NULL,NULL,NULL,'2026-03-05 12:01:07','2026-03-05 12:01:36',NULL),(43,'DRG-00043','Frusemide(Lasix)','[]','injection','20mg',NULL,'Other',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,100.00,6,10,100,1,NULL,NULL,NULL,'2026-03-05 12:08:55','2026-03-05 12:09:15',NULL),(44,'DRG-00044','Atropine','[]','injection','1mg',NULL,'Cardiovascular',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,500.00,12,10,100,1,NULL,NULL,NULL,'2026-03-05 12:17:02','2026-03-05 12:25:38',NULL),(45,'DRG-00045','Adrenaline','[]','injection','1mg',NULL,'Cardiovascular',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,300.00,5,5,100,1,NULL,NULL,NULL,'2026-03-05 12:29:21','2026-03-05 12:29:37',NULL),(46,'DRG-00046','Metoclopramide (Plasil)','[]','injection','10mg',NULL,'Gastrointestinal',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,100.00,3,5,100,1,NULL,NULL,NULL,'2026-03-05 12:33:20','2026-03-05 12:35:33',NULL),(47,'DRG-00047','Lidocaine','[]','injection','30ml',NULL,'Anesthetics',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,300.00,21,10,100,1,NULL,NULL,NULL,'2026-03-05 12:43:58','2026-03-05 12:44:27',NULL),(48,'DRG-00048','Metronidazole','[]','injection','500mg',NULL,'Antibiotics',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,300.00,7,10,100,1,NULL,NULL,NULL,'2026-03-05 12:48:03','2026-03-05 12:48:23',NULL),(49,'DRG-00049','Iv Paracetamol','[]','injection','1gram',NULL,'Analgesics & Pain Relief',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,300.00,8,10,100,1,NULL,NULL,NULL,'2026-03-05 12:54:11','2026-03-06 11:53:09',NULL),(50,'DRG-00050','Ciprofloxacin','[]','injection','200mg',NULL,'Antibiotics',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,300.00,18,10,100,1,NULL,NULL,NULL,'2026-03-05 12:59:38','2026-03-05 12:59:53',NULL),(51,'DRG-00051','Quinine Dihydrochloride','[]','injection','600mg',NULL,'Antimalarials',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,'pieces',200.00,80,10,100,1,NULL,NULL,NULL,'2026-03-05 13:05:00','2026-03-05 13:16:11',NULL),(52,'DRG-00052','Im Artemether','[]','injection','80mg',NULL,'Antimalarials',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,100.00,54,10,100,1,NULL,NULL,NULL,'2026-03-05 13:08:28','2026-03-05 13:08:48',NULL),(53,'DRG-00053','Artemether & Lumefantrine','[]','tablet','20mg/120mg',NULL,'Antimalarials',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,5.00,456,48,100,1,NULL,NULL,NULL,'2026-03-05 13:14:55','2026-03-05 13:15:13',NULL),(54,'DRG-00054','P-Alaxin','[]','suspension','24grams',NULL,'Antimalarials',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,50.00,3,10,100,1,NULL,NULL,NULL,'2026-03-05 13:20:00','2026-03-05 13:21:13',NULL),(55,'DRG-00055','Artemether & Lumefantrine','[]','suspension','60ml',NULL,'Antimalarials',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,50.00,21,10,100,1,NULL,NULL,NULL,'2026-03-05 13:25:23','2026-03-05 13:25:36',NULL),(56,'DRG-00056','SPOTCLAV 625','[]','tablet','625MG',NULL,'Antibiotics',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,35.00,10,20,100,1,NULL,NULL,NULL,'2026-03-05 13:33:45','2026-03-05 13:34:10',NULL),(57,'DRG-00057','Labclav','[]','tablet','625mg',NULL,'Antibiotics',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,'tablets',35.00,30,20,100,1,NULL,NULL,NULL,'2026-03-05 13:36:00','2026-03-05 13:37:05',NULL),(58,'DRG-00058','Ciprofloxacin','[]','tablet','500mg',NULL,'Antibiotics',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,'tablets',10.00,480,100,100,1,NULL,NULL,NULL,'2026-03-05 13:39:46','2026-03-05 13:53:58',NULL),(59,'DRG-00059','Benzathine Benzylpenicillin  (2.4mega)','[]','tablet','500mg',NULL,'Antibiotics',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,300.00,30,20,100,1,NULL,NULL,NULL,'2026-03-05 13:43:42','2026-03-05 13:44:04',NULL),(60,'DRG-00060','Streptomycin Sulphate','[]','injection','1gram',NULL,'Antibiotics',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,200.00,19,10,100,1,NULL,NULL,NULL,'2026-03-05 13:46:57','2026-03-05 13:47:19',NULL),(61,'DRG-00061','Artesunate','[]','injection','60mg',NULL,'Antimalarials',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,200.00,19,10,100,1,NULL,NULL,NULL,'2026-03-05 13:51:15','2026-03-05 13:51:30',NULL),(62,'DRG-00062','Doxycycline','[]','capsule','100mg',NULL,'Antibiotics',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,5.00,500,100,100,1,NULL,NULL,NULL,'2026-03-05 13:56:59','2026-03-05 13:57:20',NULL),(63,'DRG-00063','Ampiclox','[]','capsule','500mg',NULL,'Antibiotics',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,5.00,400,100,100,1,NULL,NULL,NULL,'2026-03-05 13:59:48','2026-03-05 14:00:09',NULL),(64,'DRG-00064','Amoxicillin','[]','capsule','500mg',NULL,'Antibiotics',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,'capsules',5.00,900,100,100,1,NULL,NULL,NULL,'2026-03-05 14:03:02','2026-03-05 14:07:34',NULL),(65,'DRG-00065','Amoxicillin DT','[]','tablet','250mg',NULL,'Antibiotics',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,'tablets',5.00,300,100,100,1,NULL,NULL,NULL,'2026-03-05 14:05:44','2026-03-06 11:09:29',NULL),(66,'DRG-00066','Metronidazole','[]','tablet','400mg',NULL,'Antibiotics',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,'tablets',5.00,400,100,100,1,NULL,NULL,NULL,'2026-03-05 14:10:16','2026-03-05 14:11:35',NULL),(67,'DRG-00067','Tinidazole','[]','tablet','500mg',NULL,'Antibiotics',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,5.00,84,50,100,1,NULL,NULL,NULL,'2026-03-05 14:14:24','2026-03-05 14:14:42',NULL),(68,'DRG-00068','Co-Trimoxazole','[]','tablet','960mg',NULL,'Antibiotics',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,'tablets',5.00,800,50,100,1,NULL,NULL,NULL,'2026-03-05 14:17:38','2026-03-06 11:21:14',NULL),(69,'DRG-00069','Iv Esomeprazole','[]','injection','40mg',NULL,'Gastrointestinal',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,'vials',200.00,5,10,100,1,NULL,NULL,NULL,'2026-03-05 14:20:11','2026-03-05 14:21:09',NULL),(70,'DRG-00070','Omeprazole','[]','capsule','20mg',NULL,'Gastrointestinal',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,10.00,690,100,100,1,NULL,NULL,NULL,'2026-03-05 14:26:51','2026-03-05 14:27:08',NULL),(71,'DRG-00071','Nystatin','[]','suspension','30ml',NULL,'Antifungals',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,100.00,7,100,100,1,NULL,NULL,NULL,'2026-03-05 14:29:36','2026-03-05 14:29:51',NULL),(72,'DRG-00072','Secnidazole','[]','tablet','1gram',NULL,'Antibiotics',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,25.00,24,20,100,1,NULL,NULL,NULL,'2026-03-05 14:32:24','2026-03-05 14:32:40',NULL),(73,'DRG-00073','Albendazole (ABZ)','[]','tablet','400mg',NULL,'Antiparasitics',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,20.00,46,20,100,1,NULL,NULL,NULL,'2026-03-05 14:35:43','2026-03-05 14:36:00',NULL),(74,'DRG-00074','Fluconazole','[]','capsule','150mg',NULL,'Antifungals',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,20.00,24,20,100,1,NULL,NULL,NULL,'2026-03-05 14:38:56','2026-03-05 14:39:19',NULL),(75,'DRG-00075','Salorex','[]','syrup','100ml',NULL,'Respiratory',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,150.00,15,20,100,1,NULL,NULL,NULL,'2026-03-05 14:43:10','2026-03-05 14:43:36',NULL),(76,'DRG-00076','Vitaglobin','[]','syrup','200ml',NULL,'Supplements & Vitamins',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,450.00,8,10,100,1,NULL,NULL,NULL,'2026-03-05 14:47:56','2026-03-05 14:48:11',NULL),(77,'DRG-00077','Promivit','[]','syrup','100ml',NULL,'Supplements & Vitamins',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,150.00,26,10,100,1,NULL,NULL,NULL,'2026-03-05 14:50:00','2026-03-05 14:50:15',NULL),(78,'DRG-00078','Piroxicam','[]','capsule','20mg',NULL,'Analgesics & Pain Relief',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,5.00,700,100,100,1,NULL,NULL,NULL,'2026-03-05 14:53:31','2026-03-05 14:53:45',NULL),(79,'DRG-00079','Paracetamol','[]','suppository','250mg',NULL,'Analgesics & Pain Relief',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,50.00,10,10,100,1,NULL,NULL,NULL,'2026-03-05 14:57:07','2026-03-05 14:57:35',NULL),(80,'DRG-00080','Paracetamol','[]','suppository','125mg',NULL,'Analgesics & Pain Relief',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,50.00,20,10,100,1,NULL,NULL,NULL,'2026-03-05 14:58:06','2026-03-05 14:58:23',NULL),(81,'DRG-00081','Cetrizine','[]','tablet','10mg',NULL,'Antihistamines & Allergy',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,5.00,1200,100,100,1,NULL,NULL,NULL,'2026-03-05 15:01:39','2026-03-05 15:02:01',NULL),(82,'DRG-00082','Piriton','[]','tablet','4mg',NULL,'Antihistamines & Allergy',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,5.00,500,100,100,1,NULL,NULL,NULL,'2026-03-05 15:03:06','2026-03-05 15:03:29',NULL),(83,'DRG-00083','Paracetamol','[]','tablet','500mg',NULL,'Analgesics & Pain Relief',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,5.00,598,100,100,1,NULL,NULL,NULL,'2026-03-05 15:04:58','2026-03-06 12:57:56',NULL),(84,'DRG-00084','Ibuprofen','[]','tablet','200mg',NULL,'Analgesics & Pain Relief',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,5.00,600,100,100,1,NULL,NULL,NULL,'2026-03-05 15:07:02','2026-03-05 15:07:27',NULL),(85,'DRG-00085','Ibuprofen','[]','tablet','400mg',NULL,'Analgesics & Pain Relief',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,5.00,700,100,100,1,NULL,NULL,NULL,'2026-03-05 15:08:22','2026-03-05 15:08:38',NULL),(86,'DRG-00086','Metronidazole','[]','suspension','60ml',NULL,'Antibiotics',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,100.00,40,50,100,1,NULL,NULL,NULL,'2026-03-05 15:11:50','2026-03-05 15:12:14',NULL),(87,'DRG-00087','Metronidazole','[]','suspension','100ml',NULL,'Antibiotics',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,150.00,11,20,100,1,NULL,NULL,NULL,'2026-03-05 15:13:54','2026-03-05 15:14:22',NULL),(88,'DRG-00088','Zinc Sulphate','[]','tablet','20mg',NULL,'Supplements & Vitamins',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,15.00,0,20,100,1,NULL,NULL,NULL,'2026-03-05 15:16:12','2026-03-05 15:16:12',NULL),(89,'DRG-00089','Oral Rehydration Salts (ORS)','[]','suspension','500ml',NULL,'Supplements & Vitamins',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,30.00,55,20,100,1,NULL,NULL,NULL,'2026-03-05 15:19:30','2026-03-05 15:19:46',NULL),(90,'DRG-00090','Azithromycin','[]','suspension','15ml',NULL,'Antibiotics',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,50.00,22,20,100,1,NULL,NULL,NULL,'2026-03-05 15:21:54','2026-03-05 15:22:14',NULL),(91,'DRG-00091','Amoxiclav','[]','suspension','70ml',NULL,'Antibiotics',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,100.00,6,20,100,1,NULL,NULL,NULL,'2026-03-05 15:24:48','2026-03-05 15:25:07',NULL),(92,'DRG-00092','Ibuprofen','[]','suspension','60ml',NULL,'Analgesics & Pain Relief',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,100.00,11,20,100,1,NULL,NULL,NULL,'2026-03-05 15:28:13','2026-03-05 15:28:27',NULL),(93,'DRG-00093','Co-Trimoxazole','[]','suspension','50ml',NULL,'Antibiotics',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,100.00,15,20,100,1,NULL,NULL,NULL,'2026-03-05 15:30:21','2026-03-05 15:30:39',NULL),(94,'DRG-00094','Piriton','[]','syrup','50ml',NULL,'Antihistamines & Allergy',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,100.00,15,20,100,1,NULL,NULL,NULL,'2026-03-05 15:31:51','2026-03-05 15:32:05',NULL),(95,'DRG-00095','Paracetamol','[]','suspension','60ml',NULL,'Analgesics & Pain Relief',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,100.00,11,20,100,1,NULL,NULL,NULL,'2026-03-05 15:33:40','2026-03-05 15:34:00',NULL),(96,'DRG-00096','Sulbutamol','[]','syrup','60ml',NULL,'Respiratory',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,50.00,15,20,100,1,NULL,NULL,NULL,'2026-03-05 15:36:13','2026-03-05 15:36:28',NULL),(97,'DRG-00097','Promethazine Hydrochloride','[]','syrup','60ml',NULL,'Antihistamines & Allergy',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,50.00,18,15,100,1,NULL,NULL,NULL,'2026-03-05 15:41:15','2026-03-05 15:41:33',NULL),(98,'DRG-00098','Cetrizine','[]','syrup','60ml',NULL,'Antihistamines & Allergy',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,50.00,9,10,100,1,NULL,NULL,NULL,'2026-03-05 15:42:40','2026-03-05 15:42:57',NULL),(99,'DRG-00099','Glysit (Dapagliflozin)','[]','tablet','5mg',NULL,'Antidiabetics',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,100.00,56,10,100,1,NULL,NULL,NULL,'2026-03-06 11:19:56','2026-03-06 11:20:09',NULL),(100,'DRG-00100','Nelgra (Viagra gen)','[]','tablet','50mg',NULL,'Other',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,20.00,80,20,100,1,NULL,NULL,NULL,'2026-03-06 11:33:52','2026-03-06 11:34:07',NULL),(101,'DRG-00101','Prednisolone','[]','tablet','5mg',NULL,'Other',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,5.00,1900,20,100,1,NULL,NULL,NULL,'2026-03-06 11:37:02','2026-03-06 11:37:20',NULL),(102,'DRG-00102','Calamine Lotion','[]','cream','100ml',NULL,'Other',NULL,0,NULL,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'N/A',0,0,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,100.00,15,10,100,1,NULL,NULL,NULL,'2026-03-06 11:40:48','2026-03-06 11:41:11',NULL);
/*!40000 ALTER TABLE `pharmacy_drugs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pharmacy_inventory_transactions`
--

DROP TABLE IF EXISTS `pharmacy_inventory_transactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pharmacy_inventory_transactions` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `transaction_number` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'TXN-20251206-0001',
  `batch_id` bigint unsigned NOT NULL,
  `drug_id` bigint unsigned NOT NULL,
  `transaction_type` enum('receipt','dispensation','return','adjustment','transfer_out','transfer_in','damage','expiry','recall','loss','sample') COLLATE utf8mb4_unicode_ci NOT NULL,
  `quantity` int NOT NULL COMMENT 'Positive or negative',
  `balance_before` int NOT NULL,
  `balance_after` int NOT NULL,
  `reference_type` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'dispensation, purchase_order, etc.',
  `reference_id` bigint DEFAULT NULL COMMENT 'ID of related record',
  `from_location` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `to_location` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `reason` text COLLATE utf8mb4_unicode_ci,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `performed_by` bigint unsigned NOT NULL,
  `authorized_by` bigint unsigned DEFAULT NULL COMMENT 'Supervisor approval',
  `transaction_date` timestamp NOT NULL,
  `requires_authorization` tinyint(1) NOT NULL DEFAULT '0',
  `is_authorized` tinyint(1) NOT NULL DEFAULT '0',
  `unit_cost` decimal(10,2) DEFAULT NULL,
  `total_value` decimal(10,2) DEFAULT NULL COMMENT 'quantity * unit_cost',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `pharmacy_inventory_transactions_transaction_number_unique` (`transaction_number`),
  KEY `idx_pharm_inv_txn_reference` (`reference_type`,`reference_id`),
  KEY `pharmacy_inventory_transactions_performed_by_foreign` (`performed_by`),
  KEY `pharmacy_inventory_transactions_authorized_by_foreign` (`authorized_by`),
  KEY `pharmacy_inventory_transactions_batch_id_transaction_date_index` (`batch_id`,`transaction_date`),
  KEY `pharmacy_inventory_transactions_drug_id_transaction_type_index` (`drug_id`,`transaction_type`),
  KEY `pharmacy_inventory_transactions_transaction_type_index` (`transaction_type`),
  KEY `pharmacy_inventory_transactions_transaction_date_index` (`transaction_date`),
  CONSTRAINT `pharmacy_inventory_transactions_authorized_by_foreign` FOREIGN KEY (`authorized_by`) REFERENCES `staff` (`id`) ON DELETE SET NULL,
  CONSTRAINT `pharmacy_inventory_transactions_batch_id_foreign` FOREIGN KEY (`batch_id`) REFERENCES `pharmacy_drug_batches` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `pharmacy_inventory_transactions_drug_id_foreign` FOREIGN KEY (`drug_id`) REFERENCES `pharmacy_drugs` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `pharmacy_inventory_transactions_performed_by_foreign` FOREIGN KEY (`performed_by`) REFERENCES `staff` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=106 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pharmacy_inventory_transactions`
--

LOCK TABLES `pharmacy_inventory_transactions` WRITE;
/*!40000 ALTER TABLE `pharmacy_inventory_transactions` DISABLE KEYS */;
INSERT INTO `pharmacy_inventory_transactions` VALUES (1,'TXN-20260305-0001',1,25,'transfer_in',4,0,4,'inventory_item',25,'main_store','pharmacy','Transferred from Main Store','Source: MED-00025 - Andrin Nasal Drops',2,NULL,'2026-03-05 08:30:59',0,0,30.00,120.00,'2026-03-05 08:30:59','2026-03-05 08:30:59'),(2,'TXN-20260305-0002',2,26,'transfer_in',8,0,8,'inventory_item',26,'main_store','pharmacy','Transferred from Main Store','Source: MED-00026 - Tetracycline Hydrochloride Eye Ointment',2,NULL,'2026-03-05 08:34:29',0,0,30.00,240.00,'2026-03-05 08:34:29','2026-03-05 08:34:29'),(3,'TXN-20260305-0003',3,27,'transfer_in',6,0,6,'inventory_item',27,'main_store','pharmacy','Transferred from Main Store','Source: MED-00027 - Chlorhexidine Digluconate',2,NULL,'2026-03-05 08:40:55',0,0,30.00,180.00,'2026-03-05 08:40:55','2026-03-05 08:40:55'),(4,'TXN-20260305-0004',4,28,'transfer_in',35,0,35,'inventory_item',28,'main_store','pharmacy','Transferred from Main Store','Source: MED-00028 - Sayana Press',2,NULL,'2026-03-05 08:46:06',0,0,50.00,1750.00,'2026-03-05 08:46:06','2026-03-05 08:46:06'),(5,'TXN-20260305-0005',5,29,'transfer_in',6,0,6,'inventory_item',29,'main_store','pharmacy','Transferred from Main Store','Source: MED-00029 - Depo',2,NULL,'2026-03-05 08:49:47',0,0,50.00,300.00,'2026-03-05 08:49:47','2026-03-05 08:49:47'),(6,'TXN-20260305-0006',6,30,'transfer_in',6,0,6,'inventory_item',30,'main_store','pharmacy','Transferred from Main Store','Source: MED-00030 - Levonorgestrel',2,NULL,'2026-03-05 08:55:17',0,0,10.00,60.00,'2026-03-05 08:55:17','2026-03-05 08:55:17'),(7,'TXN-20260305-0007',7,31,'transfer_in',504,0,504,'inventory_item',31,'main_store','pharmacy','Transferred from Main Store','Source: MED-00031 - Femiplan Pills',2,NULL,'2026-03-05 09:03:40',0,0,2.50,1260.00,'2026-03-05 09:03:40','2026-03-05 09:03:40'),(8,'TXN-20260305-0008',8,32,'transfer_in',29,0,29,'inventory_item',32,'main_store','pharmacy','Transferred from Main Store','Source: MED-00032 - Ringers Lactate',2,NULL,'2026-03-05 09:07:30',0,0,80.00,2320.00,'2026-03-05 09:07:30','2026-03-05 09:07:30'),(9,'TXN-20260305-0009',9,4,'transfer_in',4,0,4,'inventory_item',4,'main_store','pharmacy','Transferred from Main Store','Source: MED-00004 - Dextrose',2,NULL,'2026-03-05 09:15:20',0,0,100.00,400.00,'2026-03-05 09:15:20','2026-03-05 09:15:20'),(10,'TXN-20260305-0010',10,5,'transfer_in',1202,0,1202,'inventory_item',5,'main_store','pharmacy','Transferred from Main Store','Source: MED-00005 - Glibenclamide',2,NULL,'2026-03-05 09:16:34',0,0,2.30,2764.60,'2026-03-05 09:16:34','2026-03-05 09:16:34'),(11,'TXN-20260305-0011',11,11,'transfer_in',28,0,28,'inventory_item',11,'main_store','pharmacy','Transferred from Main Store','Source: MED-00011 - Atenolol',2,NULL,'2026-03-05 09:19:31',0,0,2.30,64.40,'2026-03-05 09:19:31','2026-03-05 09:19:31'),(12,'TXN-20260305-0012',12,15,'transfer_in',90,0,90,'inventory_item',15,'main_store','pharmacy','Transferred from Main Store','Source: MED-00015 - Atorvastatin',2,NULL,'2026-03-05 09:21:47',0,0,2.30,207.00,'2026-03-05 09:21:47','2026-03-05 09:21:47'),(13,'TXN-20260305-0013',13,19,'transfer_in',59,0,59,'inventory_item',19,'main_store','pharmacy','Transferred from Main Store','Source: MED-00019 - Bisacodyl',2,NULL,'2026-03-05 09:22:50',0,0,2.30,135.70,'2026-03-05 09:22:50','2026-03-05 09:22:50'),(14,'TXN-20260305-0014',14,23,'transfer_in',11,0,11,'inventory_item',23,'main_store','pharmacy','Transferred from Main Store','Source: MED-00023 - Clotrimazole',2,NULL,'2026-03-05 09:23:36',0,0,30.00,330.00,'2026-03-05 09:23:36','2026-03-05 09:23:36'),(15,'TXN-20260305-0015',15,21,'transfer_in',40,0,40,'inventory_item',21,'main_store','pharmacy','Transferred from Main Store','Source: MED-00021 - Diazepam',2,NULL,'2026-03-05 09:25:13',0,0,2.30,92.00,'2026-03-05 09:25:13','2026-03-05 09:25:13'),(16,'TXN-20260305-0016',16,8,'transfer_in',299,0,299,'inventory_item',8,'main_store','pharmacy','Transferred from Main Store','Source: MED-00008 - Folic Acid',2,NULL,'2026-03-05 09:27:37',0,0,2.30,687.70,'2026-03-05 09:27:37','2026-03-05 09:27:37'),(17,'TXN-20260305-0017',17,16,'transfer_in',44,0,44,'inventory_item',16,'main_store','pharmacy','Transferred from Main Store','Source: MED-00016 - Furosemide',2,NULL,'2026-03-05 09:31:27',0,0,2.50,110.00,'2026-03-05 09:31:27','2026-03-05 09:31:27'),(18,'TXN-20260305-0018',18,17,'transfer_in',490,0,490,'inventory_item',17,'main_store','pharmacy','Transferred from Main Store','Source: MED-00017 - HCTZ',2,NULL,'2026-03-05 09:35:39',0,0,2.50,1225.00,'2026-03-05 09:35:39','2026-03-05 09:35:39'),(19,'TXN-20260305-0019',19,9,'transfer_in',400,0,400,'inventory_item',9,'main_store','pharmacy','Transferred from Main Store','Source: MED-00009 - IFAS',2,NULL,'2026-03-05 09:37:16',0,0,2.30,920.00,'2026-03-05 09:37:16','2026-03-05 09:37:16'),(20,'TXN-20260305-0020',20,12,'transfer_in',28,0,28,'inventory_item',12,'main_store','pharmacy','Transferred from Main Store','Source: MED-00012 - Losartan H',2,NULL,'2026-03-05 09:38:56',0,0,2.30,64.40,'2026-03-05 09:38:56','2026-03-05 09:38:56'),(21,'TXN-20260305-0021',21,13,'transfer_in',28,0,28,'inventory_item',13,'main_store','pharmacy','Transferred from Main Store','Source: MED-00013 - Losartan P',2,NULL,'2026-03-05 09:40:52',0,0,2.30,64.40,'2026-03-05 09:40:52','2026-03-05 09:40:52'),(22,'TXN-20260305-0022',22,7,'transfer_in',20,0,20,'inventory_item',7,'main_store','pharmacy','Transferred from Main Store','Source: MED-00007 - Metformin',2,NULL,'2026-03-05 09:41:32',0,0,10.00,200.00,'2026-03-05 09:41:32','2026-03-05 09:41:32'),(23,'TXN-20260305-0023',23,6,'transfer_in',400,0,400,'inventory_item',6,'main_store','pharmacy','Transferred from Main Store','Source: MED-00006 - Metformin',2,NULL,'2026-03-05 09:44:56',0,0,10.00,4000.00,'2026-03-05 09:44:56','2026-03-05 09:44:56'),(24,'TXN-20260305-0024',24,20,'transfer_in',90,0,90,'inventory_item',20,'main_store','pharmacy','Transferred from Main Store','Source: MED-00020 - Metoclopramide',2,NULL,'2026-03-05 09:49:40',0,0,5.00,450.00,'2026-03-05 09:49:40','2026-03-05 09:49:40'),(25,'TXN-20260305-0025',25,14,'transfer_in',60,0,60,'inventory_item',14,'main_store','pharmacy','Transferred from Main Store','Source: MED-00014 - Montelukast',2,NULL,'2026-03-05 09:50:10',0,0,5.00,300.00,'2026-03-05 09:50:10','2026-03-05 09:50:10'),(26,'TXN-20260305-0026',26,10,'transfer_in',1600,0,1600,'inventory_item',10,'main_store','pharmacy','Transferred from Main Store','Source: MED-00010 - Nifedipine',2,NULL,'2026-03-05 09:50:36',0,0,5.00,8000.00,'2026-03-05 09:50:36','2026-03-05 09:50:36'),(27,'TXN-20260305-0027',27,18,'transfer_in',180,0,180,'inventory_item',18,'main_store','pharmacy','Transferred from Main Store','Source: MED-00018 - Pyridoxine',2,NULL,'2026-03-05 09:51:28',0,0,5.00,900.00,'2026-03-05 09:51:28','2026-03-05 09:51:28'),(28,'TXN-20260305-0028',28,22,'transfer_in',1100,0,1100,'inventory_item',22,'main_store','pharmacy','Transferred from Main Store','Source: MED-00022 - Sulbutamol',2,NULL,'2026-03-05 09:51:49',0,0,5.00,5500.00,'2026-03-05 09:51:49','2026-03-05 09:51:49'),(29,'TXN-20260305-0029',29,33,'transfer_in',9,0,9,'inventory_item',33,'main_store','pharmacy','Transferred from Main Store','Source: MED-00033 - Normal Saline',2,NULL,'2026-03-05 09:57:24',0,0,500.00,4500.00,'2026-03-05 09:57:24','2026-03-05 09:57:24'),(30,'TXN-20260305-0030',39,34,'transfer_in',15,0,15,'inventory_item',34,'main_store','pharmacy','Transferred from Main Store','Source: MED-00034 - Hydrocortisone',2,NULL,'2026-03-05 10:07:56',0,0,500.00,7500.00,'2026-03-05 10:07:56','2026-03-05 10:07:56'),(31,'TXN-20260305-0031',40,35,'transfer_in',10,0,10,'inventory_item',35,'main_store','pharmacy','Transferred from Main Store','Source: MED-00035 - Benzyl Penicillin (XPEN)',2,NULL,'2026-03-05 11:31:42',0,0,200.00,2000.00,'2026-03-05 11:31:42','2026-03-05 11:31:42'),(32,'TXN-20260305-0032',41,37,'transfer_in',120,0,120,'inventory_item',37,'main_store','pharmacy','Transferred from Main Store','Source: MED-00037 - Diclofenac',2,NULL,'2026-03-05 11:34:57',0,0,200.00,24000.00,'2026-03-05 11:34:57','2026-03-05 11:34:57'),(33,'TXN-20260305-0033',42,38,'transfer_in',30,0,30,'inventory_item',38,'main_store','pharmacy','Transferred from Main Store','Source: MED-00038 - Ceftriaxone',2,NULL,'2026-03-05 11:38:37',0,0,250.00,7500.00,'2026-03-05 11:38:37','2026-03-05 11:38:37'),(34,'TXN-20260305-0034',43,39,'transfer_in',140,0,140,'inventory_item',39,'main_store','pharmacy','Transferred from Main Store','Source: MED-00039 - Gentamycin',2,NULL,'2026-03-05 11:43:40',0,0,100.00,14000.00,'2026-03-05 11:43:40','2026-03-05 11:43:40'),(35,'TXN-20260305-0035',44,40,'transfer_in',4,0,4,'inventory_item',40,'main_store','pharmacy','Transferred from Main Store','Source: MED-00040 - Aminophylline',2,NULL,'2026-03-05 11:49:37',0,0,300.00,1200.00,'2026-03-05 11:49:37','2026-03-05 11:49:37'),(36,'TXN-20260305-0036',45,41,'transfer_in',1,0,1,'inventory_item',41,'main_store','pharmacy','Transferred from Main Store','Source: MED-00041 - Fluphenazine Decanoate',2,NULL,'2026-03-05 11:54:22',0,0,1000.00,1000.00,'2026-03-05 11:54:22','2026-03-05 11:54:22'),(37,'TXN-20260305-0037',46,42,'transfer_in',4,0,4,'inventory_item',42,'main_store','pharmacy','Transferred from Main Store','Source: MED-00042 - Diazepam',2,NULL,'2026-03-05 12:01:36',0,0,200.00,800.00,'2026-03-05 12:01:36','2026-03-05 12:01:36'),(38,'TXN-20260305-0038',47,43,'transfer_in',6,0,6,'inventory_item',43,'main_store','pharmacy','Transferred from Main Store','Source: MED-00043 - Frusemide(Lasix)',2,NULL,'2026-03-05 12:09:15',0,0,100.00,600.00,'2026-03-05 12:09:15','2026-03-05 12:09:15'),(39,'TXN-20260305-0039',48,44,'transfer_in',12,0,12,'inventory_item',44,'main_store','pharmacy','Transferred from Main Store','Source: MED-00044 - Atropine',2,NULL,'2026-03-05 12:25:38',0,0,500.00,6000.00,'2026-03-05 12:25:38','2026-03-05 12:25:38'),(40,'TXN-20260305-0040',49,45,'transfer_in',5,0,5,'inventory_item',45,'main_store','pharmacy','Transferred from Main Store','Source: MED-00045 - Adrenaline',2,NULL,'2026-03-05 12:29:37',0,0,300.00,1500.00,'2026-03-05 12:29:37','2026-03-05 12:29:37'),(41,'TXN-20260305-0041',50,46,'transfer_in',2,0,2,'inventory_item',46,'main_store','pharmacy','Transferred from Main Store','Source: MED-00046 - Metoclopramide (Plasil)',2,NULL,'2026-03-05 12:34:30',0,0,100.00,200.00,'2026-03-05 12:34:30','2026-03-05 12:34:30'),(42,'TXN-20260305-0042',51,46,'transfer_in',1,0,1,'inventory_item',46,'main_store','pharmacy','Transferred from Main Store','Source: MED-00046 - Metoclopramide (Plasil)',2,NULL,'2026-03-05 12:35:33',0,0,100.00,100.00,'2026-03-05 12:35:33','2026-03-05 12:35:33'),(43,'TXN-20260305-0043',52,47,'transfer_in',21,0,21,'inventory_item',47,'main_store','pharmacy','Transferred from Main Store','Source: MED-00047 - Lidocaine',2,NULL,'2026-03-05 12:44:27',0,0,300.00,6300.00,'2026-03-05 12:44:27','2026-03-05 12:44:27'),(44,'TXN-20260305-0044',53,48,'transfer_in',7,0,7,'inventory_item',48,'main_store','pharmacy','Transferred from Main Store','Source: MED-00048 - Metronidazole',2,NULL,'2026-03-05 12:48:23',0,0,300.00,2100.00,'2026-03-05 12:48:23','2026-03-05 12:48:23'),(45,'TXN-20260305-0045',54,49,'transfer_in',9,0,9,'inventory_item',49,'main_store','pharmacy','Transferred from Main Store','Source: MED-00049 - Iv Paracetamol',2,NULL,'2026-03-05 12:54:44',0,0,300.00,2700.00,'2026-03-05 12:54:44','2026-03-05 12:54:44'),(46,'TXN-20260305-0046',55,50,'transfer_in',18,0,18,'inventory_item',50,'main_store','pharmacy','Transferred from Main Store','Source: MED-00050 - Ciprofloxacin',2,NULL,'2026-03-05 12:59:53',0,0,300.00,5400.00,'2026-03-05 12:59:53','2026-03-05 12:59:53'),(47,'TXN-20260305-0047',56,51,'transfer_in',80,0,80,'inventory_item',51,'main_store','pharmacy','Transferred from Main Store','Source: MED-00051 - Quinine Dihydrochloride',2,NULL,'2026-03-05 13:05:16',0,0,200.00,16000.00,'2026-03-05 13:05:16','2026-03-05 13:05:16'),(48,'TXN-20260305-0048',57,52,'transfer_in',54,0,54,'inventory_item',52,'main_store','pharmacy','Transferred from Main Store','Source: MED-00052 - Im Artemether',2,NULL,'2026-03-05 13:08:48',0,0,100.00,5400.00,'2026-03-05 13:08:48','2026-03-05 13:08:48'),(49,'TXN-20260305-0049',58,53,'transfer_in',456,0,456,'inventory_item',53,'main_store','pharmacy','Transferred from Main Store','Source: MED-00053 - AL',2,NULL,'2026-03-05 13:15:13',0,0,5.00,2280.00,'2026-03-05 13:15:13','2026-03-05 13:15:13'),(50,'TXN-20260305-0050',59,54,'transfer_in',3,0,3,'inventory_item',54,'main_store','pharmacy','Transferred from Main Store','Source: MED-00054 - P-Alaxin',2,NULL,'2026-03-05 13:21:13',0,0,50.00,150.00,'2026-03-05 13:21:13','2026-03-05 13:21:13'),(51,'TXN-20260305-0051',60,55,'transfer_in',21,0,21,'inventory_item',55,'main_store','pharmacy','Transferred from Main Store','Source: MED-00055 - Artemether & Lumefantrine',2,NULL,'2026-03-05 13:25:36',0,0,50.00,1050.00,'2026-03-05 13:25:36','2026-03-05 13:25:36'),(52,'TXN-20260305-0052',61,56,'transfer_in',10,0,10,'inventory_item',56,'main_store','pharmacy','Transferred from Main Store','Source: MED-00056 - Amoxicillin & Clavulanate Potassium',2,NULL,'2026-03-05 13:34:10',0,0,35.00,350.00,'2026-03-05 13:34:10','2026-03-05 13:34:10'),(53,'TXN-20260305-0053',62,57,'transfer_in',30,0,30,'inventory_item',57,'main_store','pharmacy','Transferred from Main Store','Source: MED-00057 - Amoxicillin & Clavulanate Potassium',2,NULL,'2026-03-05 13:37:05',0,0,35.00,1050.00,'2026-03-05 13:37:05','2026-03-05 13:37:05'),(54,'TXN-20260305-0054',63,58,'transfer_in',80,0,80,'inventory_item',58,'main_store','pharmacy','Transferred from Main Store','Source: MED-00058 - Ciprofloxacin',2,NULL,'2026-03-05 13:40:00',0,0,10.00,800.00,'2026-03-05 13:40:00','2026-03-05 13:40:00'),(55,'TXN-20260305-0055',64,59,'transfer_in',30,0,30,'inventory_item',59,'main_store','pharmacy','Transferred from Main Store','Source: MED-00059 - Benzathine Benzylpenicillin (2.4mega)',2,NULL,'2026-03-05 13:44:04',0,0,300.00,9000.00,'2026-03-05 13:44:04','2026-03-05 13:44:04'),(56,'TXN-20260305-0056',65,60,'transfer_in',19,0,19,'inventory_item',60,'main_store','pharmacy','Transferred from Main Store','Source: MED-00060 - Streptomycin Sulphate',2,NULL,'2026-03-05 13:47:19',0,0,200.00,3800.00,'2026-03-05 13:47:19','2026-03-05 13:47:19'),(57,'TXN-20260305-0057',66,61,'transfer_in',19,0,19,'inventory_item',61,'main_store','pharmacy','Transferred from Main Store','Source: MED-00061 - Artesunate',2,NULL,'2026-03-05 13:51:30',0,0,200.00,3800.00,'2026-03-05 13:51:30','2026-03-05 13:51:30'),(58,'TXN-20260305-0058',67,58,'transfer_in',400,0,400,'inventory_item',58,'main_store','pharmacy','Transferred from Main Store','Source: MED-00058 - Ciprofloxacin',2,NULL,'2026-03-05 13:53:58',0,0,10.00,4000.00,'2026-03-05 13:53:58','2026-03-05 13:53:58'),(59,'TXN-20260305-0059',68,62,'transfer_in',500,0,500,'inventory_item',62,'main_store','pharmacy','Transferred from Main Store','Source: MED-00062 - Doxycycline',2,NULL,'2026-03-05 13:57:20',0,0,5.00,2500.00,'2026-03-05 13:57:20','2026-03-05 13:57:20'),(60,'TXN-20260305-0060',69,63,'transfer_in',400,0,400,'inventory_item',63,'main_store','pharmacy','Transferred from Main Store','Source: MED-00063 - Ampiclox',2,NULL,'2026-03-05 14:00:09',0,0,5.00,2000.00,'2026-03-05 14:00:09','2026-03-05 14:00:09'),(61,'TXN-20260305-0061',70,64,'transfer_in',100,0,100,'inventory_item',64,'main_store','pharmacy','Transferred from Main Store','Source: MED-00064 - Amoxicillin',2,NULL,'2026-03-05 14:03:19',0,0,5.00,500.00,'2026-03-05 14:03:19','2026-03-05 14:03:19'),(62,'TXN-20260305-0062',71,65,'transfer_in',100,0,100,'inventory_item',65,'main_store','pharmacy','Transferred from Main Store','Source: MED-00065 - Amoxicillin DT',2,NULL,'2026-03-05 14:06:02',0,0,5.00,500.00,'2026-03-05 14:06:02','2026-03-05 14:06:02'),(63,'TXN-20260305-0063',72,64,'transfer_in',800,0,800,'inventory_item',64,'main_store','pharmacy','Transferred from Main Store','Source: MED-00064 - Amoxicillin',2,NULL,'2026-03-05 14:07:34',0,0,5.00,4000.00,'2026-03-05 14:07:34','2026-03-05 14:07:34'),(64,'TXN-20260305-0064',73,66,'transfer_in',400,0,400,'inventory_item',66,'main_store','pharmacy','Transferred from Main Store','Source: MED-00066 - Metronidazole',2,NULL,'2026-03-05 14:11:14',0,0,5.00,2000.00,'2026-03-05 14:11:14','2026-03-05 14:11:14'),(65,'TXN-20260305-0065',74,67,'transfer_in',84,0,84,'inventory_item',67,'main_store','pharmacy','Transferred from Main Store','Source: MED-00067 - Tinidazole',2,NULL,'2026-03-05 14:14:42',0,0,5.00,420.00,'2026-03-05 14:14:42','2026-03-05 14:14:42'),(66,'TXN-20260305-0066',75,68,'transfer_in',200,0,200,'inventory_item',68,'main_store','pharmacy','Transferred from Main Store','Source: MED-00068 - Co-Trimoxazole',2,NULL,'2026-03-05 14:17:56',0,0,5.00,1000.00,'2026-03-05 14:17:56','2026-03-05 14:17:56'),(67,'TXN-20260305-0067',76,69,'transfer_in',5,0,5,'inventory_item',69,'main_store','pharmacy','Transferred from Main Store','Source: MED-00069 - Iv Esomeprazole',2,NULL,'2026-03-05 14:21:09',0,0,200.00,1000.00,'2026-03-05 14:21:09','2026-03-05 14:21:09'),(68,'TXN-20260305-0068',77,70,'transfer_in',690,0,690,'inventory_item',70,'main_store','pharmacy','Transferred from Main Store','Source: MED-00070 - Omeprazole',2,NULL,'2026-03-05 14:27:08',0,0,10.00,6900.00,'2026-03-05 14:27:08','2026-03-05 14:27:08'),(69,'TXN-20260305-0069',78,71,'transfer_in',7,0,7,'inventory_item',71,'main_store','pharmacy','Transferred from Main Store','Source: MED-00071 - Nystatin',2,NULL,'2026-03-05 14:29:51',0,0,100.00,700.00,'2026-03-05 14:29:51','2026-03-05 14:29:51'),(70,'TXN-20260305-0070',79,72,'transfer_in',24,0,24,'inventory_item',72,'main_store','pharmacy','Transferred from Main Store','Source: MED-00072 - Secnidazole',2,NULL,'2026-03-05 14:32:40',0,0,25.00,600.00,'2026-03-05 14:32:40','2026-03-05 14:32:40'),(71,'TXN-20260305-0071',80,73,'transfer_in',46,0,46,'inventory_item',73,'main_store','pharmacy','Transferred from Main Store','Source: MED-00073 - Albendazole (ABZ)',2,NULL,'2026-03-05 14:36:00',0,0,20.00,920.00,'2026-03-05 14:36:00','2026-03-05 14:36:00'),(72,'TXN-20260305-0072',81,74,'transfer_in',24,0,24,'inventory_item',74,'main_store','pharmacy','Transferred from Main Store','Source: MED-00074 - Fluconazole',2,NULL,'2026-03-05 14:39:19',0,0,20.00,480.00,'2026-03-05 14:39:19','2026-03-05 14:39:19'),(73,'TXN-20260305-0073',82,75,'transfer_in',15,0,15,'inventory_item',75,'main_store','pharmacy','Transferred from Main Store','Source: MED-00075 - Salorex',2,NULL,'2026-03-05 14:43:36',0,0,150.00,2250.00,'2026-03-05 14:43:36','2026-03-05 14:43:36'),(74,'TXN-20260305-0074',83,76,'transfer_in',8,0,8,'inventory_item',76,'main_store','pharmacy','Transferred from Main Store','Source: MED-00076 - Vitaglobin',2,NULL,'2026-03-05 14:48:11',0,0,450.00,3600.00,'2026-03-05 14:48:11','2026-03-05 14:48:11'),(75,'TXN-20260305-0075',84,77,'transfer_in',26,0,26,'inventory_item',77,'main_store','pharmacy','Transferred from Main Store','Source: MED-00077 - Promivit',2,NULL,'2026-03-05 14:50:15',0,0,150.00,3900.00,'2026-03-05 14:50:15','2026-03-05 14:50:15'),(76,'TXN-20260305-0076',85,78,'transfer_in',700,0,700,'inventory_item',78,'main_store','pharmacy','Transferred from Main Store','Source: MED-00078 - Piroxicam',2,NULL,'2026-03-05 14:53:45',0,0,5.00,3500.00,'2026-03-05 14:53:45','2026-03-05 14:53:45'),(77,'TXN-20260305-0077',86,79,'transfer_in',10,0,10,'inventory_item',79,'main_store','pharmacy','Transferred from Main Store','Source: MED-00079 - Paracetamol',2,NULL,'2026-03-05 14:57:35',0,0,50.00,500.00,'2026-03-05 14:57:35','2026-03-05 14:57:35'),(78,'TXN-20260305-0078',87,80,'transfer_in',20,0,20,'inventory_item',80,'main_store','pharmacy','Transferred from Main Store','Source: MED-00080 - Paracetamol',2,NULL,'2026-03-05 14:58:23',0,0,50.00,1000.00,'2026-03-05 14:58:23','2026-03-05 14:58:23'),(79,'TXN-20260305-0079',88,81,'transfer_in',1200,0,1200,'inventory_item',81,'main_store','pharmacy','Transferred from Main Store','Source: MED-00081 - Cetrizine',2,NULL,'2026-03-05 15:02:01',0,0,5.00,6000.00,'2026-03-05 15:02:01','2026-03-05 15:02:01'),(80,'TXN-20260305-0080',89,82,'transfer_in',500,0,500,'inventory_item',82,'main_store','pharmacy','Transferred from Main Store','Source: MED-00082 - Piriton',2,NULL,'2026-03-05 15:03:29',0,0,5.00,2500.00,'2026-03-05 15:03:29','2026-03-05 15:03:29'),(81,'TXN-20260305-0081',90,83,'transfer_in',600,0,600,'inventory_item',83,'main_store','pharmacy','Transferred from Main Store','Source: MED-00083 - Paracetamol',2,NULL,'2026-03-05 15:05:16',0,0,5.00,3000.00,'2026-03-05 15:05:16','2026-03-05 15:05:16'),(82,'TXN-20260305-0082',91,84,'transfer_in',600,0,600,'inventory_item',84,'main_store','pharmacy','Transferred from Main Store','Source: MED-00084 - Ibuprofen',2,NULL,'2026-03-05 15:07:27',0,0,5.00,3000.00,'2026-03-05 15:07:27','2026-03-05 15:07:27'),(83,'TXN-20260305-0083',92,85,'transfer_in',700,0,700,'inventory_item',85,'main_store','pharmacy','Transferred from Main Store','Source: MED-00085 - Ibuprofen',2,NULL,'2026-03-05 15:08:38',0,0,5.00,3500.00,'2026-03-05 15:08:38','2026-03-05 15:08:38'),(84,'TXN-20260305-0084',93,86,'transfer_in',40,0,40,'inventory_item',86,'main_store','pharmacy','Transferred from Main Store','Source: MED-00086 - Metronidazole',2,NULL,'2026-03-05 15:12:14',0,0,100.00,4000.00,'2026-03-05 15:12:14','2026-03-05 15:12:14'),(85,'TXN-20260305-0085',94,87,'transfer_in',11,0,11,'inventory_item',87,'main_store','pharmacy','Transferred from Main Store','Source: MED-00087 - Metronidazole',2,NULL,'2026-03-05 15:14:22',0,0,150.00,1650.00,'2026-03-05 15:14:22','2026-03-05 15:14:22'),(86,'TXN-20260305-0086',95,89,'transfer_in',55,0,55,'inventory_item',89,'main_store','pharmacy','Transferred from Main Store','Source: MED-00089 - Oral Rehydration Salts (ORS)',2,NULL,'2026-03-05 15:19:46',0,0,30.00,1650.00,'2026-03-05 15:19:46','2026-03-05 15:19:46'),(87,'TXN-20260305-0087',96,90,'transfer_in',22,0,22,'inventory_item',90,'main_store','pharmacy','Transferred from Main Store','Source: MED-00090 - Azithromycin',2,NULL,'2026-03-05 15:22:14',0,0,50.00,1100.00,'2026-03-05 15:22:14','2026-03-05 15:22:14'),(88,'TXN-20260305-0088',97,91,'transfer_in',6,0,6,'inventory_item',91,'main_store','pharmacy','Transferred from Main Store','Source: MED-00091 - Amoxiclav',2,NULL,'2026-03-05 15:25:07',0,0,100.00,600.00,'2026-03-05 15:25:07','2026-03-05 15:25:07'),(89,'TXN-20260305-0089',98,92,'transfer_in',11,0,11,'inventory_item',92,'main_store','pharmacy','Transferred from Main Store','Source: MED-00092 - Ibuprofen',2,NULL,'2026-03-05 15:28:27',0,0,100.00,1100.00,'2026-03-05 15:28:27','2026-03-05 15:28:27'),(90,'TXN-20260305-0090',99,93,'transfer_in',15,0,15,'inventory_item',93,'main_store','pharmacy','Transferred from Main Store','Source: MED-00093 - Co-Trimoxazole',2,NULL,'2026-03-05 15:30:39',0,0,100.00,1500.00,'2026-03-05 15:30:39','2026-03-05 15:30:39'),(91,'TXN-20260305-0091',100,94,'transfer_in',15,0,15,'inventory_item',94,'main_store','pharmacy','Transferred from Main Store','Source: MED-00094 - Piriton',2,NULL,'2026-03-05 15:32:05',0,0,100.00,1500.00,'2026-03-05 15:32:05','2026-03-05 15:32:05'),(92,'TXN-20260305-0092',101,95,'transfer_in',11,0,11,'inventory_item',95,'main_store','pharmacy','Transferred from Main Store','Source: MED-00095 - Paracetamol',2,NULL,'2026-03-05 15:34:00',0,0,100.00,1100.00,'2026-03-05 15:34:00','2026-03-05 15:34:00'),(93,'TXN-20260305-0093',102,96,'transfer_in',15,0,15,'inventory_item',96,'main_store','pharmacy','Transferred from Main Store','Source: MED-00096 - Sulbutamol',2,NULL,'2026-03-05 15:36:28',0,0,50.00,750.00,'2026-03-05 15:36:28','2026-03-05 15:36:28'),(94,'TXN-20260305-0094',103,97,'transfer_in',18,0,18,'inventory_item',97,'main_store','pharmacy','Transferred from Main Store','Source: MED-00097 - Promethazine Hydrochloride',2,NULL,'2026-03-05 15:41:33',0,0,50.00,900.00,'2026-03-05 15:41:33','2026-03-05 15:41:33'),(95,'TXN-20260305-0095',104,98,'transfer_in',9,0,9,'inventory_item',98,'main_store','pharmacy','Transferred from Main Store','Source: MED-00098 - Cetrizine',2,NULL,'2026-03-05 15:42:57',0,0,50.00,450.00,'2026-03-05 15:42:57','2026-03-05 15:42:57'),(96,'TXN-20260305-0096',105,36,'transfer_in',50,0,50,'inventory_item',36,'main_store','pharmacy','Transferred from Main Store','Source: MED-00036 - Dexamethasone',2,NULL,'2026-03-05 15:44:19',0,0,200.00,10000.00,'2026-03-05 15:44:19','2026-03-05 15:44:19'),(97,'TXN-20260306-0001',108,65,'transfer_in',200,0,200,'inventory_item',65,'main_store','pharmacy','Transferred from Main Store','Source: MED-00065 - Amoxicillin DT',2,NULL,'2026-03-06 11:09:29',0,0,5.00,1000.00,'2026-03-06 11:09:29','2026-03-06 11:09:29'),(98,'TXN-20260306-0002',109,99,'transfer_in',56,0,56,'inventory_item',99,'main_store','pharmacy','Transferred from Main Store','Source: MED-00099 - Glysit (Dapagliflozin)',2,NULL,'2026-03-06 11:20:09',0,0,100.00,5600.00,'2026-03-06 11:20:09','2026-03-06 11:20:09'),(99,'TXN-20260306-0003',110,68,'transfer_in',600,0,600,'inventory_item',68,'main_store','pharmacy','Transferred from Main Store','Source: MED-00068 - Co-Trimoxazole',2,NULL,'2026-03-06 11:21:14',0,0,5.00,3000.00,'2026-03-06 11:21:14','2026-03-06 11:21:14'),(100,'TXN-20260306-0004',111,100,'transfer_in',80,0,80,'inventory_item',100,'main_store','pharmacy','Transferred from Main Store','Source: MED-00100 - Nelgra (Viagra gen)',2,NULL,'2026-03-06 11:34:07',0,0,20.00,1600.00,'2026-03-06 11:34:07','2026-03-06 11:34:07'),(101,'TXN-20260306-0005',112,101,'transfer_in',1900,0,1900,'inventory_item',101,'main_store','pharmacy','Transferred from Main Store','Source: MED-00101 - Prednisolone',2,NULL,'2026-03-06 11:37:20',0,0,5.00,9500.00,'2026-03-06 11:37:20','2026-03-06 11:37:20'),(102,'TXN-20260306-0006',113,33,'transfer_in',30,0,30,'inventory_item',33,'main_store','pharmacy','Transferred from Main Store','Source: MED-00033 - Normal Saline',2,NULL,'2026-03-06 11:38:58',0,0,500.00,15000.00,'2026-03-06 11:38:58','2026-03-06 11:38:58'),(103,'TXN-20260306-0007',114,102,'transfer_in',15,0,15,'inventory_item',102,'main_store','pharmacy','Transferred from Main Store','Source: MED-00102 - Calamine Lotion',2,NULL,'2026-03-06 11:41:11',0,0,100.00,1500.00,'2026-03-06 11:41:11','2026-03-06 11:41:11'),(104,'TXN-20260306-0008',90,83,'dispensation',-1,600,599,'prescription',7,NULL,NULL,NULL,'Dispensed to patient #6',10,NULL,'2026-03-06 12:12:53',0,0,NULL,NULL,'2026-03-06 12:12:53','2026-03-06 12:12:53'),(105,'TXN-20260306-0009',90,83,'dispensation',-1,599,598,'prescription',9,NULL,NULL,NULL,'Dispensed to patient #7',2,NULL,'2026-03-06 12:57:56',0,0,NULL,NULL,'2026-03-06 12:57:56','2026-03-06 12:57:56');
/*!40000 ALTER TABLE `pharmacy_inventory_transactions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pharmacy_orders`
--

DROP TABLE IF EXISTS `pharmacy_orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pharmacy_orders` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `prescription_id` bigint unsigned NOT NULL,
  `patient_id` bigint unsigned NOT NULL,
  `doctor_id` bigint unsigned DEFAULT NULL,
  `pharmacist_id` bigint unsigned DEFAULT NULL,
  `status` enum('pending','dispensed') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `notes` text COLLATE utf8mb4_unicode_ci,
  `dispensed_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `pharmacy_orders_prescription_id_foreign` (`prescription_id`),
  KEY `pharmacy_orders_patient_id_foreign` (`patient_id`),
  KEY `pharmacy_orders_doctor_id_foreign` (`doctor_id`),
  KEY `pharmacy_orders_pharmacist_id_foreign` (`pharmacist_id`),
  CONSTRAINT `pharmacy_orders_doctor_id_foreign` FOREIGN KEY (`doctor_id`) REFERENCES `doctors` (`id`) ON DELETE SET NULL,
  CONSTRAINT `pharmacy_orders_patient_id_foreign` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`id`) ON DELETE CASCADE,
  CONSTRAINT `pharmacy_orders_pharmacist_id_foreign` FOREIGN KEY (`pharmacist_id`) REFERENCES `staff` (`id`) ON DELETE SET NULL,
  CONSTRAINT `pharmacy_orders_prescription_id_foreign` FOREIGN KEY (`prescription_id`) REFERENCES `prescriptions` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pharmacy_orders`
--

LOCK TABLES `pharmacy_orders` WRITE;
/*!40000 ALTER TABLE `pharmacy_orders` DISABLE KEYS */;
INSERT INTO `pharmacy_orders` VALUES (1,7,6,6,NULL,'pending',NULL,NULL,'2026-03-06 12:12:33','2026-03-06 12:12:33'),(2,8,7,4,NULL,'pending',NULL,NULL,'2026-03-06 12:38:23','2026-03-06 12:38:23'),(3,9,7,4,NULL,'pending',NULL,NULL,'2026-03-06 12:57:10','2026-03-06 12:57:10');
/*!40000 ALTER TABLE `pharmacy_orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pharmacy_prescription_items`
--

DROP TABLE IF EXISTS `pharmacy_prescription_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pharmacy_prescription_items` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `prescription_id` bigint unsigned NOT NULL,
  `drug_id` bigint unsigned NOT NULL,
  `quantity_prescribed` int NOT NULL,
  `quantity_dispensed` int NOT NULL DEFAULT '0',
  `quantity_remaining` int GENERATED ALWAYS AS ((`quantity_prescribed` - `quantity_dispensed`)) VIRTUAL,
  `dosage` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'e.g., 500mg, 2 tablets',
  `frequency` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'e.g., 3 times daily, Every 8 hours',
  `route` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'oral, IV, topical, etc.',
  `duration_days` int DEFAULT NULL,
  `duration_text` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '7 days, Until symptoms resolve',
  `special_instructions` text COLLATE utf8mb4_unicode_ci COMMENT 'Take with food, Avoid alcohol',
  `administration_instructions` text COLLATE utf8mb4_unicode_ci,
  `substitute_allowed` tinyint(1) NOT NULL DEFAULT '0',
  `alternative_drugs` json DEFAULT NULL COMMENT '[{"drug_id": 123, "reason": "generic"}]',
  `status` enum('pending','partially_dispensed','fully_dispensed','cancelled','substituted') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `unit_price` decimal(10,2) DEFAULT NULL,
  `line_total` decimal(10,2) DEFAULT NULL,
  `first_dispensed_at` timestamp NULL DEFAULT NULL,
  `fully_dispensed_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `pharmacy_prescription_items_prescription_id_status_index` (`prescription_id`,`status`),
  KEY `pharmacy_prescription_items_drug_id_index` (`drug_id`),
  KEY `pharmacy_prescription_items_status_index` (`status`),
  CONSTRAINT `pharmacy_prescription_items_drug_id_foreign` FOREIGN KEY (`drug_id`) REFERENCES `pharmacy_drugs` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `pharmacy_prescription_items_prescription_id_foreign` FOREIGN KEY (`prescription_id`) REFERENCES `pharmacy_prescriptions` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pharmacy_prescription_items`
--

LOCK TABLES `pharmacy_prescription_items` WRITE;
/*!40000 ALTER TABLE `pharmacy_prescription_items` DISABLE KEYS */;
/*!40000 ALTER TABLE `pharmacy_prescription_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pharmacy_prescriptions`
--

DROP TABLE IF EXISTS `pharmacy_prescriptions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pharmacy_prescriptions` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `prescription_number` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'RX-20251206-0001',
  `patient_id` bigint unsigned NOT NULL,
  `treatment_id` bigint unsigned DEFAULT NULL,
  `doctor_id` bigint unsigned DEFAULT NULL,
  `prescribing_date` timestamp NOT NULL,
  `diagnosis` text COLLATE utf8mb4_unicode_ci,
  `prescription_type` enum('inpatient','outpatient','emergency') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'outpatient',
  `priority` enum('routine','urgent','stat') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'routine',
  `valid_until` date DEFAULT NULL COMMENT 'Prescription validity',
  `status` enum('active','partially_dispensed','fully_dispensed','cancelled','expired') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `special_instructions` text COLLATE utf8mb4_unicode_ci,
  `allergies_noted` text COLLATE utf8mb4_unicode_ci COMMENT 'Patient allergies at time of prescription',
  `patient_warnings` text COLLATE utf8mb4_unicode_ci,
  `total_estimated_cost` decimal(10,2) NOT NULL DEFAULT '0.00',
  `total_dispensed_cost` decimal(10,2) NOT NULL DEFAULT '0.00',
  `notes` text COLLATE utf8mb4_unicode_ci,
  `cancelled_at` timestamp NULL DEFAULT NULL,
  `cancelled_by` bigint unsigned DEFAULT NULL,
  `cancellation_reason` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `pharmacy_prescriptions_prescription_number_unique` (`prescription_number`),
  KEY `pharmacy_prescriptions_treatment_id_foreign` (`treatment_id`),
  KEY `pharmacy_prescriptions_doctor_id_foreign` (`doctor_id`),
  KEY `pharmacy_prescriptions_cancelled_by_foreign` (`cancelled_by`),
  KEY `pharmacy_prescriptions_patient_id_status_index` (`patient_id`,`status`),
  KEY `pharmacy_prescriptions_prescribing_date_index` (`prescribing_date`),
  KEY `pharmacy_prescriptions_status_index` (`status`),
  CONSTRAINT `pharmacy_prescriptions_cancelled_by_foreign` FOREIGN KEY (`cancelled_by`) REFERENCES `staff` (`id`) ON DELETE SET NULL,
  CONSTRAINT `pharmacy_prescriptions_doctor_id_foreign` FOREIGN KEY (`doctor_id`) REFERENCES `doctors` (`id`) ON DELETE SET NULL,
  CONSTRAINT `pharmacy_prescriptions_patient_id_foreign` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `pharmacy_prescriptions_treatment_id_foreign` FOREIGN KEY (`treatment_id`) REFERENCES `treatments` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pharmacy_prescriptions`
--

LOCK TABLES `pharmacy_prescriptions` WRITE;
/*!40000 ALTER TABLE `pharmacy_prescriptions` DISABLE KEYS */;
/*!40000 ALTER TABLE `pharmacy_prescriptions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pharmacy_reorder_requests`
--

DROP TABLE IF EXISTS `pharmacy_reorder_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pharmacy_reorder_requests` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `pharmacy_drug_id` bigint unsigned NOT NULL,
  `quantity` int DEFAULT NULL,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `notes` text COLLATE utf8mb4_unicode_ci,
  `requested_by` bigint unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `pharmacy_reorder_requests_pharmacy_drug_id_foreign` (`pharmacy_drug_id`),
  CONSTRAINT `pharmacy_reorder_requests_pharmacy_drug_id_foreign` FOREIGN KEY (`pharmacy_drug_id`) REFERENCES `pharmacy_drugs` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pharmacy_reorder_requests`
--

LOCK TABLES `pharmacy_reorder_requests` WRITE;
/*!40000 ALTER TABLE `pharmacy_reorder_requests` DISABLE KEYS */;
/*!40000 ALTER TABLE `pharmacy_reorder_requests` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pharmacy_stock_alerts`
--

DROP TABLE IF EXISTS `pharmacy_stock_alerts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pharmacy_stock_alerts` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `alert_type` enum('low_stock','expiry_soon','expired','overstock','no_stock','batch_recall','quality_issue') COLLATE utf8mb4_unicode_ci NOT NULL,
  `severity` enum('info','warning','critical') COLLATE utf8mb4_unicode_ci NOT NULL,
  `drug_id` bigint unsigned NOT NULL,
  `batch_id` bigint unsigned DEFAULT NULL,
  `message` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `threshold_value` int DEFAULT NULL COMMENT 'e.g., reorder level',
  `current_value` int DEFAULT NULL COMMENT 'Current stock',
  `expiry_date` date DEFAULT NULL COMMENT 'For expiry alerts',
  `days_to_expiry` int DEFAULT NULL,
  `alert_data` json DEFAULT NULL COMMENT 'Additional context data',
  `recommended_action` text COLLATE utf8mb4_unicode_ci,
  `is_acknowledged` tinyint(1) NOT NULL DEFAULT '0',
  `acknowledged_by` bigint unsigned DEFAULT NULL,
  `acknowledged_at` timestamp NULL DEFAULT NULL,
  `acknowledgment_notes` text COLLATE utf8mb4_unicode_ci,
  `is_resolved` tinyint(1) NOT NULL DEFAULT '0',
  `resolved_at` timestamp NULL DEFAULT NULL,
  `resolved_by` bigint unsigned DEFAULT NULL,
  `resolution_notes` text COLLATE utf8mb4_unicode_ci,
  `auto_dismissed` tinyint(1) NOT NULL DEFAULT '0',
  `dismissed_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `pharmacy_stock_alerts_batch_id_foreign` (`batch_id`),
  KEY `pharmacy_stock_alerts_acknowledged_by_foreign` (`acknowledged_by`),
  KEY `pharmacy_stock_alerts_resolved_by_foreign` (`resolved_by`),
  KEY `pharmacy_stock_alerts_alert_type_severity_index` (`alert_type`,`severity`),
  KEY `pharmacy_stock_alerts_drug_id_is_resolved_index` (`drug_id`,`is_resolved`),
  KEY `pharmacy_stock_alerts_is_acknowledged_is_resolved_index` (`is_acknowledged`,`is_resolved`),
  KEY `pharmacy_stock_alerts_alert_type_index` (`alert_type`),
  KEY `pharmacy_stock_alerts_severity_index` (`severity`),
  KEY `pharmacy_stock_alerts_is_acknowledged_index` (`is_acknowledged`),
  KEY `pharmacy_stock_alerts_is_resolved_index` (`is_resolved`),
  CONSTRAINT `pharmacy_stock_alerts_acknowledged_by_foreign` FOREIGN KEY (`acknowledged_by`) REFERENCES `staff` (`id`) ON DELETE SET NULL,
  CONSTRAINT `pharmacy_stock_alerts_batch_id_foreign` FOREIGN KEY (`batch_id`) REFERENCES `pharmacy_drug_batches` (`id`) ON DELETE CASCADE,
  CONSTRAINT `pharmacy_stock_alerts_drug_id_foreign` FOREIGN KEY (`drug_id`) REFERENCES `pharmacy_drugs` (`id`) ON DELETE CASCADE,
  CONSTRAINT `pharmacy_stock_alerts_resolved_by_foreign` FOREIGN KEY (`resolved_by`) REFERENCES `staff` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pharmacy_stock_alerts`
--

LOCK TABLES `pharmacy_stock_alerts` WRITE;
/*!40000 ALTER TABLE `pharmacy_stock_alerts` DISABLE KEYS */;
/*!40000 ALTER TABLE `pharmacy_stock_alerts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `prescription_items`
--

DROP TABLE IF EXISTS `prescription_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `prescription_items` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `prescription_id` bigint unsigned NOT NULL,
  `inventory_item_id` bigint unsigned DEFAULT NULL,
  `drug_name_text` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Doctor written drug name',
  `dosage_text` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'e.g., 500mg',
  `frequency_text` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'e.g., 3x daily',
  `duration_text` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'e.g., 7 days',
  `instructions_text` text COLLATE utf8mb4_unicode_ci COMMENT 'Special instructions',
  `source` enum('prescribed','manual') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'prescribed',
  `manually_added_by` bigint unsigned DEFAULT NULL,
  `dispensed_from_stock` tinyint(1) NOT NULL DEFAULT '1',
  `quantity` int NOT NULL,
  `unit_price` decimal(10,2) NOT NULL,
  `subtotal` decimal(10,2) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `mapped_drug_id` bigint unsigned DEFAULT NULL,
  `mapped_quantity` int DEFAULT NULL COMMENT 'Pharmacist adjusted quantity',
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `prescription_items_prescription_id_foreign` (`prescription_id`),
  KEY `prescription_items_inventory_item_id_foreign` (`inventory_item_id`),
  KEY `prescription_items_mapped_drug_id_foreign` (`mapped_drug_id`),
  KEY `prescription_items_manually_added_by_foreign` (`manually_added_by`),
  CONSTRAINT `prescription_items_inventory_item_id_foreign` FOREIGN KEY (`inventory_item_id`) REFERENCES `inventory_items` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `prescription_items_manually_added_by_foreign` FOREIGN KEY (`manually_added_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `prescription_items_mapped_drug_id_foreign` FOREIGN KEY (`mapped_drug_id`) REFERENCES `pharmacy_drugs` (`id`),
  CONSTRAINT `prescription_items_prescription_id_foreign` FOREIGN KEY (`prescription_id`) REFERENCES `prescriptions` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `prescription_items`
--

LOCK TABLES `prescription_items` WRITE;
/*!40000 ALTER TABLE `prescription_items` DISABLE KEYS */;
INSERT INTO `prescription_items` VALUES (6,6,NULL,'Iv Paracetamol','injection - 1gram ',NULL,NULL,NULL,'manual',NULL,1,1,300.00,300.00,'2026-03-06 11:53:09','2026-03-06 11:53:09',49,1,NULL),(7,7,NULL,'Paracetamol 500mg (tablet)','500mg','STAT (Immediately)','1day',NULL,'prescribed',NULL,1,1,5.00,5.00,'2026-03-06 12:12:33','2026-03-06 12:12:53',83,1,NULL),(8,8,NULL,'Normal Saline 500ml (injection)','54','OD (Once daily)','3','efg','prescribed',NULL,1,1,0.00,0.00,'2026-03-06 12:38:23','2026-03-06 12:58:06',NULL,NULL,NULL),(9,9,NULL,'Paracetamol 500mg (tablet)','500 mg','TID (Three times daily)','3/7',NULL,'prescribed',NULL,1,1,5.00,5.00,'2026-03-06 12:57:10','2026-03-06 12:57:56',83,1,NULL);
/*!40000 ALTER TABLE `prescription_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `prescriptions`
--

DROP TABLE IF EXISTS `prescriptions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `prescriptions` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `patient_id` bigint unsigned NOT NULL,
  `treatment_id` bigint unsigned DEFAULT NULL,
  `doctor_id` bigint unsigned DEFAULT NULL,
  `total_amount` decimal(10,2) NOT NULL DEFAULT '0.00',
  `status` enum('pending','billed','paid') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `pharmacy_status` enum('draft','sent_to_pharmacy','under_review','ready_to_dispense','dispensed','cancelled') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'draft',
  `notes` text COLLATE utf8mb4_unicode_ci,
  `is_manual_dispensation` tinyint(1) NOT NULL DEFAULT '0',
  `registered_on_the_fly` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `reviewed_by_pharmacist_id` bigint unsigned DEFAULT NULL,
  `pharmacist_notes` text COLLATE utf8mb4_unicode_ci,
  `sent_to_pharmacy_at` timestamp NULL DEFAULT NULL,
  `dispensed_at` timestamp NULL DEFAULT NULL,
  `dispensed_by_staff_id` bigint unsigned DEFAULT NULL,
  `dispensing_notes` text COLLATE utf8mb4_unicode_ci,
  `reviewed_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `prescriptions_doctor_id_foreign` (`doctor_id`),
  KEY `prescriptions_reviewed_by_pharmacist_id_foreign` (`reviewed_by_pharmacist_id`),
  KEY `prescriptions_dispensed_by_staff_id_foreign` (`dispensed_by_staff_id`),
  KEY `idx_prescriptions_patient_id` (`patient_id`),
  KEY `idx_prescriptions_treatment_id` (`treatment_id`),
  KEY `idx_prescriptions_pharmacy_status` (`pharmacy_status`),
  KEY `idx_prescriptions_created_at` (`created_at`),
  CONSTRAINT `prescriptions_dispensed_by_staff_id_foreign` FOREIGN KEY (`dispensed_by_staff_id`) REFERENCES `staff` (`id`) ON DELETE SET NULL,
  CONSTRAINT `prescriptions_doctor_id_foreign` FOREIGN KEY (`doctor_id`) REFERENCES `doctors` (`id`) ON DELETE SET NULL,
  CONSTRAINT `prescriptions_patient_id_foreign` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`id`) ON DELETE CASCADE,
  CONSTRAINT `prescriptions_reviewed_by_pharmacist_id_foreign` FOREIGN KEY (`reviewed_by_pharmacist_id`) REFERENCES `staff` (`id`),
  CONSTRAINT `prescriptions_treatment_id_foreign` FOREIGN KEY (`treatment_id`) REFERENCES `treatments` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `prescriptions`
--

LOCK TABLES `prescriptions` WRITE;
/*!40000 ALTER TABLE `prescriptions` DISABLE KEYS */;
INSERT INTO `prescriptions` VALUES (6,4,NULL,NULL,300.00,'pending','dispensed','Manual dispensation',1,0,'2026-03-06 11:53:09','2026-03-06 11:53:09',NULL,NULL,NULL,'2026-03-06 11:53:09',NULL,NULL,NULL,NULL),(7,6,5,6,0.00,'pending','dispensed',NULL,0,0,'2026-03-06 12:12:33','2026-03-06 12:12:53',10,NULL,'2026-03-06 12:12:33','2026-03-06 12:12:53',10,NULL,'2026-03-06 12:12:53',NULL),(8,7,6,4,0.00,'pending','sent_to_pharmacy',NULL,0,0,'2026-03-06 12:38:23','2026-03-06 12:38:23',NULL,NULL,'2026-03-06 12:38:23',NULL,NULL,NULL,NULL,NULL),(9,7,6,4,0.00,'pending','dispensed',NULL,0,0,'2026-03-06 12:57:09','2026-03-06 12:57:56',2,NULL,'2026-03-06 12:57:09','2026-03-06 12:57:56',2,NULL,'2026-03-06 12:57:56',NULL);
/*!40000 ALTER TABLE `prescriptions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `queue`
--

DROP TABLE IF EXISTS `queue`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `queue` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `patient_id` bigint unsigned NOT NULL,
  `added_by` bigint unsigned DEFAULT NULL,
  `status` enum('waiting','in_progress','completed','removed') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'waiting',
  `priority` int NOT NULL DEFAULT '0',
  `notes` text COLLATE utf8mb4_unicode_ci,
  `attended_at` timestamp NULL DEFAULT NULL,
  `attended_by` bigint unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `queue_added_by_foreign` (`added_by`),
  KEY `queue_attended_by_foreign` (`attended_by`),
  KEY `queue_status_priority_created_at_index` (`status`,`priority`,`created_at`),
  KEY `queue_patient_id_index` (`patient_id`),
  KEY `idx_queue_patient_id` (`patient_id`),
  KEY `idx_queue_status` (`status`),
  KEY `idx_queue_created_at` (`created_at`),
  CONSTRAINT `queue_added_by_foreign` FOREIGN KEY (`added_by`) REFERENCES `staff` (`id`) ON DELETE SET NULL,
  CONSTRAINT `queue_attended_by_foreign` FOREIGN KEY (`attended_by`) REFERENCES `staff` (`id`) ON DELETE SET NULL,
  CONSTRAINT `queue_patient_id_foreign` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `queue`
--

LOCK TABLES `queue` WRITE;
/*!40000 ALTER TABLE `queue` DISABLE KEYS */;
INSERT INTO `queue` VALUES (1,3,2,'completed',0,NULL,'2026-03-05 04:58:24',2,'2026-03-05 04:58:15','2026-03-05 04:58:24'),(2,3,10,'completed',0,NULL,'2026-03-05 07:13:38',10,'2026-03-05 07:13:26','2026-03-05 07:13:38'),(3,4,10,'completed',0,NULL,'2026-03-05 15:49:45',10,'2026-03-05 15:49:35','2026-03-05 15:49:45'),(4,4,2,'removed',0,NULL,NULL,NULL,'2026-03-05 17:47:43','2026-03-05 17:48:16'),(5,6,10,'completed',0,NULL,'2026-03-06 12:02:19',10,'2026-03-06 12:02:06','2026-03-06 12:02:19');
/*!40000 ALTER TABLE `queue` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sessions`
--

DROP TABLE IF EXISTS `sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sessions` (
  `id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` bigint unsigned DEFAULT NULL,
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` text COLLATE utf8mb4_unicode_ci,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_activity` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `sessions_user_id_index` (`user_id`),
  KEY `sessions_last_activity_index` (`last_activity`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sessions`
--

LOCK TABLES `sessions` WRITE;
/*!40000 ALTER TABLE `sessions` DISABLE KEYS */;
INSERT INTO `sessions` VALUES ('yhW8QJVEwqhVBD6c1qR2iLLcoZAAoQ0SNQIAlO01',NULL,'100.64.0.2','WhatsApp/2.2606.102 W','YTozOntzOjY6Il90b2tlbiI7czo0MDoiendESnpyaXRKTXdvc0RiRUsxUmlJQ01BMTUwNlFFcnJHaXRKTDMzNiI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NDg6Imh0dHA6Ly9uYWl0aXJpamFtYm9obXMtcHJvZHVjdGlvbi51cC5yYWlsd2F5LmFwcCI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=',1772609693);
/*!40000 ALTER TABLE `sessions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `settings`
--

DROP TABLE IF EXISTS `settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `settings` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `value` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` enum('string','number','boolean','json') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'string',
  `description` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `settings_key_unique` (`key`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `settings`
--

LOCK TABLES `settings` WRITE;
/*!40000 ALTER TABLE `settings` DISABLE KEYS */;
INSERT INTO `settings` VALUES (1,'consultation_fee','300','number','Default consultation fee for patient visits','2026-03-04 07:29:55','2026-03-04 18:02:16');
/*!40000 ALTER TABLE `settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `staff`
--

DROP TABLE IF EXISTS `staff`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `staff` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `ch_id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `first_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `role` enum('admin','doctor','reception','pharmacist','labtech','facility_clerk') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'doctor',
  `password` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `staff_ch_id_unique` (`ch_id`),
  UNIQUE KEY `staff_email_unique` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `staff`
--

LOCK TABLES `staff` WRITE;
/*!40000 ALTER TABLE `staff` DISABLE KEYS */;
INSERT INTO `staff` VALUES (1,'CH-96294','System','Admin','admin@hospital.com','0700000000','admin','$2y$12$z4mDd.UCWMrAfdjVM7wTJ.6DWAxCWypzIJbzZPWtHq6MrHYf8KZkS','2026-03-04 07:29:55','2026-03-04 07:29:55'),(2,'CH-36021','system','admin','admin@naitirijambo.com','null','admin','$2y$12$X6tUl.A6fJm/.Gq5aRuOheuOUS5EbfE1ffah55WIoT3NwA4WlVYCq','2026-03-04 08:02:47','2026-03-04 08:09:47'),(3,'CH-90819','Moses','Simiyu','moses@naitirijambo.com','0757144358','doctor','$2y$12$JsQtrkqig/zZTI.p5.58re5E5yiuZ6hh5eksJjhmfvmEslrgRuvde','2026-03-04 18:11:07','2026-03-04 18:11:07'),(4,'CH-71157','Vivian','Masika','vivian@naitirijambo.com','0704 002831','reception','$2y$12$JOaIf30HAzGMiGGTq2ksZOOlfvIzvJrWxRGYIiq6yNXs5S2pnpfLG','2026-03-04 18:17:40','2026-03-05 05:05:56'),(5,'CH-80069','Brevin','Wanjala','brevin@naitirijambo.com','0790679873','doctor','$2y$12$5CbR7Szx0/JsdbA.oEe3UucFjH/LZxVPgDphnIJ/YmWkRBDTMm0fS','2026-03-05 05:09:41','2026-03-06 12:57:27'),(6,'CH-56416','Benard','Ngichabe','benard@naitirijambo.com','0726427775','doctor','$2y$12$Or9UhV5LOQH.EPf7r1D84ObwwxTk2XrzkeGhq.a5JVMyNDyoZIxlC','2026-03-05 05:10:52','2026-03-05 05:10:52'),(7,'CH-32280','Catherine','Wanyama','cate@naitirijambo.com','0715790048','pharmacist','$2y$12$gjI1NFW7RMIca.OmiAtNVuUwVsnGFQQTYGUvw5Kukz8V7g6BBhgxW','2026-03-05 05:12:25','2026-03-05 05:12:25'),(8,'CH-25940','Mary','Mwangi','mary@naitirijambo.com','0710121020','pharmacist','$2y$12$3gaCA.LU.dP23/svlbm/ROgBs57y3j0nbvlyyCcS/Z/Zon0vbpau.','2026-03-05 05:13:38','2026-03-05 05:13:38'),(9,'CH-08874','Shillah','Nambo','nambo@naitirijambo.com','0792848652','pharmacist','$2y$12$dZpnvsk/wy7s1i8XnK0zgeQ9KpDXxHc1QkJZ5LQ.g53i2CakTMlRG','2026-03-05 05:14:45','2026-03-05 05:14:45'),(10,'CH-73449','SAMMY','SONGWA','samy@naitirijambo.com','0707379815','admin','$2y$12$zJUpaSjP2MQoSqI4.xEuEu5NzT28yyIPbM28u6AdrxkIuAgF0jN.e','2026-03-05 07:11:24','2026-03-05 07:11:24');
/*!40000 ALTER TABLE `staff` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `staff_documents`
--

DROP TABLE IF EXISTS `staff_documents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `staff_documents` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `staff_id` bigint unsigned NOT NULL,
  `label` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_path` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `staff_documents_staff_id_foreign` (`staff_id`),
  CONSTRAINT `staff_documents_staff_id_foreign` FOREIGN KEY (`staff_id`) REFERENCES `staff` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `staff_documents`
--

LOCK TABLES `staff_documents` WRITE;
/*!40000 ALTER TABLE `staff_documents` DISABLE KEYS */;
/*!40000 ALTER TABLE `staff_documents` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `suppliers`
--

DROP TABLE IF EXISTS `suppliers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `suppliers` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `contact_person` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `address` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `category` enum('pharmaceutical','equipment','general') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'general',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `suppliers`
--

LOCK TABLES `suppliers` WRITE;
/*!40000 ALTER TABLE `suppliers` DISABLE KEYS */;
INSERT INTO `suppliers` VALUES (1,'KENTONS LIMITED','KENTONS','0726-427-775','sales@kentons.net','Oginga Odinga Road, Kisumu, Kenya','pharmaceutical','2026-03-04 07:29:55','2026-03-05 06:21:32'),(2,'PHILMED LIMITED','Margaret Njeri','0714285993','info@philmedltd.co.ke','P.O Box 36728 00200 Nairobi','pharmaceutical','2026-03-05 06:24:09','2026-03-05 06:24:09'),(3,'RAM CHEMISTS LIMITED','RAM','0700000000',NULL,'KITALE','pharmaceutical','2026-03-05 06:26:08','2026-03-05 06:26:08'),(4,'NAMUKHE MEDICAL SUPPLIES LIMITED','NMSL','0727270677',NULL,'Laini Moja, Africana Building next to Kitale Woolshop','pharmaceutical','2026-03-05 06:27:59','2026-03-05 06:27:59');
/*!40000 ALTER TABLE `suppliers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `surveillance_cases`
--

DROP TABLE IF EXISTS `surveillance_cases`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `surveillance_cases` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `treatment_id` bigint unsigned NOT NULL,
  `patient_id` bigint unsigned NOT NULL,
  `disease_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `disease_code` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_priority_disease` tinyint(1) NOT NULL DEFAULT '0',
  `is_immediately_notifiable` tinyint(1) NOT NULL DEFAULT '0',
  `suspected_outbreak` tinyint(1) NOT NULL DEFAULT '0',
  `onset_date` date DEFAULT NULL,
  `travel_exposure_notes` text COLLATE utf8mb4_unicode_ci,
  `case_status` enum('suspected','probable','confirmed') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'suspected',
  `outcome` enum('alive','dead','referred','unknown') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'alive',
  `lab_confirmed` tinyint(1) NOT NULL DEFAULT '0',
  `lab_confirmation_date` date DEFAULT NULL,
  `notified_to_moh` tinyint(1) NOT NULL DEFAULT '0',
  `notification_datetime` datetime DEFAULT NULL,
  `created_by` bigint unsigned NOT NULL,
  `updated_by` bigint unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `surveillance_cases_treatment_id_foreign` (`treatment_id`),
  KEY `surveillance_cases_patient_id_foreign` (`patient_id`),
  KEY `surveillance_cases_created_by_foreign` (`created_by`),
  KEY `surveillance_cases_updated_by_foreign` (`updated_by`),
  KEY `surveillance_cases_disease_name_index` (`disease_name`),
  KEY `surveillance_cases_onset_date_index` (`onset_date`),
  KEY `surveillance_cases_is_immediately_notifiable_index` (`is_immediately_notifiable`),
  CONSTRAINT `surveillance_cases_created_by_foreign` FOREIGN KEY (`created_by`) REFERENCES `staff` (`id`) ON DELETE CASCADE,
  CONSTRAINT `surveillance_cases_patient_id_foreign` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`id`) ON DELETE CASCADE,
  CONSTRAINT `surveillance_cases_treatment_id_foreign` FOREIGN KEY (`treatment_id`) REFERENCES `treatments` (`id`) ON DELETE CASCADE,
  CONSTRAINT `surveillance_cases_updated_by_foreign` FOREIGN KEY (`updated_by`) REFERENCES `staff` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `surveillance_cases`
--

LOCK TABLES `surveillance_cases` WRITE;
/*!40000 ALTER TABLE `surveillance_cases` DISABLE KEYS */;
/*!40000 ALTER TABLE `surveillance_cases` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `treatments`
--

DROP TABLE IF EXISTS `treatments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `treatments` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `patient_id` bigint unsigned NOT NULL,
  `visit_type` enum('new','revisit') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `encounter_type` enum('OPD','Emergency','Inpatient','MCH','Immunisation','Lab Only','Pharmacy Only','Follow-up') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `department` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `service_category` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `service_subcategory` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `doctor_id` bigint unsigned DEFAULT NULL,
  `bill_id` bigint unsigned DEFAULT NULL,
  `visit_date` date NOT NULL,
  `treatment_type` enum('new','revisit') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'new' COMMENT 'Type of visit: new (first of day) or revisit (same-day return)',
  `referral_status` enum('self','referred_in','return_visit','follow_up') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `referred_from` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `payment_type` enum('Cash','Mobile Money','Bank Transfer','Insurance','Other') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `diagnosis` text COLLATE utf8mb4_unicode_ci,
  `diagnosis_category` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `diagnosis_subcategory` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `treatment_category` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `treatment_subcategory` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `diagnosis_status` enum('pending','confirmed') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `status` enum('active','awaiting_billing','billed','completed') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `disposition` enum('treated_sent_home','admitted','referred_out','transferred','died','absconded','pending') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `referred_to_facility` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `referral_reason` text COLLATE utf8mb4_unicode_ci,
  `death_datetime` datetime DEFAULT NULL,
  `cause_of_death` text COLLATE utf8mb4_unicode_ci,
  `maternal_death` tinyint(1) NOT NULL DEFAULT '0',
  `neonatal_death` tinyint(1) NOT NULL DEFAULT '0',
  `created_by` bigint unsigned DEFAULT NULL,
  `updated_by` bigint unsigned DEFAULT NULL,
  `treatment_notes` text COLLATE utf8mb4_unicode_ci,
  `chief_complaint` text COLLATE utf8mb4_unicode_ci,
  `premedication` text COLLATE utf8mb4_unicode_ci,
  `past_medical_history` text COLLATE utf8mb4_unicode_ci,
  `systemic_review` text COLLATE utf8mb4_unicode_ci,
  `impression` text COLLATE utf8mb4_unicode_ci,
  `attending_doctor` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `treatments_created_by_foreign` (`created_by`),
  KEY `treatments_updated_by_foreign` (`updated_by`),
  KEY `treatments_visit_type_index` (`visit_type`),
  KEY `treatments_encounter_type_index` (`encounter_type`),
  KEY `treatments_disposition_index` (`disposition`),
  KEY `treatments_visit_date_index` (`visit_date`),
  KEY `idx_treatments_patient_id` (`patient_id`),
  KEY `idx_treatments_doctor_id` (`doctor_id`),
  KEY `idx_treatments_visit_date` (`visit_date`),
  KEY `idx_treatments_status` (`status`),
  KEY `idx_treatments_created_at` (`created_at`),
  KEY `treatments_patient_id_visit_date_treatment_type_index` (`patient_id`,`visit_date`,`treatment_type`),
  KEY `treatments_bill_id_index` (`bill_id`),
  CONSTRAINT `treatments_bill_id_foreign` FOREIGN KEY (`bill_id`) REFERENCES `bills` (`id`) ON DELETE SET NULL,
  CONSTRAINT `treatments_created_by_foreign` FOREIGN KEY (`created_by`) REFERENCES `staff` (`id`) ON DELETE SET NULL,
  CONSTRAINT `treatments_doctor_id_foreign` FOREIGN KEY (`doctor_id`) REFERENCES `doctors` (`id`) ON DELETE SET NULL,
  CONSTRAINT `treatments_patient_id_foreign` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`id`) ON DELETE CASCADE,
  CONSTRAINT `treatments_updated_by_foreign` FOREIGN KEY (`updated_by`) REFERENCES `staff` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `treatments`
--

LOCK TABLES `treatments` WRITE;
/*!40000 ALTER TABLE `treatments` DISABLE KEYS */;
INSERT INTO `treatments` VALUES (1,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-02-18','new',NULL,NULL,NULL,'Common Cold',NULL,NULL,NULL,NULL,'pending','active',NULL,NULL,NULL,NULL,NULL,0,0,NULL,NULL,'Prescribed rest and hydration.',NULL,NULL,NULL,NULL,NULL,'Dr. Paul','2026-03-04 07:29:55','2026-03-04 07:29:55'),(2,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-02-28','new',NULL,NULL,NULL,'Fever',NULL,NULL,NULL,NULL,'pending','active',NULL,NULL,NULL,NULL,NULL,0,0,NULL,NULL,'Advised monitoring temperature.',NULL,NULL,NULL,NULL,NULL,'Dr. Paul','2026-03-04 07:29:55','2026-03-04 07:29:55'),(3,2,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-02-21','new',NULL,NULL,NULL,'Common Cold',NULL,NULL,NULL,NULL,'pending','active',NULL,NULL,NULL,NULL,NULL,0,0,NULL,NULL,'Prescribed rest and hydration.',NULL,NULL,NULL,NULL,NULL,'Dr. Sarah','2026-03-04 07:29:55','2026-03-04 07:29:55'),(4,2,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-02-27','new',NULL,NULL,NULL,'Fever',NULL,NULL,NULL,NULL,'pending','active',NULL,NULL,NULL,NULL,NULL,0,0,NULL,NULL,'Advised monitoring temperature.',NULL,NULL,NULL,NULL,NULL,'Dr. Sarah','2026-03-04 07:29:55','2026-03-04 07:29:55'),(5,6,NULL,NULL,NULL,NULL,NULL,6,3,'2026-03-06','new',NULL,NULL,'Insurance','Malaria','Medical','General Medicine',NULL,NULL,'confirmed','active',NULL,NULL,NULL,NULL,NULL,0,0,10,10,NULL,'Gbm\nHob\nVomiting \nDiarrhea','Pcm\nMtz','Nill','Nill','Malaria','Dr. Benard Ngichabe','2026-03-06 12:03:16','2026-03-06 12:11:43'),(6,7,NULL,NULL,NULL,NULL,NULL,4,5,'2026-03-06','new',NULL,NULL,'Bank Transfer','test diag','Surgical','General Surgery',NULL,NULL,'confirmed','active',NULL,NULL,NULL,NULL,NULL,0,0,NULL,NULL,NULL,'abbc','abbc','abbc','abbc','abbc','Dr. Moses Simiyu','2026-03-06 12:36:17','2026-03-06 12:37:45'),(7,7,NULL,NULL,NULL,NULL,NULL,4,5,'2026-03-06','revisit',NULL,NULL,'Bank Transfer',NULL,NULL,NULL,NULL,NULL,'pending','active',NULL,NULL,NULL,NULL,NULL,0,0,NULL,NULL,NULL,'abbc','abbc','abbc','abbc','abbc','Dr. Moses Simiyu','2026-03-06 12:37:13','2026-03-06 12:37:13');
/*!40000 ALTER TABLE `treatments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `triages`
--

DROP TABLE IF EXISTS `triages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `triages` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `patient_id` bigint unsigned NOT NULL,
  `blood_pressure_systolic` int DEFAULT NULL,
  `blood_pressure_diastolic` int DEFAULT NULL,
  `temperature` decimal(5,2) DEFAULT NULL,
  `pulse_rate` int DEFAULT NULL,
  `respiratory_rate` int DEFAULT NULL,
  `weight` decimal(6,2) DEFAULT NULL,
  `height` decimal(6,2) DEFAULT NULL,
  `oxygen_saturation` int DEFAULT NULL,
  `chief_complaint` text COLLATE utf8mb4_unicode_ci,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `triage_level` enum('non_urgent','urgent','emergency') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `recorded_by` bigint unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `updated_by` bigint unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `triages_recorded_by_foreign` (`recorded_by`),
  KEY `triages_patient_id_index` (`patient_id`),
  KEY `triages_created_at_index` (`created_at`),
  KEY `triages_updated_by_foreign` (`updated_by`),
  CONSTRAINT `triages_patient_id_foreign` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`id`) ON DELETE CASCADE,
  CONSTRAINT `triages_recorded_by_foreign` FOREIGN KEY (`recorded_by`) REFERENCES `staff` (`id`) ON DELETE CASCADE,
  CONSTRAINT `triages_updated_by_foreign` FOREIGN KEY (`updated_by`) REFERENCES `staff` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `triages`
--

LOCK TABLES `triages` WRITE;
/*!40000 ALTER TABLE `triages` DISABLE KEYS */;
INSERT INTO `triages` VALUES (1,3,132,86,37.00,70,18,64.00,NULL,NULL,NULL,NULL,NULL,2,'2026-03-05 04:55:38','2026-03-05 04:55:38',NULL),(2,4,120,70,36.60,70,20,65.00,NULL,NULL,NULL,NULL,NULL,2,'2026-03-05 17:47:26','2026-03-05 17:47:26',NULL);
/*!40000 ALTER TABLE `triages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `remember_token` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `users_email_unique` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-03-06 16:37:43
