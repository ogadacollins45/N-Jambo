CREATE DATABASE  IF NOT EXISTS `hms_db` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `hms_db`;
-- MySQL dump 10.13  Distrib 8.0.44, for Win64 (x86_64)
--
-- Host: caboose.proxy.rlwy.net    Database: hms_db
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
  KEY `appointments_patient_id_foreign` (`patient_id`),
  KEY `appointments_doctor_id_foreign` (`doctor_id`),
  CONSTRAINT `appointments_doctor_id_foreign` FOREIGN KEY (`doctor_id`) REFERENCES `doctors` (`id`) ON DELETE CASCADE,
  CONSTRAINT `appointments_patient_id_foreign` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `appointments`
--

LOCK TABLES `appointments` WRITE;
/*!40000 ALTER TABLE `appointments` DISABLE KEYS */;
INSERT INTO `appointments` VALUES (1,1,2,'2025-11-10 14:00:00','completed','2025-11-06 19:30:36','2025-11-07 08:06:57'),(2,2,2,'2025-11-09 10:00:00','Scheduled','2025-11-06 19:30:36','2025-11-06 19:30:36'),(3,5,3,'2025-11-09 10:06:00','completed','2025-11-07 19:06:31','2025-11-23 14:14:17'),(4,15,4,'2025-11-13 18:21:00','Scheduled','2025-11-12 15:21:37','2025-11-12 15:21:37'),(5,50,3,'2025-11-24 15:55:00','completed','2025-11-23 12:55:08','2025-11-23 12:56:05'),(6,16,6,'2025-12-06 11:17:00','Scheduled','2025-12-04 19:14:01','2025-12-04 19:14:01');
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
  `category` enum('consultation','prescription','lab','service','custom') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'custom',
  `description` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `prescription_id` bigint unsigned DEFAULT NULL,
  `prescription_item_id` bigint unsigned DEFAULT NULL,
  `inventory_item_id` bigint unsigned DEFAULT NULL,
  `quantity` int unsigned NOT NULL DEFAULT '1',
  `amount` decimal(10,2) NOT NULL,
  `subtotal` decimal(10,2) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `bill_items_bill_id_category_index` (`bill_id`,`category`),
  CONSTRAINT `bill_items_bill_id_foreign` FOREIGN KEY (`bill_id`) REFERENCES `bills` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=61 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bill_items`
--

LOCK TABLES `bill_items` WRITE;
/*!40000 ALTER TABLE `bill_items` DISABLE KEYS */;
INSERT INTO `bill_items` VALUES (1,1,'consultation','Consultation Fee',NULL,NULL,NULL,1,3.00,3.00,'2025-11-07 08:05:40','2025-11-07 08:05:40'),(2,2,'consultation','Consultation Fee',NULL,NULL,NULL,1,3.00,3.00,'2025-11-07 08:06:56','2025-11-07 08:06:56'),(3,3,'consultation','Consultation Fee',NULL,NULL,NULL,1,3.00,3.00,'2025-11-07 09:38:06','2025-11-07 09:38:06'),(4,4,'consultation','Consultation Fee',NULL,NULL,NULL,1,3.00,3.00,'2025-11-07 09:48:18','2025-11-07 09:48:18'),(5,4,'prescription','Amox',NULL,NULL,NULL,2,150.00,300.00,'2025-11-07 09:49:34','2025-11-07 09:49:34'),(6,4,'prescription','Bandage Roll',NULL,NULL,NULL,1,1.20,1.20,'2025-11-07 09:49:34','2025-11-07 09:49:34'),(7,4,'prescription','Syringe 5ml',NULL,NULL,NULL,1,0.80,0.80,'2025-11-07 09:49:34','2025-11-07 09:49:34'),(8,5,'consultation','Consultation Fee',NULL,NULL,NULL,1,3.00,3.00,'2025-11-07 10:37:26','2025-11-07 10:37:26'),(9,5,'prescription','Paracetamol',NULL,NULL,NULL,1,2.50,2.50,'2025-11-07 10:37:36','2025-11-07 10:37:36'),(10,6,'consultation','Consultation Fee',NULL,NULL,NULL,1,3.00,3.00,'2025-11-07 10:48:59','2025-11-07 10:48:59'),(11,6,'prescription','Paracetamol',NULL,NULL,NULL,3,2.50,7.50,'2025-11-07 19:04:38','2025-11-07 19:04:38'),(12,7,'consultation','Consultation Fee',NULL,NULL,NULL,1,3.00,3.00,'2025-11-12 10:09:16','2025-11-12 10:09:16'),(13,8,'consultation','Consultation Fee',NULL,NULL,NULL,1,3.00,3.00,'2025-11-12 14:12:26','2025-11-12 14:12:26'),(14,9,'consultation','Consultation Fee',NULL,NULL,NULL,1,3.00,3.00,'2025-11-12 15:07:28','2025-11-12 15:07:28'),(15,10,'consultation','Consultation Fee',NULL,NULL,NULL,1,3.00,3.00,'2025-11-12 15:07:28','2025-11-12 15:07:28'),(16,11,'consultation','Consultation Fee',NULL,NULL,NULL,1,3.00,3.00,'2025-11-12 15:11:32','2025-11-12 15:11:32'),(17,12,'consultation','Consultation Fee',NULL,NULL,NULL,1,3.00,3.00,'2025-11-12 15:20:56','2025-11-12 15:20:56'),(18,13,'consultation','Consultation Fee',NULL,NULL,NULL,1,3.00,3.00,'2025-11-13 18:14:32','2025-11-13 18:14:32'),(19,14,'consultation','Consultation Fee',NULL,NULL,NULL,1,3.00,3.00,'2025-11-13 18:44:17','2025-11-13 18:44:17'),(20,14,'prescription','Amox',NULL,NULL,NULL,1,150.00,150.00,'2025-11-13 18:44:28','2025-11-13 18:44:28'),(21,14,'prescription','Paracetamol',NULL,NULL,NULL,1,2.50,2.50,'2025-11-13 18:44:28','2025-11-13 18:44:28'),(22,15,'consultation','Consultation Fee',NULL,NULL,NULL,1,3.00,3.00,'2025-11-13 18:47:51','2025-11-13 18:47:51'),(23,16,'consultation','Consultation Fee',NULL,NULL,NULL,1,3.00,3.00,'2025-11-13 19:26:29','2025-11-13 19:26:29'),(24,17,'consultation','Consultation Fee',NULL,NULL,NULL,1,3.00,3.00,'2025-11-18 04:11:32','2025-11-18 04:11:32'),(25,18,'consultation','Consultation Fee',NULL,NULL,NULL,1,3.00,3.00,'2025-11-18 10:43:47','2025-11-18 10:43:47'),(26,19,'consultation','Consultation Fee',NULL,NULL,NULL,1,3.00,3.00,'2025-11-18 10:43:47','2025-11-18 10:43:47'),(27,20,'consultation','Consultation Fee',NULL,NULL,NULL,1,3.00,3.00,'2025-11-18 10:44:57','2025-11-18 10:44:57'),(28,21,'consultation','Consultation Fee',NULL,NULL,NULL,1,3.00,3.00,'2025-11-23 12:56:04','2025-11-23 12:56:04'),(29,22,'consultation','Consultation Fee',NULL,NULL,NULL,1,3.00,3.00,'2025-11-23 13:03:23','2025-11-23 13:03:23'),(30,23,'consultation','Consultation Fee',NULL,NULL,NULL,1,3.00,3.00,'2025-11-23 19:21:48','2025-11-23 19:21:48'),(31,24,'consultation','Consultation Fee',NULL,NULL,NULL,1,3.00,3.00,'2025-11-25 11:06:22','2025-11-25 11:06:22'),(32,25,'consultation','Consultation Fee',NULL,NULL,NULL,1,3.00,3.00,'2025-11-25 12:23:55','2025-11-25 12:23:55'),(33,26,'consultation','Consultation Fee',NULL,NULL,NULL,1,3.00,3.00,'2025-11-25 13:20:38','2025-11-25 13:20:38'),(34,27,'consultation','Consultation Fee',NULL,NULL,NULL,1,3.00,3.00,'2025-11-25 14:37:47','2025-11-25 14:37:47'),(35,28,'consultation','Consultation Fee',NULL,NULL,NULL,1,3.00,3.00,'2025-11-25 14:53:25','2025-11-25 14:53:25'),(36,29,'consultation','Consultation Fee',NULL,NULL,NULL,1,3.00,3.00,'2025-11-25 15:06:55','2025-11-25 15:06:55'),(37,30,'consultation','Consultation Fee',NULL,NULL,NULL,1,3.00,3.00,'2025-11-25 15:28:29','2025-11-25 15:28:29'),(38,31,'consultation','Consultation Fee',NULL,NULL,NULL,1,3.00,3.00,'2025-11-25 15:41:00','2025-11-25 15:41:00'),(39,32,'consultation','Consultation Fee',NULL,NULL,NULL,1,3.00,3.00,'2025-11-26 10:59:27','2025-11-26 10:59:27'),(40,33,'consultation','Consultation Fee',NULL,NULL,NULL,1,3.00,3.00,'2025-11-26 11:25:33','2025-11-26 11:25:33'),(41,34,'consultation','Consultation Fee',NULL,NULL,NULL,1,3.00,3.00,'2025-11-26 12:19:55','2025-11-26 12:19:55'),(42,35,'consultation','Consultation Fee',NULL,NULL,NULL,1,3.00,3.00,'2025-11-26 12:33:19','2025-11-26 12:33:19'),(43,36,'consultation','Consultation Fee',NULL,NULL,NULL,1,3.00,3.00,'2025-11-26 12:37:25','2025-11-26 12:37:25'),(44,37,'consultation','Consultation Fee',NULL,NULL,NULL,1,3.00,3.00,'2025-11-26 12:40:22','2025-11-26 12:40:22'),(45,38,'consultation','Consultation Fee',NULL,NULL,NULL,1,3.00,3.00,'2025-11-27 11:33:30','2025-11-27 11:33:30'),(46,39,'consultation','Consultation Fee',NULL,NULL,NULL,1,3.00,3.00,'2025-11-27 12:51:58','2025-11-27 12:51:58'),(47,40,'consultation','Consultation Fee',NULL,NULL,NULL,1,3.00,3.00,'2025-11-27 13:33:09','2025-11-27 13:33:09'),(48,41,'consultation','Consultation Fee',NULL,NULL,NULL,1,3.00,3.00,'2025-11-27 14:07:01','2025-11-27 14:07:01'),(49,42,'consultation','Consultation Fee',NULL,NULL,NULL,1,3.00,3.00,'2025-11-27 14:38:29','2025-11-27 14:38:29'),(50,43,'consultation','Consultation Fee',NULL,NULL,NULL,1,3.00,3.00,'2025-11-27 18:32:31','2025-11-27 18:32:31'),(51,44,'consultation','Consultation Fee',NULL,NULL,NULL,1,3.00,3.00,'2025-11-27 18:46:43','2025-11-27 18:46:43'),(52,45,'consultation','Consultation Fee',NULL,NULL,NULL,1,3.00,3.00,'2025-12-01 08:31:01','2025-12-01 08:31:01'),(53,46,'consultation','Consultation Fee',NULL,NULL,NULL,1,3.00,3.00,'2025-12-01 09:37:25','2025-12-01 09:37:25'),(54,47,'consultation','Consultation Fee',NULL,NULL,NULL,1,3.00,3.00,'2025-12-01 10:05:01','2025-12-01 10:05:01'),(55,48,'consultation','Consultation Fee',NULL,NULL,NULL,1,3.00,3.00,'2025-12-01 11:25:45','2025-12-01 11:25:45'),(56,49,'consultation','Consultation Fee',NULL,NULL,NULL,1,3.00,3.00,'2025-12-01 11:32:17','2025-12-01 11:32:17'),(57,50,'consultation','Consultation Fee',NULL,NULL,NULL,1,3.00,3.00,'2025-12-01 11:32:27','2025-12-01 11:32:27'),(58,51,'consultation','Consultation Fee',NULL,NULL,NULL,1,3.00,3.00,'2025-12-01 11:38:28','2025-12-01 11:38:28'),(59,52,'consultation','Consultation Fee',NULL,NULL,NULL,1,3.00,3.00,'2025-12-01 13:50:43','2025-12-01 13:50:43'),(60,53,'consultation','Consultation Fee',NULL,NULL,NULL,1,3.00,3.00,'2025-12-04 18:59:25','2025-12-04 18:59:25');
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
  `doctor_id` bigint unsigned DEFAULT NULL,
  `subtotal` decimal(10,2) NOT NULL DEFAULT '0.00',
  `discount` decimal(10,2) NOT NULL DEFAULT '0.00',
  `tax` decimal(10,2) NOT NULL DEFAULT '0.00',
  `total_amount` decimal(10,2) NOT NULL DEFAULT '0.00',
  `status` enum('unpaid','partial','paid') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'unpaid',
  `notes` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `bills_treatment_id_foreign` (`treatment_id`),
  KEY `bills_doctor_id_foreign` (`doctor_id`),
  KEY `bills_patient_id_treatment_id_status_index` (`patient_id`,`treatment_id`,`status`),
  CONSTRAINT `bills_doctor_id_foreign` FOREIGN KEY (`doctor_id`) REFERENCES `doctors` (`id`) ON DELETE SET NULL,
  CONSTRAINT `bills_patient_id_foreign` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`id`) ON DELETE CASCADE,
  CONSTRAINT `bills_treatment_id_foreign` FOREIGN KEY (`treatment_id`) REFERENCES `treatments` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=54 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bills`
