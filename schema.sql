CREATE DATABASE IF NOT EXISTS company;

USE company;

CREATE TABLE employee(

id INT AUTO_INCREMENT PRIMARY KEY,

name VARCHAR(100),

salary DECIMAL(10,2)

);

INSERT INTO employee(name,salary)

VALUES

('John',50000),

('David',60000);