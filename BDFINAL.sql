CREATE DATABASE FacturasDeVentas
USE FacturasDeVentas
GO

CREATE TABLE Factura
(idFactura varchar(20) primary key,
consecutivo varchar(20))
GO

CREATE TABLE FormaPago
(idFactura varchar(4) primary key,
formaPago varchar(15) NOT NULL)/*contado, tarjeta*/ 
GO

CREATE TABLE Cliente
(idCliente varchar(20) primary key,
numId varchar(20) NOT NULL, --NIT O CC
nombre varchar(20) NOT NULL,
apellido varchar(20) NOT NULL,
tlf varchar(13)
direccion varchar(15),
correo varchar(20))
GO

CREATE TABLE Prefijo
(idPrefijo varchar(4) primary key,
nombre varchar(15) NOT NULL)/*contado, tarjeta*/ 
GO

CREATE TABLE NroFactura

CREATE TABLE Fecha
(idfecha varchar(20) primary key,
fecha datetime NOT NULL)

CREATE TABLE FechaVencimiento
(idfechaVen varchar(20) primary key,
fechaVen datetime NOT NULL)

CREATE TABLE MonedaTransac

CREATE TABLE CentroRespon

CREATE TABLE Negocio

CREATE TABLE Vendedor