--

LOCK TABLES `bills` WRITE;
/*!40000 ALTER TABLE `bills` DISABLE KEYS */;
INSERT INTO `bills` VALUES (1,3,5,NULL,3.00,0.00,0.00,3.00,'paid',NULL,'2025-11-07 08:05:40','2025-11-07 08:06:04'),(2,1,6,2,3.00,0.00,0.00,3.00,'paid',NULL,'2025-11-07 08:06:56','2025-11-07 09:41:34'),(3,4,7,NULL,3.00,0.00,0.00,3.00,'unpaid',NULL,'2025-11-07 09:38:06','2025-11-07 09:38:06'),(4,3,8,NULL,305.00,0.00,0.00,305.00,'paid',NULL,'2025-11-07 09:48:18','2025-11-12 17:33:27'),(5,3,9,NULL,5.50,0.00,0.00,5.50,'unpaid',NULL,'2025-11-07 10:37:26','2025-11-07 10:37:36'),(6,5,10,NULL,10.50,0.00,0.00,10.50,'paid',NULL,'2025-11-07 10:48:59','2025-11-07 19:04:38'),(7,15,11,NULL,3.00,0.00,0.00,3.00,'unpaid',NULL,'2025-11-12 10:09:16','2025-11-12 10:09:16'),(8,14,12,NULL,3.00,0.00,0.00,3.00,'unpaid',NULL,'2025-11-12 14:12:26','2025-11-12 14:12:26'),(9,14,13,4,3.00,0.00,0.00,3.00,'paid',NULL,'2025-11-12 15:07:28','2025-11-12 17:32:45'),(10,14,14,4,3.00,0.00,0.00,3.00,'unpaid',NULL,'2025-11-12 15:07:28','2025-11-12 15:07:28'),(11,14,15,NULL,3.00,0.00,0.00,3.00,'paid',NULL,'2025-11-12 15:11:32','2025-11-17 11:49:39'),(12,15,16,6,3.00,0.00,0.00,3.00,'paid',NULL,'2025-11-12 15:20:56','2025-11-12 17:32:56'),(13,12,17,6,3.00,0.00,0.00,3.00,'paid',NULL,'2025-11-13 18:14:32','2025-11-13 19:26:59'),(14,16,18,6,155.50,0.00,0.00,155.50,'paid',NULL,'2025-11-13 18:44:17','2025-11-13 18:45:09'),(15,16,19,6,3.00,0.00,0.00,3.00,'paid',NULL,'2025-11-13 18:47:51','2025-11-13 19:27:12'),(16,16,20,6,3.00,0.00,0.00,3.00,'paid',NULL,'2025-11-13 19:26:29','2025-11-14 21:15:03'),(17,17,21,4,3.00,0.00,0.00,3.00,'unpaid',NULL,'2025-11-18 04:11:32','2025-11-18 04:11:32'),(18,18,22,4,3.00,0.00,0.00,3.00,'paid',NULL,'2025-11-18 10:43:47','2025-11-23 11:20:55'),(19,18,23,4,3.00,0.00,0.00,3.00,'unpaid',NULL,'2025-11-18 10:43:47','2025-11-18 10:43:47'),(20,18,24,4,3.00,0.00,0.00,3.00,'unpaid',NULL,'2025-11-18 10:44:57','2025-11-18 10:44:57'),(21,50,25,3,3.00,0.00,0.00,3.00,'unpaid',NULL,'2025-11-23 12:56:04','2025-11-23 12:56:04'),(22,59,26,2,3.00,0.00,0.00,3.00,'unpaid',NULL,'2025-11-23 13:03:23','2025-11-23 13:03:23'),(23,16,27,6,3.00,0.00,0.00,3.00,'unpaid',NULL,'2025-11-23 19:21:48','2025-11-23 19:21:48'),(24,81,28,4,3.00,0.00,0.00,3.00,'unpaid',NULL,'2025-11-25 11:06:22','2025-11-25 11:06:22'),(25,82,29,4,3.00,0.00,0.00,3.00,'unpaid',NULL,'2025-11-25 12:23:55','2025-11-25 12:23:55'),(26,67,30,4,3.00,0.00,0.00,3.00,'unpaid',NULL,'2025-11-25 13:20:38','2025-11-25 13:20:38'),(27,83,31,4,3.00,0.00,0.00,3.00,'unpaid',NULL,'2025-11-25 14:37:47','2025-11-25 14:37:47'),(28,84,32,4,3.00,0.00,0.00,3.00,'unpaid',NULL,'2025-11-25 14:53:25','2025-11-25 14:53:25'),(29,85,33,4,3.00,0.00,0.00,3.00,'unpaid',NULL,'2025-11-25 15:06:55','2025-11-25 15:06:55'),(30,86,34,4,3.00,0.00,0.00,3.00,'unpaid',NULL,'2025-11-25 15:28:29','2025-11-25 15:28:29'),(31,87,35,4,3.00,0.00,0.00,3.00,'unpaid',NULL,'2025-11-25 15:41:00','2025-11-25 15:41:00'),(32,97,36,4,3.00,0.00,0.00,3.00,'unpaid',NULL,'2025-11-26 10:59:27','2025-11-26 10:59:27'),(33,98,37,4,3.00,0.00,0.00,3.00,'unpaid',NULL,'2025-11-26 11:25:33','2025-11-26 11:25:33'),(34,99,38,4,3.00,0.00,0.00,3.00,'unpaid',NULL,'2025-11-26 12:19:55','2025-11-26 12:19:55'),(35,100,39,4,3.00,0.00,0.00,3.00,'unpaid',NULL,'2025-11-26 12:33:19','2025-11-26 12:33:19'),(36,101,40,4,3.00,0.00,0.00,3.00,'unpaid',NULL,'2025-11-26 12:37:25','2025-11-26 12:37:25'),(37,100,41,4,3.00,0.00,0.00,3.00,'unpaid',NULL,'2025-11-26 12:40:22','2025-11-26 12:40:22'),(38,85,42,4,3.00,0.00,0.00,3.00,'unpaid',NULL,'2025-11-27 11:33:30','2025-11-27 11:33:30'),(39,108,43,4,3.00,0.00,0.00,3.00,'unpaid',NULL,'2025-11-27 12:51:58','2025-11-27 12:51:58'),(40,21,44,4,3.00,0.00,0.00,3.00,'unpaid',NULL,'2025-11-27 13:33:09','2025-11-27 13:33:09'),(41,109,45,4,3.00,0.00,0.00,3.00,'unpaid',NULL,'2025-11-27 14:07:01','2025-11-27 14:07:01'),(42,110,46,4,3.00,0.00,0.00,3.00,'unpaid',NULL,'2025-11-27 14:38:29','2025-11-27 14:38:29'),(43,112,47,6,3.00,0.00,0.00,3.00,'unpaid',NULL,'2025-11-27 18:32:31','2025-11-27 18:32:31'),(44,111,48,6,3.00,0.00,0.00,3.00,'unpaid',NULL,'2025-11-27 18:46:43','2025-11-27 18:46:43'),(45,162,49,4,3.00,0.00,0.00,3.00,'unpaid',NULL,'2025-12-01 08:31:01','2025-12-01 08:31:01'),(46,164,50,4,3.00,0.00,0.00,3.00,'unpaid',NULL,'2025-12-01 09:37:25','2025-12-01 09:37:25'),(47,164,51,4,3.00,0.00,0.00,3.00,'unpaid',NULL,'2025-12-01 10:05:01','2025-12-01 10:05:01'),(48,165,52,4,3.00,0.00,0.00,3.00,'unpaid',NULL,'2025-12-01 11:25:45','2025-12-01 11:25:45'),(49,101,53,4,3.00,0.00,0.00,3.00,'unpaid',NULL,'2025-12-01 11:32:17','2025-12-01 11:32:17'),(50,101,54,4,3.00,0.00,0.00,3.00,'unpaid',NULL,'2025-12-01 11:32:27','2025-12-01 11:32:27'),(51,100,55,4,3.00,0.00,0.00,3.00,'unpaid',NULL,'2025-12-01 11:38:28','2025-12-01 11:38:28'),(52,97,56,4,3.00,0.00,0.00,3.00,'unpaid',NULL,'2025-12-01 13:50:43','2025-12-01 13:50:43'),(53,16,57,6,3.00,0.00,0.00,3.00,'paid',NULL,'2025-12-04 18:59:25','2025-12-04 19:00:16');
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
INSERT INTO `doctors` VALUES (1,'James','Otieno','Cardiology','0700000000','j.otieno@example.com','2025-11-06 19:30:36','2025-11-06 19:30:36'),(2,'Sarah','Mutua','Pediatrics','0711111111','s.mutua@example.com','2025-11-06 19:30:36','2025-11-06 19:30:36'),(3,'Paul','Mwangi','General Medicine','0722222222','p.mwangi@example.com','2025-11-06 19:30:36','2025-11-06 19:30:36'),(4,'MAURINE','AKINYI',NULL,'254713015353','maurineakinyi41@gmail.com','2025-11-11 08:11:07','2025-11-11 08:11:07'),(6,'Doctor','Doc',NULL,'0701430850','collinsogada452@gmail.com','2025-11-07 15:35:07','2025-11-26 07:33:47');
/*!40000 ALTER TABLE `doctors` ENABLE KEYS */;
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
  `reorder_level` int unsigned NOT NULL DEFAULT '0',
  `unit_price` decimal(10,2) NOT NULL DEFAULT '0.00',
  `supplier_id` bigint unsigned DEFAULT NULL,
  `expiry_date` date DEFAULT NULL,
  `batch_no` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `location` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `inventory_items_item_code_unique` (`item_code`),
  KEY `inventory_items_supplier_id_foreign` (`supplier_id`),
  CONSTRAINT `inventory_items_supplier_id_foreign` FOREIGN KEY (`supplier_id`) REFERENCES `suppliers` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inventory_items`
--

LOCK TABLES `inventory_items` WRITE;
/*!40000 ALTER TABLE `inventory_items` DISABLE KEYS */;
INSERT INTO `inventory_items` VALUES (1,'MED-00001','Paracetamol','Medicine',NULL,102,'tablet',10,2.50,1,'2026-01-01','BATCH-A','Pharmacy A','2025-11-06 19:30:36','2025-12-04 18:59:39'),(2,'EQP-00002','Syringe 5ml','Equipment',NULL,299,'piece',50,0.80,1,NULL,NULL,'Store Room','2025-11-06 19:30:36','2025-11-07 09:49:34'),(3,'CON-00003','Bandage Roll','Consumable',NULL,72,'roll',20,1.20,1,NULL,NULL,'Store Room','2025-11-06 19:30:36','2025-12-04 18:59:39'),(4,'MED-00004','Amox','Medicine',NULL,8,NULL,0,150.00,NULL,'2026-02-20',NULL,NULL,'2025-11-07 09:05:46','2025-12-04 19:09:28');
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
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inventory_transactions`
--

LOCK TABLES `inventory_transactions` WRITE;
/*!40000 ALTER TABLE `inventory_transactions` DISABLE KEYS */;
INSERT INTO `inventory_transactions` VALUES (1,1,'in',120,120,'Seed stock',NULL,'seeder','2025-11-06 19:30:36','2025-11-06 19:30:36'),(2,2,'in',300,300,'Seed stock',NULL,'seeder','2025-11-06 19:30:36','2025-11-06 19:30:36'),(3,3,'in',75,75,'Seed stock',NULL,'seeder','2025-11-06 19:30:36','2025-11-06 19:30:36'),(4,4,'in',30,30,'Initial stock',NULL,'system','2025-11-07 09:05:46','2025-11-07 09:05:46');
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
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `migrations`
--

LOCK TABLES `migrations` WRITE;
/*!40000 ALTER TABLE `migrations` DISABLE KEYS */;
INSERT INTO `migrations` VALUES (1,'0001_01_01_000000_create_users_table',1),(2,'0001_01_01_000001_create_cache_table',1),(3,'0001_01_01_000002_create_jobs_table',1),(4,'2025_10_10_222933_create_patients_table',1),(5,'2025_10_10_233647_create_treatments_table',1),(6,'2025_10_20_140747_create_doctors_table',1),(7,'2025_10_20_150412_create_appointments_table',1),(8,'2025_10_23_111635_create_suppliers_table',1),(9,'2025_10_23_111636_create_inventory_items_table',1),(10,'2025_10_23_111637_create_inventory_transactions_table',1),(11,'2025_10_26_145745_create_prescriptions_table',1),(12,'2025_10_26_145746_create_prescription_items_table',1),(13,'2025_10_26_190240_add_doctor_id_to_treatments_table',1),(14,'2025_10_26_201006_create_bills_table',1),(15,'2025_10_26_201007_create_bill_items_table',1),(16,'2025_10_26_201008_create_payments_table',1),(17,'2025_10_28_000000_add_treatment_id_to_prescriptions_table',1),(18,'2025_11_01_182327_add_status_columns_to_related_tables',1),(19,'2025_11_02_234052_create_personal_access_tokens_table',1),(20,'2025_11_02_235741_create_staff_table',1),(21,'2025_11_02_235742_create_staff_documents_table',1);
/*!40000 ALTER TABLE `migrations` ENABLE KEYS */;
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
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `patients_upid_unique` (`upid`),
  UNIQUE KEY `patients_national_id_unique` (`national_id`)
) ENGINE=InnoDB AUTO_INCREMENT=176 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `patients`
--

LOCK TABLES `patients` WRITE;
/*!40000 ALTER TABLE `patients` DISABLE KEYS */;
INSERT INTO `patients` VALUES (1,'HMS-690CF75C19705',NULL,'Samuel','Orwa','M','2001-04-04',NULL,'0716095621','orwasamuel7@example.com','Ng\'elel Tarit, Eldoret','2025-11-06 19:30:36','2025-11-20 22:14:12'),(2,'HMS-690CF75C19734',NULL,'Mary','Achieng','F','1990-07-21',NULL,'0733333333','mary.achieng@example.com','Nairobi, Kenya','2025-11-06 19:30:36','2025-11-06 19:30:36'),(3,'CH-00001','1237445','Clemo','Washington','M','2025-11-07',NULL,'0700011112','clemo@gmail.com','Eldoret','2025-11-07 08:04:48','2025-11-10 10:43:54'),(4,'CH-00002','444555','James','Gichuki','M','2024-10-04',NULL,'0701430851','james12@yahoo.com','Kikuyu','2025-11-07 09:37:00','2025-11-07 09:37:00'),(5,'CH-00003','121234','Chris','Tolemi','M',NULL,NULL,NULL,NULL,NULL,'2025-11-07 10:46:24','2025-11-07 10:46:24'),(6,'CH-00004',NULL,'Kamau','John','M',NULL,NULL,NULL,NULL,NULL,'2025-11-09 14:02:11','2025-11-09 14:02:11'),(7,'CH-00005',NULL,'ESTHER','NGUGI','F',NULL,NULL,'0706386443',NULL,NULL,'2025-11-11 07:50:18','2025-11-11 07:50:18'),(8,'CH-00006',NULL,'zena','kosgei','F',NULL,NULL,NULL,NULL,NULL,'2025-11-11 08:23:46','2025-11-11 08:50:17'),(9,'CH-00007',NULL,'collins','kosgei','M',NULL,NULL,NULL,NULL,NULL,'2025-11-11 08:25:35','2025-11-11 08:25:35'),(10,'CH-00008',NULL,'Derick','Omondi','M',NULL,NULL,'0701430851',NULL,'Allsops,Thika Road','2025-11-11 08:31:55','2025-11-11 08:31:55'),(11,'CH-00009','40223435','Mishel','Rabel','F','2002-09-14',NULL,'0110497040',NULL,NULL,'2025-11-11 08:44:15','2025-11-11 08:44:15'),(12,'CH-00010',NULL,'Harrun','Kosgei','M',NULL,NULL,'0704727774',NULL,NULL,'2025-11-11 08:48:38','2025-11-11 08:48:38'),(13,'CH-00011',NULL,'Edith','Cherotich','F',NULL,NULL,'0719895188',NULL,NULL,'2025-11-11 08:53:56','2025-11-11 08:53:56'),(14,'CH-00012','12374457','Steve','Steve','M','2004-11-11',NULL,'0700011112','steve@gmail.com','Nairobi 11,','2025-11-12 06:27:59','2025-11-12 06:27:59'),(15,'CH-00013',NULL,'Beatrice','Koskei','F',NULL,NULL,'0720249908',NULL,'Kapsoya, Eldoret','2025-11-12 10:07:17','2025-11-20 22:24:21'),(16,'CH-00014','11122333','Chris','Cross','M','2004-11-12',21,'0700011227','sample@gmail.com','NA, NAIROBI','2025-11-13 18:43:40','2025-11-13 18:43:40'),(17,'CH-00015','12121234','Abc','Jkl','M','2003-11-16',22,'053088033',NULL,'Saudi Arabia, Dhahran 11','2025-11-17 11:17:08','2025-11-17 11:17:08'),(18,'CH-00016','121212','Ian','Ian','M','2003-11-17',22,'0701430850','tottin254@gmail.com','Allsops,Thika Road','2025-11-18 10:43:06','2025-11-18 10:43:06'),(19,'CH-00017',NULL,'Muhamud','Abdilai','M','1963-11-19',62,'0725437780',NULL,'Mariakani','2025-11-20 09:31:44','2025-11-20 09:31:44'),(20,'CH-00018',NULL,'Eda','Nekesa','F','1987-11-19',38,'0708615194',NULL,'Kapsoya','2025-11-20 10:26:37','2025-11-20 10:27:15'),(21,'CH-00019',NULL,'Sonia','Sang','F','2002-11-19',23,'0712551136',NULL,'Kapsoya','2025-11-20 11:05:08','2025-11-20 11:05:08'),(22,'CH-00020',NULL,'Janet','Mkoshi','F','1971-11-19',54,'0711669852',NULL,'Kapsoya, Eldoret','2025-11-20 11:08:43','2025-11-23 05:35:48'),(23,'CH-00021',NULL,'ADUT','MAPER','F','2001-11-19',24,'0740918846',NULL,'Kapsoya, Eldoret','2025-11-20 11:51:35','2025-11-20 22:20:19'),(24,'CH-00022','26746356','Joyce Tarimo','Muruka','F','1975-01-01',50,'0720175870',NULL,'Kapsoya, Eldoret','2025-11-20 17:19:00','2025-11-22 17:19:41'),(25,'CH-00023',NULL,'Josphine','Kipkoti','F','1965-05-13',60,'0797183666',NULL,'Kapsoya, Eldoret','2025-11-20 22:04:52','2025-11-21 18:13:04'),(26,'CH-00024',NULL,'Bol','Pager','M','2010-11-20',15,'0797828493',NULL,'Kapsoya, Eldoret','2025-11-21 16:03:13','2025-11-21 16:03:13'),(27,'CH-00025',NULL,'Aluel','Leek','F','2001-11-20',24,'0790160959',NULL,'Kapsoya, Eldoret','2025-11-21 16:13:24','2025-11-21 18:11:04'),(28,'CH-00026',NULL,'Ayak','Pach','F','2008-11-20',17,'0705697948',NULL,'Kapsoya, Eldoret','2025-11-21 18:02:40','2025-11-21 18:08:24'),(29,'CH-00027',NULL,'Chol','Thong','M','2003-11-20',22,'0717719755',NULL,'Kapsoya, Eldoret','2025-11-21 18:05:20','2025-11-21 18:07:20'),(30,'CH-00028',NULL,'Ajang','Kuer','M','2008-11-20',17,'0718757695',NULL,'Kapsoya, Eldoret','2025-11-21 18:16:47','2025-11-21 18:16:47'),(31,'CH-00029',NULL,'Akok','Deng','M','2017-11-20',8,'0714715587',NULL,'Kapsoya, Eldoret','2025-11-21 18:21:08','2025-11-21 18:21:08'),(32,'CH-00030',NULL,'Nyanachiec','Marial','F','2019-11-20',6,'0794227707',NULL,'Kapsoya, Eldoret','2025-11-21 18:25:33','2025-11-21 18:25:33'),(33,'CH-00031',NULL,'Angieth','Gai','M','2022-11-20',3,'0794227707',NULL,'Kapsoya, Eldoret','2025-11-21 18:28:46','2025-11-21 18:28:46'),(34,'CH-00032',NULL,'Ayen','Chol','F','2010-11-20',15,'0793624014',NULL,'Kapsoya, Eldoret','2025-11-21 18:31:00','2025-11-21 18:31:00'),(35,'CH-00033',NULL,'Mercy','Aluak','F','2011-11-20',14,'0718099580',NULL,'Kapsoya, Eldoret','2025-11-21 18:34:21','2025-11-21 18:34:21'),(36,'CH-00034',NULL,'Yar','Akech','F','2001-11-20',24,'0792194186',NULL,'Kapsoya, Eldoret','2025-11-21 18:47:52','2025-11-21 18:47:52'),(37,'CH-00035',NULL,'Ruth','Achieng','F','1999-11-20',26,'0758528035',NULL,'Kapsoya, Eldoret','2025-11-21 19:15:03','2025-11-21 19:15:03'),(38,'CH-00036',NULL,'Donald','Kidako','M','1992-08-13',NULL,'0723265360',NULL,'Kapsoya, Eldoret','2025-11-21 19:17:16','2025-11-22 05:08:24'),(39,'CH-00037',NULL,'Elvis','Mukunza','M','2025-11-21',0,'0723265360',NULL,'Kapsoya, Eldoret','2025-11-22 05:11:31','2025-11-22 05:11:31'),(40,'CH-00038','24060885','Nancy','Ogenga','F','1985-11-21',40,'0719759955',NULL,'Kapsoya, Eldoret','2025-11-22 05:15:16','2025-11-22 05:15:16'),(41,'CH-00039',NULL,'Pamela','Jepkoech','F','1988-11-21',37,'0723234662',NULL,'Jeru, Eldoret','2025-11-22 05:19:51','2025-11-22 05:19:51'),(42,'CH-00040',NULL,'Bor','Deng','M','1998-11-21',27,'0114010422',NULL,'Kapsoya, Eldoret','2025-11-22 05:30:04','2025-11-22 05:30:04'),(43,'CH-00041',NULL,'Emmanuel','Kipkosgei','M','2000-11-21',25,'0796678547',NULL,'Kapsoya, Eldoret','2025-11-22 05:35:19','2025-11-22 05:35:19'),(44,'CH-00042',NULL,'Daisy','Talam','F','1996-11-21',29,'0795882774',NULL,'Kapsoya, Eldoret','2025-11-22 05:37:51','2025-11-22 05:37:51'),(45,'CH-00043',NULL,'Elsie','Chebichii','F','2003-11-21',22,'0726808427',NULL,'Mosoriot, Eldoret','2025-11-22 05:40:15','2025-11-22 05:40:15'),(46,'CH-00044',NULL,'Timah','Mohamed','F','1975-11-21',50,'0715139853',NULL,'Samar, Eldoret','2025-11-22 08:44:09','2025-11-22 15:31:28'),(47,'CH-00045',NULL,'Jayden','Kiprop','M','2017-11-21',8,'0720974925',NULL,'Kapsoya, Eldoret','2025-11-22 08:45:34','2025-11-22 15:29:21'),(48,'CH-00046',NULL,'William','Rono  KIPLIMO','M',NULL,NULL,NULL,NULL,'Kapsoya, Eldoret','2025-11-22 08:46:20','2025-11-27 06:53:37'),(49,'CH-00047',NULL,'Myles','Kipkoech','M','2019-11-21',6,'0727271868',NULL,'Annex, Eldoret','2025-11-22 12:27:19','2025-11-22 17:15:36'),(50,'CH-00048',NULL,'Miquel','Kiprop','M','2022-11-21',3,'0727271868',NULL,'Annex,  Eldoret','2025-11-22 12:28:17','2025-11-22 17:10:01'),(51,'CH-00049',NULL,'Wesley','Nekesa','F',NULL,NULL,'0758894250',NULL,'Kapsoya, Eldoret','2025-11-22 14:16:05','2025-11-22 17:07:31'),(52,'CH-00050',NULL,'George','Gachege','M','1980-11-21',45,'0726809573',NULL,'Kapsoya, Eldoret','2025-11-22 14:17:59','2025-11-22 17:05:39'),(53,'CH-00051',NULL,'Faith','Njiru','F','1991-11-21',34,'0718434693',NULL,'Kapsoya, Eldoret','2025-11-22 17:00:25','2025-11-22 17:00:25'),(54,'CH-00052','29867488','Shadrack Okello','Amayi','M','1992-11-21',33,'0704353948',NULL,'Kapsoya, Eldoret','2025-11-22 19:40:20','2025-11-22 20:06:08'),(55,'CH-00053',NULL,'Brian  Kipchumba','Koros','M','1999-11-21',26,'0792564214',NULL,'Kapsoya, Eldoret','2025-11-22 19:43:38','2025-11-22 19:43:38'),(56,'CH-00054',NULL,'Collins','Okello','M','2021-11-22',4,'0706309737',NULL,'Juniorate','2025-11-23 08:49:42','2025-11-23 08:49:42'),(57,'CH-00055','28413358','Brenda','Achieng','F','1991-11-22',34,'0703722460',NULL,'Kapsoya','2025-11-23 10:44:31','2025-11-23 10:44:31'),(58,'CH-00056',NULL,'Akur','Agot','F','1986-11-22',39,'0706519551',NULL,'kapsoya','2025-11-23 10:47:23','2025-11-23 10:47:23'),(59,'CH-00057','12121236','Olives','Oduya Adhiambo','F','2005-07-19',19,'0103621124','Adhiamboolives@g.mail.com','Two Rivers Estate','2025-11-23 11:24:56','2025-11-24 07:59:11'),(60,'CH-00058',NULL,'Bryce','Andy','M','2020-11-22',5,'0703446914',NULL,'Kapsoya','2025-11-23 13:36:55','2025-11-23 13:36:55'),(61,'CH-00059',NULL,'Leonidah','Chepkoech','F','2005-11-22',20,'0722556566',NULL,'Kapsoya, Eldoret','2025-11-23 13:38:45','2025-11-23 17:31:42'),(62,'CH-00060',NULL,'Josphine','Cheruiyot','F','1951-11-23',74,'0723406686',NULL,'Kapsoya, Eldoret','2025-11-24 05:05:15','2025-11-24 05:05:15'),(63,'CH-00061',NULL,'Victoria Igadiza','Muchera','F','2021-11-23',4,'0111923468',NULL,'Kapsoya, Eldoret','2025-11-24 05:08:39','2025-11-24 05:10:59'),(64,'CH-00062',NULL,'Joy Blessing','Muchera','F','2017-11-23',8,'0111923468',NULL,'Kapsoya, Eldoret','2025-11-24 05:10:05','2025-11-24 05:10:05'),(65,'CH-00063',NULL,'Irine','Jeptanui','F','1997-11-23',28,'0729576243',NULL,'Kapsoya, Eldoret','2025-11-24 05:13:14','2025-11-24 05:13:14'),(66,'CH-00064','29171912','Joseph','Marathu Gitau','M','1995-11-23',30,'0795036304',NULL,'Bahatii','2025-11-24 06:57:29','2025-11-24 06:57:29'),(67,'CH-00065','2312348','Richard','Kutto Kipkosgei','M','1981-11-23',44,'07053123737',NULL,'Illula','2025-11-24 07:51:44','2025-11-24 07:51:44'),(68,'CH-00066',NULL,'Irine','Chesang','F','1985-11-23',40,'0713540543',NULL,'Kapsoya','2025-11-24 10:10:06','2025-11-24 10:10:06'),(69,'CH-00067',NULL,'Dorine','Omwega','F','1996-11-23',29,'0717586813',NULL,'Kapsoya, Eldoret','2025-11-24 10:11:37','2025-11-24 13:21:44'),(70,'CH-00068',NULL,'Sharon','Atieno','F','1996-11-23',29,'0715925858',NULL,'Kapsoya, Eldoret','2025-11-24 10:51:34','2025-11-24 13:21:15'),(71,'CH-00069',NULL,'Nancy','Atieno','F','1985-11-23',40,'0719759955',NULL,'Kapsoya, Eldoret','2025-11-24 13:20:41','2025-11-24 13:20:41'),(72,'CH-00070',NULL,'Vincent','Wafula Juma','M','2018-11-23',7,'0721329162',NULL,'Munyaka','2025-11-24 14:22:17','2025-11-24 14:22:17'),(73,'CH-00071',NULL,'Angeline','Arimuk','F','1987-11-24',38,'0728409570',NULL,'kapsoya, Eldoret','2025-11-25 06:44:44','2025-11-25 06:44:44'),(74,'CH-00072',NULL,'Ieden','Kidakwa  Mukunza','M','2019-11-24',6,'0797942996',NULL,'Kapsoya, Eldoret','2025-11-25 08:16:02','2025-11-25 08:16:02'),(75,'CH-00073',NULL,'Alvauria','Khasoa Mukunza','F','2024-11-24',1,'0797942996',NULL,'Kapsoya, Eldoret','2025-11-25 08:17:32','2025-11-25 08:17:32'),(76,'CH-00074','31451852','Elvis','Mukunza','M','1993-11-24',32,'0797942996',NULL,'Kapsoya, Eldoret','2025-11-25 08:18:49','2025-11-25 08:18:49'),(77,'CH-00075','39576516','Caleb','Kimutai','M','2001-11-24',24,'0717379431',NULL,'Kapsoya, Eldoret','2025-11-25 08:20:12','2025-11-25 08:20:12'),(78,'CH-00076',NULL,'WILLIS','Juma Ochieng','M','1990-11-24',35,'0704351839',NULL,'Kapsoya, Eldoret','2025-11-25 10:32:41','2025-11-25 10:32:41'),(79,'CH-00077',NULL,'Wayne','Rooney Wanjiku','M','2013-11-24',12,'0704351839',NULL,'Kpsoya, Eldoret','2025-11-25 10:34:23','2025-11-25 10:34:23'),(80,'CH-00078',NULL,'Ann','Wanjiku  Karanja','F','2000-11-24',25,'0748665463',NULL,'Kpsoya, Eldoret','2025-11-25 10:35:55','2025-11-25 10:35:55'),(81,'CH-00079',NULL,'Haron','Kimutai','M','2001-11-24',24,'07177379431',NULL,'Kapsoya,Kenya','2025-11-25 10:55:43','2025-11-25 10:55:43'),(82,'CH-00080',NULL,'MELVIN','ADHIAMBO','F','1998-11-24',27,'0713151350',NULL,'Juniorate, Kapsoya','2025-11-25 11:46:16','2025-11-25 15:32:08'),(83,'CH-00081','11592887','FAITH','MBULA','F','1977-11-24',48,'0726778005',NULL,NULL,'2025-11-25 14:07:16','2025-11-25 15:31:09'),(84,'CH-00082','28785446','JACKLINE','ACHIENG AWUOR','F','1987-11-24',38,'0718786948',NULL,'Kapsoya, eldoret','2025-11-25 14:18:37','2025-11-25 15:30:18'),(85,'CH-00083',NULL,'FAITH','DBORAH OUMA','F','2019-11-24',6,'0708615194',NULL,'Kapsoya, eldoret','2025-11-25 14:52:23','2025-11-25 15:29:06'),(86,'CH-00084','31234386','NANCY','AYESA','F','1982-11-24',43,'0746905730',NULL,'KAPSOYA-ESTATE.ELDORET','2025-11-25 15:01:42','2025-11-25 15:01:42'),(87,'CH-00085','32570614','CHRISTINE','MAKENA','F','1993-11-24',32,'0721113255',NULL,'KAPSOYA, ELDORET','2025-11-25 15:09:37','2025-11-25 15:09:37'),(88,'CH-00086','25803067','EDWARD','ADWET','M','1986-11-24',39,'0786107425',NULL,'KIPKORGOT, ELDORET','2025-11-25 15:33:33','2025-11-25 15:33:33'),(89,'CH-00087','25665981','WINNNY','TIBIN MANGESOI','F','1989-11-25',36,'0704446274',NULL,'KAPSOYA, ELDORET','2025-11-26 06:16:57','2025-11-26 06:16:57'),(90,'CH-00088',NULL,'BERYL','JEPTOO KOECH','F',NULL,NULL,'0704446274',NULL,'KAPSOYA, ELDORET','2025-11-26 07:19:29','2025-11-26 07:19:29'),(91,'CH-00089',NULL,'SHEENA','BARTIEN CHEBOR','F','2022-11-25',3,'072226320',NULL,'KAPSOYA','2025-11-26 07:42:14','2025-11-26 07:42:14'),(92,'CH-00090',NULL,'ADRIAN','JOHNSON KIGEN','M','2015-11-25',10,'0720985863',NULL,'KAPSOYA, ELDORET','2025-11-26 09:08:38','2025-11-26 09:08:38'),(93,'CH-00091',NULL,'CLARE','JELAGAT','F','2017-11-25',8,'0720985863',NULL,'KAPSOYA, ELDORET','2025-11-26 09:09:43','2025-11-26 09:09:43'),(94,'CH-00092',NULL,'MELISSA','CHEPKWONY','F','2021-11-25',4,'0716620592',NULL,'KAPSOYA, ELDORET','2025-11-26 09:11:11','2025-11-26 09:11:11'),(95,'CH-00093',NULL,'MARY','ATIENO','F','2011-11-25',14,'0759799608',NULL,'MUNYAKA, ELDORET','2025-11-26 09:12:49','2025-11-26 09:12:49'),(96,'CH-00094',NULL,'MILLY','CHEPKOSGEI','F','1991-11-25',34,'0759799608',NULL,'MUNYAKA, ELDORET','2025-11-26 09:13:38','2025-11-26 09:13:38'),(97,'CH-00095','28540987','MARK','TANUI','M','1985-11-25',40,'070619514',NULL,'KAPSOYA, ELDORET','2025-11-26 10:41:51','2025-11-26 10:41:51'),(98,'CH-00096',NULL,'ALCASA','KALAHARI','M','1999-11-25',26,'0704138554',NULL,'KAPSOYA','2025-11-26 11:09:30','2025-11-26 11:09:30'),(99,'CH-00097',NULL,'PROMISE','MAINA MWANGI','M','2015-11-25',10,'0721474407',NULL,'KAPSOYA','2025-11-26 11:56:58','2025-11-26 11:56:58'),(100,'CH-00098',NULL,'ASHER','LIMO KIMANI','M','2021-11-25',4,'22434029',NULL,'KAPSOYA','2025-11-26 12:23:13','2025-11-26 12:23:13'),(101,'CH-00099',NULL,'SANDRA','JEMUTAI LIMO','F','2001-11-25',24,'0722434029',NULL,'KAPSOYA','2025-11-26 12:25:07','2025-11-26 12:25:07'),(102,'CH-00100','38358641','MERCELINE','INAPAA','F','2002-11-25',23,'0793612598',NULL,NULL,'2025-11-26 15:14:30','2025-11-26 15:14:30'),(103,'CH-00101','35209609','VINCENT','ONYANGO','M','2000-11-25',25,'0715686769',NULL,'KAPSOYA, ELDORET','2025-11-26 18:54:08','2025-11-26 18:54:08'),(104,'CH-00102',NULL,'GOAMAR','GIDEON','F','2004-11-26',21,'0707333059',NULL,'KAPSOYA ,ELDORET','2025-11-27 03:25:39','2025-11-27 03:25:39'),(105,'CH-00103',NULL,'SABASTIAN','RONOO','M','2020-11-26',5,'0728089588',NULL,'KAPSOYA, ELDORET','2025-11-27 07:03:48','2025-11-27 07:03:48'),(106,'CH-00104',NULL,'SCOLASTICAH','CHEROP','F','1998-11-26',27,'0795690628',NULL,'KAPSOYA, ELDORET','2025-11-27 08:08:53','2025-11-27 08:08:53'),(107,'CH-00105','11024239','REGINA','SAMBU JEPKOECH','F','1970-11-26',55,'0725943996',NULL,'ILLULA, ELDORET','2025-11-27 09:33:07','2025-11-27 09:33:07'),(108,'CH-00106',NULL,'LOGAN','KIPROTICH','M','2019-11-26',6,'0728151377',NULL,'KAPSOYA','2025-11-27 12:32:31','2025-11-27 12:32:31'),(109,'CH-00107',NULL,'BEN','PINTONE','M','2015-11-26',10,'0721248278',NULL,'KAPSOYA','2025-11-27 13:23:56','2025-11-27 13:23:56'),(110,'CH-00108',NULL,'JANE','WANJIKU KARIUKI','F','1971-11-26',54,'0722479481',NULL,'KAPSOYA','2025-11-27 13:30:15','2025-11-27 13:30:15'),(111,'CH-00109','880104','MARY','AYUEN','F','1989-11-26',36,'0725280286',NULL,'KAPSOYA , ELDORET','2025-11-27 16:21:12','2025-11-27 16:21:12'),(112,'CH-00110','2052396','FAUSTINE','DIYA','F','1959-11-26',66,'0716823554',NULL,'KAPSOYA , ELDORET','2025-11-27 18:16:40','2025-11-27 18:16:40'),(113,'CH-00111',NULL,'AYAK','PACH','F','2008-11-27',17,'0728807214',NULL,'KAPSOYA','2025-11-28 09:48:04','2025-11-28 09:48:04'),(114,'CH-00112',NULL,'AKIM','JOSEPH','M','2016-11-27',9,'0700844884',NULL,'KASOYA','2025-11-28 09:48:56','2025-11-28 09:48:56'),(115,'CH-00113',NULL,'JENIFFER','GACHEKE KANYUITHIA','F','2002-11-27',23,'07012600',NULL,'KASOYA','2025-11-28 09:50:23','2025-11-28 09:50:23'),(116,'CH-00114',NULL,'FAITH','MBAISI','F','1993-11-30',32,'0716329054',NULL,'KAPSOYA','2025-12-01 05:37:47','2025-12-01 05:37:47'),(117,'CH-00115',NULL,'JOSHUA','OCHUKA','M','2024-11-30',1,'0716329054',NULL,'KAPSOYA','2025-12-01 05:38:50','2025-12-01 05:38:50'),(118,'CH-00116',NULL,'DAMIAN','BELT','M','2023-11-30',2,'0791605854',NULL,'KAPSOYA','2025-12-01 05:39:48','2025-12-01 05:39:48'),(119,'CH-00117',NULL,'DAIZY','CHEKURUI','F','2003-11-30',22,'0791605854',NULL,'KAPSOYA','2025-12-01 05:40:32','2025-12-01 05:40:32'),(120,'CH-00118',NULL,'ROSE','KISUYA','F','1986-11-30',39,'0719362225',NULL,'KAPSOYA','2025-12-01 05:41:33','2025-12-01 05:41:33'),(121,'CH-00119',NULL,'FAITH','WAMUKOTA','F','2018-11-30',7,'0799412010',NULL,'KAPSOAYA','2025-12-01 05:46:11','2025-12-01 05:46:11'),(122,'CH-00120',NULL,'LUCKY','DENG','M','2024-11-30',1,'071183886',NULL,'KAPSOYA','2025-12-01 05:47:36','2025-12-01 05:47:36'),(123,'CH-00121',NULL,'FRANKLIN','KIPLAGAT','M',NULL,NULL,'0741907945',NULL,NULL,'2025-12-01 05:48:01','2025-12-01 05:48:47'),(124,'CH-00122',NULL,'FANCY','CHEPKEMBOI','F','1995-11-30',30,'071921288\\',NULL,'KAPSOYA','2025-12-01 05:51:00','2025-12-01 05:51:00'),(125,'CH-00123',NULL,'JOSPHINE','CHERUYIOT','F','1951-11-30',74,'04723406686',NULL,'KAPSOYA','2025-12-01 05:52:44','2025-12-01 05:52:44'),(126,'CH-00124',NULL,'JOSEPHINE','AWUT','F','2009-11-30',16,'0701217329',NULL,'KAPSOYA','2025-12-01 05:54:00','2025-12-01 05:54:00'),(127,'CH-00125',NULL,'BEATRICE','KOSKEI','F','1995-11-30',30,'0720249908',NULL,'KAPSOYA','2025-12-01 05:55:02','2025-12-01 05:55:02'),(128,'CH-00126',NULL,'WYCLIFE','KEMBOI','M','1983-11-30',42,'0713209044',NULL,'KASOYA','2025-12-01 05:55:53','2025-12-01 05:55:53'),(129,'CH-00127',NULL,'EMMANUEL','KIPKOSGEI','M','2001-11-30',24,'0796678547',NULL,'KAPSOYA','2025-12-01 05:57:04','2025-12-01 05:57:04'),(130,'CH-00128',NULL,'MUCHERA','SHADRACK','M','1987-11-30',38,'0111923468',NULL,'KAPSOYA','2025-12-01 05:59:37','2025-12-01 05:59:37'),(131,'CH-00129',NULL,'ANTONY','OCHIENG','M','1993-11-30',32,NULL,NULL,'KAPSOYA','2025-12-01 06:10:07','2025-12-01 06:10:07'),(132,'CH-00130',NULL,'KELVIN','KIPLAGAT','M','1996-11-30',29,'0727811291',NULL,'KAPSOYA','2025-12-01 06:10:57','2025-12-01 06:10:57'),(133,'CH-00131',NULL,'ALFONCE','CHACHA','M','2023-11-30',2,'0115535205',NULL,'KAPSOYA','2025-12-01 06:11:36','2025-12-01 06:12:18'),(134,'CH-00132',NULL,'ALISHA','CECILIA','F','2023-11-30',2,'0740306279',NULL,'KAPSOYA','2025-12-01 06:13:10','2025-12-01 06:13:10'),(135,'CH-00133',NULL,'ESTHER','ACHUNUN AMOIT','F','1996-11-30',29,'07900088451',NULL,'KAPSOYA','2025-12-01 06:13:56','2025-12-01 06:13:56'),(136,'CH-00134',NULL,'AYUEN','MALUAL','F','1989-11-30',36,NULL,NULL,'KAPSOYA','2025-12-01 06:14:46','2025-12-01 06:14:46'),(137,'CH-00135',NULL,'ZALIA','NYONGESA','F','2024-11-30',1,'0742588662',NULL,'KAPSOYA','2025-12-01 06:16:01','2025-12-01 06:16:01'),(138,'CH-00136',NULL,'ZURAEL','NYONGESA','M','2023-11-30',2,'0742588662',NULL,'KAPSOYA','2025-12-01 06:16:59','2025-12-01 06:16:59'),(139,'CH-00137',NULL,'BETH','NGANGA','F','1981-11-30',44,'0705101155',NULL,'KAPSOYA','2025-12-01 06:18:05','2025-12-01 06:18:05'),(140,'CH-00138',NULL,'WILLIAM','KIPTOO','M','1973-11-30',52,'0729581507',NULL,'KASPSOYA','2025-12-01 06:19:36','2025-12-01 06:19:36'),(141,'CH-00139',NULL,'PRICAH','CHEROTICH','F','1999-11-30',26,NULL,NULL,'KAPSOYA','2025-12-01 06:20:37','2025-12-01 06:20:37'),(142,'CH-00140',NULL,'RANSLEY','SIMOTWO','M','2021-11-30',4,'0724531438',NULL,'KAPSOYA','2025-12-01 06:21:46','2025-12-01 06:21:46'),(143,'CH-00141',NULL,'STEVE','AUSTINE OOKO','M','2009-11-30',16,'0715777954',NULL,'KIMUMU','2025-12-01 06:23:04','2025-12-01 06:23:04'),(144,'CH-00142',NULL,'KERR','DYLAN OOKO','M','2019-11-30',6,'071577954',NULL,'KIMUMU','2025-12-01 06:23:59','2025-12-01 06:23:59'),(145,'CH-00143',NULL,'DAVILLE','CRAIG OOKO','M','2012-11-30',13,'0715777954',NULL,'KIMUMU','2025-12-01 06:25:14','2025-12-01 06:25:14'),(146,'CH-00144',NULL,'EDITH','ADHIAMBO OGADA','F','1986-11-30',39,'0715777954',NULL,'KIMUMU','2025-12-01 06:25:58','2025-12-01 06:25:58'),(147,'CH-00145',NULL,'KENEDY','KIMELI','M','1993-11-30',32,'0725058367',NULL,'KAPSOYA','2025-12-01 06:26:58','2025-12-01 06:26:58'),(148,'CH-00146',NULL,'DORIS','ORWA','F','1965-11-30',60,'07214515510',NULL,'KAPPOYA','2025-12-01 06:27:59','2025-12-01 06:27:59'),(149,'CH-00147',NULL,'CRISSEL','ASHLEY SEYIAN','F','2023-11-30',2,'0754984282',NULL,'TWO RIVERS','2025-12-01 06:29:40','2025-12-01 06:29:40'),(150,'CH-00148',NULL,'CARL','ANSLEY LEYIAN','M','2023-11-30',2,'075984282',NULL,'KAPSOYA','2025-12-01 06:30:42','2025-12-01 06:30:42'),(151,'CH-00149',NULL,'BILL','ALVIN TOTONA KISHOYIAN','M','2019-11-30',6,'0754984282',NULL,'TWO RIVERS','2025-12-01 06:31:53','2025-12-01 06:31:53'),(152,'CH-00150',NULL,'CAROLINE','LONAH','F','1993-11-30',32,'0754984282',NULL,'DUKA MOJA','2025-12-01 06:34:22','2025-12-01 06:34:22'),(153,'CH-00151',NULL,'ELISHA','OLUOCH','M','2000-11-30',25,'0797288668',NULL,'DUKA MOJA','2025-12-01 06:36:32','2025-12-01 06:36:32'),(154,'CH-00152',NULL,'JANE','AMONDI ORWA','F','2010-11-30',15,'0714515510',NULL,'DUKA MOJA','2025-12-01 06:37:34','2025-12-01 06:37:34'),(155,'CH-00153',NULL,'MICAL','ACHIENG OTUNG','F','2008-11-30',17,'0714515510',NULL,'KASPSOYA','2025-12-01 06:38:47','2025-12-01 06:38:47'),(156,'CH-00154',NULL,'SHARON','ACHIENG ORWA','F','2005-11-30',20,'0714515510',NULL,'KAPSOYA','2025-12-01 06:40:12','2025-12-01 06:40:12'),(157,'CH-00155',NULL,'RESSIAN','TERRIAN TOTONA','F','2004-11-30',21,'0710376392',NULL,'DUKA MOJA','2025-12-01 06:41:11','2025-12-01 06:41:11'),(158,'CH-00156',NULL,'PHILLIP','KIPCHIRCHIR','M','1990-11-30',35,'0710376392',NULL,'KAPSOYA','2025-12-01 06:42:25','2025-12-01 06:42:25'),(159,'CH-00157',NULL,'MARK','KIPCHIRCHIR','M','1999-11-30',26,NULL,NULL,'KAPSOYA','2025-12-01 06:43:09','2025-12-01 06:43:09'),(160,'CH-00158',NULL,'VIOLA','CHEPCHUMBA KOSGEI','F','1996-11-30',29,'0729823212',NULL,'KAPSOYA','2025-12-01 06:44:04','2025-12-01 06:44:04'),(161,'CH-00159',NULL,'EVERLIN','KIRENGE WANJIKU','F','1999-11-30',26,'0796530340',NULL,'KAPSOYA','2025-12-01 06:44:59','2025-12-01 06:44:59'),(162,'CH-00160','10881380','GEORGE','NJUGI RIMUI','M','1970-11-30',55,'0728171720',NULL,'MUNYAKA','2025-12-01 08:13:25','2025-12-01 08:13:25'),(163,'CH-00161','42487313','JUDITH','CHEPKEMOI','F','2004-11-30',21,'0740067210',NULL,'ANNEX','2025-12-01 08:55:19','2025-12-01 08:55:19'),(164,'CH-00162','33831209','FIONA','JEMUTAI MAIYO','F','1997-11-30',28,'0723021807',NULL,'KAPSOYA','2025-12-01 09:00:17','2025-12-01 09:00:17'),(165,'CH-00163','44573728','HARON','KIBET RUTO','M','2005-11-30',20,'0798755963',NULL,'KAPSOYA','2025-12-01 10:29:33','2025-12-01 10:29:33'),(166,'CH-00164',NULL,'CAROLYNE','CHEMISTO JELAGAT','F','1986-11-30',39,'0724132687',NULL,'KAPSOYA','2025-12-01 10:45:14','2025-12-01 10:51:54'),(167,'CH-00165',NULL,'AWILI','KIPLAGAT ELIJAH','M','1985-11-30',40,'079115122',NULL,'KAPSOYA','2025-12-01 13:33:55','2025-12-01 13:33:55'),(168,'CH-00166','22301604','HELEN','NDUNGWA NGELA','F','1992-12-01',33,'0727023692',NULL,'KAPSOYA','2025-12-02 07:55:05','2025-12-02 07:55:05'),(169,'CH-00167',NULL,'Felix','Mutua','F','1997-12-01',28,'0707365637',NULL,'Kapsoya, Elderet','2025-12-02 10:14:31','2025-12-02 16:32:43'),(170,'CH-00168','40645886','Viola','Jebet','F','2002-12-01',23,'0710822634',NULL,'Kapsoya, Eldoret','2025-12-02 16:29:15','2025-12-02 16:29:15'),(171,'CH-00169','28631414','JOAN','KIBIWOTT','F','1992-12-02',33,'0715327490',NULL,'ASMARA','2025-12-03 06:08:32','2025-12-03 06:08:32'),(172,'CH-00170',NULL,'GIDIEON','KIMAIYO','M','1992-12-02',33,'0720235382',NULL,'ASMARA','2025-12-03 06:09:29','2025-12-03 06:09:29'),(173,'CH-00171',NULL,'THOK','RUOTHKOCH REAT','M','1991-12-02',34,'07994581255',NULL,'KAPSOYA','2025-12-03 13:27:40','2025-12-03 13:27:40'),(174,'CH-00172','33398546','JACKLINE','CHERUOTICH','F','1999-12-03',26,'0791483341',NULL,'KAPSOYA','2025-12-04 12:57:20','2025-12-04 12:57:20'),(175,'CH-00173',NULL,'Benjamin','Totona','M','1990-12-05',35,NULL,NULL,NULL,'2025-12-06 12:55:10','2025-12-06 12:55:10');
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
  PRIMARY KEY (`id`),
  KEY `payments_bill_id_payment_method_index` (`bill_id`,`payment_method`),
  CONSTRAINT `payments_bill_id_foreign` FOREIGN KEY (`bill_id`) REFERENCES `bills` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payments`
--

LOCK TABLES `payments` WRITE;
/*!40000 ALTER TABLE `payments` DISABLE KEYS */;
INSERT INTO `payments` VALUES (1,1,3.00,'Cash',NULL,'2025-11-07 08:06:04',NULL,'2025-11-07 08:06:04','2025-11-07 08:06:04'),(2,2,2.00,'Cash',NULL,'2025-11-07 08:08:12',NULL,'2025-11-07 08:08:12','2025-11-07 08:08:12'),(3,2,1.00,'Cash',NULL,'2025-11-07 09:41:34',NULL,'2025-11-07 09:41:34','2025-11-07 09:41:34'),(4,4,200.00,'Cash',NULL,'2025-11-07 10:38:08',NULL,'2025-11-07 10:38:08','2025-11-07 10:38:08'),(5,6,3.00,'Cash',NULL,'2025-11-07 10:49:10',NULL,'2025-11-07 10:49:10','2025-11-07 10:49:10'),(6,4,15.00,'Mobile Money',NULL,'2025-11-07 19:18:40',NULL,'2025-11-07 19:18:40','2025-11-07 19:18:40'),(7,9,3.00,'Cash',NULL,'2025-11-12 17:32:45',NULL,'2025-11-12 17:32:45','2025-11-12 17:32:45'),(8,12,3.00,'Cash',NULL,'2025-11-12 17:32:56',NULL,'2025-11-12 17:32:56','2025-11-12 17:32:56'),(9,4,90.00,'Cash',NULL,'2025-11-12 17:33:27',NULL,'2025-11-12 17:33:27','2025-11-12 17:33:27'),(10,14,155.50,'Card',NULL,'2025-11-13 18:45:09',NULL,'2025-11-13 18:45:09','2025-11-13 18:45:09'),(11,13,3.00,'Cash',NULL,'2025-11-13 19:26:59',NULL,'2025-11-13 19:26:59','2025-11-13 19:26:59'),(12,15,3.00,'Cash',NULL,'2025-11-13 19:27:12',NULL,'2025-11-13 19:27:12','2025-11-13 19:27:12'),(13,16,3.00,'Cash',NULL,'2025-11-14 21:15:03',NULL,'2025-11-14 21:15:03','2025-11-14 21:15:03'),(14,11,3.00,'Cash',NULL,'2025-11-17 11:49:39',NULL,'2025-11-17 11:49:39','2025-11-17 11:49:39'),(15,18,3.00,'Cash','3','2025-11-23 11:20:55',NULL,'2025-11-23 11:20:55','2025-11-23 11:20:55'),(16,53,3.00,'Cash',NULL,'2025-12-04 19:00:16',NULL,'2025-12-04 19:00:16','2025-12-04 19:00:16');
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
) ENGINE=InnoDB AUTO_INCREMENT=157 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `personal_access_tokens`
--

LOCK TABLES `personal_access_tokens` WRITE;
/*!40000 ALTER TABLE `personal_access_tokens` DISABLE KEYS */;
INSERT INTO `personal_access_tokens` VALUES (21,'App\\Models\\Staff',5,'auth_token','aec3fd9d1f899d8f8b5bec4abb5177d883c968fe36dc50c7fd8cb042525ce73a','[\"*\"]','2025-11-25 16:44:51',NULL,'2025-11-11 08:40:57','2025-11-25 16:44:51'),(91,'App\\Models\\Staff',6,'auth_token','301df98717e40ed1d00aafddb5787a663068ca12ea23e91d05d837448f660fa0','[\"*\"]','2025-11-23 19:26:02',NULL,'2025-11-23 19:16:19','2025-11-23 19:26:02'),(153,'App\\Models\\Staff',3,'auth_token','b5e614505839d7259010aa27929a4556c5a687261f662391064931f6459e3904','[\"*\"]','2025-12-04 19:18:57',NULL,'2025-12-04 19:15:33','2025-12-04 19:18:57'),(156,'App\\Models\\Staff',1,'auth_token','f78eba6beca3342568d57e039ba694e1cb142380914facf44e25b3acf062ba37','[\"*\"]','2025-12-06 12:56:44',NULL,'2025-12-06 12:53:39','2025-12-06 12:56:44');
/*!40000 ALTER TABLE `personal_access_tokens` ENABLE KEYS */;
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
  `inventory_item_id` bigint unsigned NOT NULL,
  `quantity` int NOT NULL,
  `unit_price` decimal(10,2) NOT NULL,
  `subtotal` decimal(10,2) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `prescription_items_prescription_id_foreign` (`prescription_id`),
  KEY `prescription_items_inventory_item_id_foreign` (`inventory_item_id`),
  CONSTRAINT `prescription_items_inventory_item_id_foreign` FOREIGN KEY (`inventory_item_id`) REFERENCES `inventory_items` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `prescription_items_prescription_id_foreign` FOREIGN KEY (`prescription_id`) REFERENCES `prescriptions` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `prescription_items`
--

LOCK TABLES `prescription_items` WRITE;
/*!40000 ALTER TABLE `prescription_items` DISABLE KEYS */;
INSERT INTO `prescription_items` VALUES (1,1,4,2,150.00,300.00,'2025-11-07 09:49:34','2025-11-07 09:49:34'),(2,1,3,1,1.20,1.20,'2025-11-07 09:49:34','2025-11-07 09:49:34'),(3,1,2,1,0.80,0.80,'2025-11-07 09:49:34','2025-11-07 09:49:34'),(4,2,1,1,2.50,2.50,'2025-11-07 10:37:36','2025-11-07 10:37:36'),(5,3,1,3,2.50,7.50,'2025-11-07 19:04:38','2025-11-07 19:04:38'),(6,4,4,1,150.00,150.00,'2025-11-13 18:44:28','2025-11-13 18:44:28'),(7,4,1,1,2.50,2.50,'2025-11-13 18:44:28','2025-11-13 18:44:28'),(8,5,4,7,150.00,1050.00,'2025-11-18 04:14:12','2025-11-18 04:14:12'),(9,5,1,10,2.50,25.00,'2025-11-18 04:14:12','2025-11-18 04:14:12'),(10,6,4,1,150.00,150.00,'2025-11-18 10:46:12','2025-11-18 10:46:12'),(11,7,1,2,2.50,5.00,'2025-11-23 12:57:47','2025-11-23 12:57:47'),(12,8,4,4,150.00,600.00,'2025-11-23 23:20:03','2025-11-23 23:20:03'),(13,9,4,3,150.00,450.00,'2025-12-04 14:50:36','2025-12-04 14:50:36'),(14,9,3,1,1.20,1.20,'2025-12-04 14:50:36','2025-12-04 14:50:36'),(15,10,4,1,150.00,150.00,'2025-12-04 18:59:39','2025-12-04 18:59:39'),(16,10,3,1,1.20,1.20,'2025-12-04 18:59:39','2025-12-04 18:59:39'),(17,10,1,1,2.50,2.50,'2025-12-04 18:59:39','2025-12-04 18:59:39'),(18,11,4,3,150.00,450.00,'2025-12-04 19:09:28','2025-12-04 19:09:28');
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
  `notes` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `prescriptions_patient_id_foreign` (`patient_id`),
  KEY `prescriptions_doctor_id_foreign` (`doctor_id`),
  KEY `prescriptions_treatment_id_foreign` (`treatment_id`),
  CONSTRAINT `prescriptions_doctor_id_foreign` FOREIGN KEY (`doctor_id`) REFERENCES `doctors` (`id`) ON DELETE SET NULL,
  CONSTRAINT `prescriptions_patient_id_foreign` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`id`) ON DELETE CASCADE,
  CONSTRAINT `prescriptions_treatment_id_foreign` FOREIGN KEY (`treatment_id`) REFERENCES `treatments` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `prescriptions`
--

LOCK TABLES `prescriptions` WRITE;
/*!40000 ALTER TABLE `prescriptions` DISABLE KEYS */;
INSERT INTO `prescriptions` VALUES (1,3,8,NULL,302.00,'pending','Paracetamol x2','2025-11-07 09:49:34','2025-11-07 09:49:34'),(2,3,9,NULL,2.50,'pending',NULL,'2025-11-07 10:37:36','2025-11-07 10:37:36'),(3,5,10,NULL,7.50,'pending',NULL,'2025-11-07 19:04:38','2025-11-07 19:04:38'),(4,16,18,NULL,152.50,'pending',NULL,'2025-11-13 18:44:28','2025-11-13 18:44:28'),(5,17,21,4,1075.00,'pending',NULL,'2025-11-18 04:14:12','2025-11-18 04:14:12'),(6,18,22,4,150.00,'pending',NULL,'2025-11-18 10:46:12','2025-11-18 10:46:12'),(7,50,25,3,5.00,'pending',NULL,'2025-11-23 12:57:47','2025-11-23 12:57:47'),(8,16,27,6,600.00,'pending',NULL,'2025-11-23 23:20:03','2025-11-23 23:20:03'),(9,16,27,NULL,451.20,'pending',NULL,'2025-12-04 14:50:36','2025-12-04 14:50:36'),(10,16,57,6,153.70,'pending',NULL,'2025-12-04 18:59:39','2025-12-04 18:59:39'),(11,16,57,6,450.00,'pending',NULL,'2025-12-04 19:09:28','2025-12-04 19:09:28');
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
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_status_priority_created` (`status`,`priority`,`created_at`),
  KEY `idx_patient_id` (`patient_id`),
  KEY `fk_queue_added_by` (`added_by`),
  KEY `fk_queue_attended_by` (`attended_by`),
  CONSTRAINT `fk_queue_added_by` FOREIGN KEY (`added_by`) REFERENCES `staff` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_queue_attended_by` FOREIGN KEY (`attended_by`) REFERENCES `staff` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_queue_patient` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `queue`
--

LOCK TABLES `queue` WRITE;
/*!40000 ALTER TABLE `queue` DISABLE KEYS */;
INSERT INTO `queue` VALUES (1,61,1,'completed',0,NULL,'2025-11-23 18:36:37',1,'2025-11-23 18:35:59','2025-11-23 18:43:38'),(2,60,1,'in_progress',0,NULL,'2025-11-23 18:46:35',3,'2025-11-23 18:44:23','2025-11-23 18:46:35'),(3,16,6,'completed',0,NULL,'2025-11-23 19:18:15',3,'2025-11-23 19:17:37','2025-11-23 19:18:15'),(4,80,1,'waiting',0,NULL,NULL,NULL,'2025-12-02 14:42:03','2025-12-02 14:42:03'),(5,169,1,'waiting',0,NULL,NULL,NULL,'2025-12-02 16:32:59','2025-12-02 16:32:59'),(6,16,1,'waiting',0,NULL,NULL,NULL,'2025-12-04 18:58:09','2025-12-04 18:58:09');
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
INSERT INTO `sessions` VALUES ('2G0YPenJV2HySA1ltAvXFlFcwZYVNgUZp08JH3Vf',NULL,'100.64.0.14','python-requests/2.32.3','YTozOntzOjY6Il90b2tlbiI7czo0MDoiVEtReTBoQnVSU0FmYkdkSEdnckZSM2U5ZzhMOWVIdzc3VThaelpsMiI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTE6Imh0dHA6Ly9wZXJmZWN0LW1hZ2ljLXByb2R1Y3Rpb24tZWVlOC51cC5yYWlsd2F5LmFwcCI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=',1763225352),('ESK0tnrEeTGEHepNnbAqAg8io3EnCNkgTgBlkYho',NULL,'100.64.0.2','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36','YTozOntzOjY6Il90b2tlbiI7czo0MDoiU0lXdWY4dDVoc3ZEQnpzVHFBNDdiNkpoRXViNkN5U1FhY1p5VjI1SiI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTE6Imh0dHA6Ly9wZXJmZWN0LW1hZ2ljLXByb2R1Y3Rpb24tZWVlOC51cC5yYWlsd2F5LmFwcCI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=',1762464278),('kKlveqhB1UZiS7tofCxm0mLZFyXnbMwkGYZbeGuX',NULL,'100.64.0.16','python-requests/2.32.3','YTozOntzOjY6Il90b2tlbiI7czo0MDoic1Y1M21UdGpFUFZ1bElCNU05NDRWb25nd2ZDUWswaWpxcXFKalUzdyI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTE6Imh0dHA6Ly9wZXJmZWN0LW1hZ2ljLXByb2R1Y3Rpb24tZWVlOC51cC5yYWlsd2F5LmFwcCI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=',1763225352),('sJ8oH9WZkjuOq3ld1Glhpc1BJret778eucNcHGFg',NULL,'100.64.0.13','python-requests/2.32.3','YTozOntzOjY6Il90b2tlbiI7czo0MDoieGFRTzd2MkR1YXpFS0pyOE9rUE1hTEpSemp4STFDS0lURURvMUNoZyI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTE6Imh0dHA6Ly9wZXJmZWN0LW1hZ2ljLXByb2R1Y3Rpb24tZWVlOC51cC5yYWlsd2F5LmFwcCI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=',1763225352),('SJTQFxC6lSB4wpohMIhFJpQ1HeoSnM6V9LmMLf01',NULL,'100.64.0.3','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36','YTozOntzOjY6Il90b2tlbiI7czo0MDoiNUFHMkc3ZTFjWHFqTjdXalltOWFEZE9JSW5hWHpCNWV2eWNvTjJGbyI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTE6Imh0dHA6Ly9wZXJmZWN0LW1hZ2ljLXByb2R1Y3Rpb24tZWVlOC51cC5yYWlsd2F5LmFwcCI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=',1763225201),('XSBr9idt5W0YtcTdAItwaNM40CSzKkZCuT5M0UqW',NULL,'100.64.0.15','python-requests/2.32.3','YTozOntzOjY6Il90b2tlbiI7czo0MDoiRVdBd0U4bDhHOUpYR29PYWw0WDNod2ZBVE50OHBIMXNUZmJZVGlsTCI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6NTE6Imh0dHA6Ly9wZXJmZWN0LW1hZ2ljLXByb2R1Y3Rpb24tZWVlOC51cC5yYWlsd2F5LmFwcCI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=',1763225352);
/*!40000 ALTER TABLE `sessions` ENABLE KEYS */;
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
  `role` enum('admin','doctor','reception') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'doctor',
  `password` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `staff_ch_id_unique` (`ch_id`),
  UNIQUE KEY `staff_email_unique` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `staff`
--

LOCK TABLES `staff` WRITE;
/*!40000 ALTER TABLE `staff` DISABLE KEYS */;
INSERT INTO `staff` VALUES (1,'CH-01560','System','Admin','admin@chidstal.com','0700000000','admin','$2y$12$dFSQUlvIvwyrggeJIfUpEOF.TdBYXQSimCudjqj4D610oIANaXwI2','2025-11-06 19:30:36','2025-11-07 09:40:27'),(3,'CH-86270','Doctor','Doc','collinsogada452@gmail.com','0701430850','doctor','$2y$12$DvUVK1YtpBD5U1Q3sWSVyeqEabkPcaTpaK/RKx85S27xQ9QhKZYIC','2025-11-07 15:35:07','2025-11-26 07:33:47'),(4,'CH-03182','EDWARD','ADWET','oadwet1@gmail.com','254786107425','admin','$2y$12$Gih.6l6ARYod8XL8gm/iiOxeiM24ynKmlO5gXtgAvu0aD/z1NBWkO','2025-11-11 08:08:54','2025-11-11 08:08:54'),(5,'CH-70480','MAURINE','AKINYI','maurineakinyi41@gmail.com','254713015353','doctor','$2y$12$Tei2LocZkRTu8u4dbV0Ip.gOyLHgr92aLGeIIy4djMfewjC0msdra','2025-11-11 08:11:07','2025-11-11 08:11:07'),(6,'CH-27448','Candy','Cane','candycane@gmail.com','0700011234','reception','$2y$12$xnHGTmyOkvi2sOIq3g3LbuUT.lP1Y0o5Nlh.khxkutAu3YotFJ08S','2025-11-12 15:15:15','2025-11-16 08:35:28');
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
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `suppliers`
--

LOCK TABLES `suppliers` WRITE;
/*!40000 ALTER TABLE `suppliers` DISABLE KEYS */;
INSERT INTO `suppliers` VALUES (1,'MediCare Ltd','Alice','0700-111-222','sales@medicare.test','Nairobi','pharmaceutical','2025-11-06 19:30:36','2025-11-06 19:30:36');
/*!40000 ALTER TABLE `suppliers` ENABLE KEYS */;
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
  `doctor_id` bigint unsigned DEFAULT NULL,
  `visit_date` date NOT NULL,
  `diagnosis` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('active','awaiting_billing','billed','completed') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `treatment_notes` text COLLATE utf8mb4_unicode_ci,
  `attending_doctor` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `treatments_patient_id_foreign` (`patient_id`),
  KEY `treatments_doctor_id_foreign` (`doctor_id`),
  CONSTRAINT `treatments_doctor_id_foreign` FOREIGN KEY (`doctor_id`) REFERENCES `doctors` (`id`) ON DELETE SET NULL,
  CONSTRAINT `treatments_patient_id_foreign` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=58 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `treatments`
--

LOCK TABLES `treatments` WRITE;
/*!40000 ALTER TABLE `treatments` DISABLE KEYS */;
INSERT INTO `treatments` VALUES (1,1,NULL,'2025-10-28','Common Cold','active','Prescribed rest and hydration.','Dr. Sarah','2025-11-06 19:30:36','2025-11-06 19:30:36'),(2,1,NULL,'2025-11-03','Fever','active','Advised monitoring temperature.','Dr. James','2025-11-06 19:30:36','2025-11-06 19:30:36'),(3,2,NULL,'2025-10-30','Common Cold','active','Prescribed rest and hydration.','Dr. Sarah','2025-11-06 19:30:36','2025-11-06 19:30:36'),(4,2,NULL,'2025-11-04','Fever','active','Advised monitoring temperature.','Dr. Sarah','2025-11-06 19:30:36','2025-11-06 19:30:36'),(5,3,NULL,'2025-11-07','Malaria','billed','Sick','James Otieno','2025-11-07 08:05:40','2025-11-07 08:06:04'),(6,1,2,'2025-11-10',NULL,'billed','Created from appointment on 11/10/2025, 2:00:00 PM',NULL,'2025-11-07 08:06:56','2025-11-07 09:41:34'),(7,4,NULL,'2025-11-07','Albenda','awaiting_billing','N/A','Paul Mwangi','2025-11-07 09:38:06','2025-11-07 09:38:06'),(8,3,NULL,'2025-11-07',NULL,'billed',NULL,'James Otieno','2025-11-07 09:48:18','2025-11-12 17:33:27'),(9,3,NULL,'2025-11-07','Hyperacidity','awaiting_billing',NULL,'Paul Mwangi','2025-11-07 10:37:26','2025-11-07 10:37:26'),(10,5,NULL,'2025-11-07','test','awaiting_billing',NULL,'Paul Mwangi','2025-11-07 10:48:59','2025-11-07 19:04:38'),(11,15,NULL,'2025-11-12',NULL,'awaiting_billing',NULL,NULL,'2025-11-12 10:09:16','2025-11-12 10:09:16'),(12,14,NULL,'2025-11-12','Hyperacidity','awaiting_billing','N/A','MAURINE AKINYI','2025-11-12 14:12:26','2025-11-12 14:12:26'),(13,14,4,'2025-11-12','Blood Test','billed','Iron Low',NULL,'2025-11-12 15:07:28','2025-11-12 17:32:45'),(14,14,4,'2025-11-12','Blood Test','awaiting_billing','Iron Low',NULL,'2025-11-12 15:07:28','2025-11-12 15:07:28'),(15,14,NULL,'2025-11-12','Blood 2','billed','Iron Low2',NULL,'2025-11-12 15:11:32','2025-11-17 11:49:39'),(16,15,6,'2025-11-12','test234','billed','NAA',NULL,'2025-11-12 15:20:56','2025-11-12 17:32:56'),(17,12,6,'2025-11-13','Malaria','billed','AL',NULL,'2025-11-13 18:14:32','2025-11-13 19:26:59'),(18,16,6,'2025-11-13','Headache','billed','N/AA',NULL,'2025-11-13 18:44:17','2025-11-13 18:45:09'),(19,16,6,'2025-11-13','Stomach ache','billed','N/A2',NULL,'2025-11-13 18:47:51','2025-11-13 19:27:12'),(20,16,6,'2025-11-13','Test 3','billed','n/a',NULL,'2025-11-13 19:26:29','2025-11-14 21:15:03'),(21,17,4,'2025-11-18','Hepatitis','active',NULL,'Dr. MAURINE AKINYI','2025-11-18 04:11:32','2025-11-18 04:11:32'),(22,18,4,'2025-11-18','Null','billed',NULL,'Dr. MAURINE AKINYI','2025-11-18 10:43:47','2025-11-23 11:20:55'),(23,18,4,'2025-11-18','Null','active',NULL,'Dr. MAURINE AKINYI','2025-11-18 10:43:47','2025-11-18 10:43:47'),(24,18,4,'2025-11-18','Null2','active',NULL,'Dr. MAURINE AKINYI','2025-11-18 10:44:57','2025-11-18 10:44:57'),(25,50,3,'2025-11-24',NULL,'active','Created from appointment on 11/24/2025, 3:55:00 PM','Dr. Paul Mwangi','2025-11-23 12:56:04','2025-11-23 12:56:04'),(26,59,2,'2025-11-23','Nausea','active','None','Dr. Sarah Mutua','2025-11-23 13:03:23','2025-11-23 13:03:23'),(27,16,6,'2025-11-23','QueueTest','active',NULL,'Dr. Collins Ogada','2025-11-23 19:21:48','2025-11-23 19:21:48'),(28,81,4,'2025-11-25','long standing epistaxis','active','on exam-mild blood clots in the nasal cavity.no active bleeding\nCBC-elevated lymphocytes 55 per cent,normal hgb,normal plt\npo azithromycin 500 mf od for 3 days.po cetrizine 10 mg od for 5 days.','Dr. MAURINE AKINYI','2025-11-25 11:06:22','2025-11-25 11:06:22'),(29,82,4,'2025-11-25','sepsis','active','bp120/69mmhg.PR 73/min.Temp 36.8.\nbody weakness,headache,hob,feeling cold,hypersalivation,central chest discomfort,loss of appetite .\nno history of travel.\nLNMP 04.11.2025,currently on jadelle\nBs for mps-negative\nplan-po amoxicillin 500mg tds for 5 days.po ibuprofen 400 mg tds for 3 days.\nreview on Monday if no change,possible cbc.','Dr. MAURINE AKINYI','2025-11-25 12:23:55','2025-11-25 12:23:55'),(30,67,4,'2025-11-24','hypertension/arthralgia','active','joint pains,shoulder pains,knee pains for 6 months.\nnew onset elevated blood pressure 181/102mmhg.Repeat on 25.22.25-169/104mmhg.\nurinalysis-NAD\nrbs-5.4mmol/litre\nTo repeat bp tomorrow for possible initiation of htn treatment.\nct piroxicam.','Dr. MAURINE AKINYI','2025-11-25 13:20:38','2025-11-25 13:20:38'),(31,83,4,'2025-11-25','low back pain with neuralgia','active','bp 169/98.pr 89/min.temp 36.6\nback pain for 1 month radiating to the right lower limb especially at night.headache.abdominal upsets on/off.on/off heartburn.No numbness experienced.Cannot bend to tie shoe laces.\nAn episode of heavy pv bleeding  following secondary amenorrhoea?menopausal syndrome.\npremeds-zulu mr,relaxon,pregabalin 75 mg-no change.\ngive-po secnidazole 2g start.po omeprazole 20 mg od for 5 days.po piroxicam 20 mg bd for 5 days.\nTca on 01.12.2025.If no change to plan for serum calcium levels and h pylori antigen,pelvic ultrasound.','Dr. MAURINE AKINYI','2025-11-25 14:37:47','2025-11-25 14:37:47'),(32,84,4,'2025-11-25','GERD WITH OESOPHAGITIS','active','bp106.61mmhg.pr 78/min.temp 36.5\nc.o-epigastric pain radiating to the central part of the chest also posteriorly.Left sided chest pain.malaise on/off for 6 months.\nTo plan for h pylori antigen test if persists.\ngive po omeprazole 20 mg bd for 3 days then  od for 4 days\npo pcm 1g bd for 2 days.\nTCA 01/12/25\navoid lying down/bending immediately after a meal.','Dr. MAURINE AKINYI','2025-11-25 14:53:25','2025-11-25 14:53:25'),(33,85,4,'2025-11-25','Acute tonsillitis in a known asthmatic patient','active','temp38.2 weight 19.2 kg\nc/o-chest pain,malaise,cough,headache.\nknown asthmatic not on any regular medication but several episodes of nebulisation.2 episodes of admission in the past 3 months due to asthmatic attacks.\nNo recent history of travel.\nR/S-chest clear.Inflamed tonsillar glands.\nDispense-PO amoxiclav 457 mg bd for 7 days.PO Cetirizine 7.5 mls nocte for 10 days.Susp ibuprofen 7.5 mls start the tds for 3 days.\ntca on 27/11/25','Dr. MAURINE AKINYI','2025-11-25 15:06:55','2025-11-25 15:06:55'),(34,86,4,'2025-11-25','low back pain/htn','active','BP 188/106MMHG.PR 97BTS/MIN.Repeat 171/102mmhg\nBack pain on and off.Heat sensation both ears especially when tense or when she bends.\nknown htn not sure with her medication.\nDispense-po calcigard{nifedipine} 40 mg 0d for 5 days\npo meloxicam 7.5 mg bd for 5 days.\nDaily bp recordings.','Dr. MAURINE AKINYI','2025-11-25 15:28:29','2025-11-25 15:28:29'),(35,87,4,'2025-11-25','urinary tract infection','active','BP 106/73MMHG.TEMP 36.5 DEGREES\nC/O-burning sensation on passing urine\nno associated symptoms.\ndispense-po amoxicillin 500 mg tds for 5 days.po paracetamol 1 g bd for 2days.','Dr. MAURINE AKINYI','2025-11-25 15:41:00','2025-11-25 15:41:00'),(36,97,4,'2025-11-26','? tendinitis','active','bp 104/60mmhg.pr 62/min.temp 36.6\nc/o-right shoulder pain radiating to the right side of the neck and right side of the  chest for 2 months.\npremeds-ceftriaxone 1 g start,amoxicillin for 5 days.no change\npatient is a chef-uses the right shoulder quite a lot\nno febrile feeling or associated symptoms\ndispense-po piroxicam 20 mg bd for 2 days then od for 6 days.po prednisolone 30 mg od for 1 day,then 20 mg od for 1 day,then 10 mg od for 1 day.\ntca after 5 days.Patient to consider haemogram.','Dr. MAURINE AKINYI','2025-11-26 10:59:27','2025-11-26 10:59:27'),(37,98,4,'2025-11-26','cut wound right knee','active','vitals normal\nc/o-cut wound right anterior knee following a fall while playing football with active bleeding.Also a bruise directly on the knee with no active bleeding.\nadvised on suturing-patient declined.\nclean and dress wound.IM TT 0.5 mls start.\nto buy analgesic and flucloxacillin.','Dr. MAURINE AKINYI','2025-11-26 11:25:33','2025-11-26 11:25:33'),(38,99,4,'2025-11-26','abdominal pain','active','temp 36.8\nc.o-sudden onset lower abdominal pain while taking lunch associated with dysuria and episodic rumbling abdomen.\np/a-tender periumbilical and left iliac fossa pain,also suprapubic region.\nurinalysis-ketones trace\nreassured.\nDispense tabs hyoscine 10 mg start then bd for 2 days.\ndrink lots of water.\ntca on friday.','Dr. MAURINE AKINYI','2025-11-26 12:19:55','2025-11-26 12:19:55'),(39,100,4,'2025-11-26','allergic rhinitis/sinusitis','active','temp 36.9 weight 13.9kg\nc/o;nasal blockage,sore throat,running nose on/off.\no/e;slightly inflamed tonsillar glands,not hyperemmic?physiological.\ndispense po cetrizine 5 mls nocte for 5 days.\ntca after 5 days.','Dr. MAURINE AKINYI','2025-11-26 12:33:19','2025-11-26 12:33:19'),(40,101,4,'2025-11-26','allergic rhinitis','active','vitals normal\nc.o-running nose,sneezing,sore throat for 2 days.\ndispense-po cetirizine 10mg nocte for 5 days.','Dr. MAURINE AKINYI','2025-11-26 12:37:25','2025-11-26 12:37:25'),(41,100,4,'2025-11-26','dermatitis','active','itchy skin rashes on the anterior neck.\ndispense clozole b apply bd for 7 days.','Dr. MAURINE AKINYI','2025-11-26 12:40:22','2025-11-26 12:40:22'),(42,85,4,'2025-11-27','tonsillitis review','active','review today,child doing well,afebrile.\nno new complaints.\nreassured\nct medication.','Dr. MAURINE AKINYI','2025-11-27 11:33:30','2025-11-27 11:33:30'),(43,108,4,'2025-11-27','urinary tract infection/dermatitis','active','temp 36.5 weight 20.5 kg\nc/o:Lower abdominal pain with dysuria,skin rashes\nno premedication\nurinalysis-leuc trace\ndispense:po amoxicillin 250mg tds for 5 days.po hysocine 10 mg od for 3 days.Clozole b cream spply bd for 5 days on the back.Drink lots of water.','Dr. MAURINE AKINYI','2025-11-27 12:51:58','2025-11-27 12:51:58'),(44,21,4,'2025-11-27','abdominal pain/pneumonia.','active','bp:113/60mmhg pr 66bts/min\nreview following pricking chestpain,recurring oral sores for 4 years,rash on the nasopharynx.Has been on azithromycin,cetirine,piroxicam.\nstill has pricking chestpain during cold despite completing medication above.\nNew onset abdominal pain,gassiness,heartburn.resolved constipation.\nDispense:po secnidazole 2 d start.po omeprazole 20 mg od for 5 days.po erythromycin 500mg qid for 5 days.po meloxicam 7.5 mg od for 5 days.\nIf no change-to consider h pylori antigen and chest xray','Dr. MAURINE AKINYI','2025-11-27 13:33:09','2025-11-27 13:33:09'),(45,109,4,'2025-11-27','taenia capitis/abdominal pain','active','temp 37.1 kg weight 28.6kg\nc/o:abdominal pain,headache.scalp rashes.\ndispense po metronidazole 200mg tds for 5 days,ibuprofen 200mg tds for 3 days.clozole b cream apply on scalp bd por 7 days.po griseofulvin 250 mg od for 14 days.\ntca after medication fro review.','Dr. MAURINE AKINYI','2025-11-27 14:07:01','2025-11-27 14:07:01'),(46,110,4,'2025-11-27','myalgia/tendinitis','active','Bp normal.\nJoint pain shoulders,ankles,muscle pain over the humerus.\nhas been taking care of a cva patient.\nPo acetal mr 1 bd for 5 days.\nTCA after 5 days.','Dr. MAURINE AKINYI','2025-11-27 14:38:29','2025-11-27 14:38:29'),(47,112,6,'2025-11-27','Lumbago','active','C/C\n1.Left sided hip and back pain\n2Pain on the right upper limb\n\nO/E;FGC,{JACCOLD}\nKnown HTN patient on meds\nVitals;BP;133/94mmHg\nP;81b/min\n\nRX;PO Myospaz 1 BD 5/7\nTopical diclogel apply OD 5/7','Dr. Doctor Doc','2025-11-27 18:32:31','2025-11-27 18:32:31'),(48,111,6,'2025-11-27','UTI,ALLERGIC REACTION','active','C/C\n1;P.V itchyness\n2;Skin folds itchyness\n3;PV discharge\n\n\nO/E\nFGC,{JACCOLD}\n\nLABS\nU/A;Leukocytes ++\n\nPLAN\nPO Cefalexine 500mg BD 5/7\nPO PCM 1G TDS 3/7\nPO PDL 20MG OD 3/7\nTopical hydrocort apply OD 5/7','Dr. Doctor Doc','2025-11-27 18:46:43','2025-11-27 18:46:43'),(49,162,4,'2025-01-12','Gastritis','active','bp 136/84mmhg.pr 68 bts/min.temp 36.8\nBurning sensation in the abdomen,malaise.On/off constipation.Pain worsens when he eats githeri.\npremeds:flagyl,buscopan,bisacodyl,paracetamol.\nTo plan for h pylori antigen.Initiate all dependants for test,to pay kit in cash ifpositive.\nDispense po omeprazole 20mg bd for 2 days then od for 6 days.Tabs relcergel 1 bd for 1 day.\nTca afer 5 days.','Dr. MAURINE AKINYI','2025-12-01 08:31:01','2025-12-01 08:31:01'),(50,164,4,'2025-01-12',NULL,'active','BP104/63MMHG      TEMP 37.1    PR 113/min BMI \nFeeling cold,right sided headache,joint pain,lower abdominal pain,general body pain,chills,sweating for 5 days,dusuria.\npremeds analgesics.\nno history of travel.\nUrinalysis:\nCBC:','Dr. MAURINE AKINYI','2025-12-01 09:37:25','2025-12-01 09:37:25'),(51,164,4,'2025-01-12','sepsis','active','urinalysis-proteins ++\ncbc-elevated mixed cell count 19.9.\ndispense:po cefalexin 500mg bd for 5 days.po pcm 1 g tds for 3 days\ntca after 5 days.','Dr. MAURINE AKINYI','2025-12-01 10:05:01','2025-12-01 10:05:01'),(52,165,4,'2025-01-12',NULL,'active','temp 36.6 bp 116/69mmhg pr 72/min\nfrontal headache,2 episodes of nose bleeding usually occurs when he has a aflu,current flu now resolving.\npremeds:antibiotics,antihistamines.only slight change\nfor review by an ent specialist.\ndispense po ibuprofen 400mg tds for 3 days.','Dr. MAURINE AKINYI','2025-12-01 11:25:45','2025-12-01 11:25:45'),(53,101,4,'2025-01-12','acute pharyngitis','active','persistent sore throat,running nose,constantly feels like clearing her throat.\npo cetirizine 10mg od for 5 days.po levofloxacin 500mg od for 5 days.\ntca after medication if no change.','Dr. MAURINE AKINYI','2025-12-01 11:32:17','2025-12-01 11:32:17'),(54,101,4,'2025-01-12','acute pharyngitis','active','persistent sore throat,running nose,constantly feels like clearing her throat.\npo cetirizine 10mg od for 5 days.po levofloxacin 500mg od for 5 days.\ntca after medication if no change.','Dr. MAURINE AKINYI','2025-12-01 11:32:27','2025-12-01 11:32:27'),(55,100,4,'2025-01-12','ACUTE TONSILLITIS','active','Vitals normal\nc/o:cough,painful throat,running nose.\no/e:inflamed hyperemic right tonsillar gland.\ndipense po azithromycin 5 mls od for 3 days.po albendazole 10 mls start.syrup kofgon 5 mls tds for 5 days.','Dr. MAURINE AKINYI','2025-12-01 11:38:28','2025-12-01 11:38:28'),(56,97,4,'2025-01-12','mixed dermatitis','active','vitals normal\nskin rashes-child using dads insurance\ngive trishield apply bd for 7 days.','Dr. MAURINE AKINYI','2025-12-01 13:50:43','2025-12-01 13:50:43'),(57,16,6,'2025-12-04',NULL,'billed',NULL,'Dr. Doctor Doc','2025-12-04 18:59:25','2025-12-04 19:00:16');
/*!40000 ALTER TABLE `treatments` ENABLE KEYS */;
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

-- Dump completed on 2026-01-19 14:35:05
