CREATE DATABASE FacturasDeVentas
USE FacturasDeVentas
GO

CREATE TABLE FormaPago
(idFormaP varchar(4) primary key,
descripcion varchar(20) NOT NULL  constraint CHK_descripcionFP CHECK (descripcion IN ('Contado','Tarjeta Crédito','Tarjeta Débido') )/*contado, tarjeta*/ 
GO

CREATE TABLE Cliente
(idCliente varchar(20) primary key,
numId varchar(20) NOT NULL, --NIT O CC
nombre varchar(20) NOT NULL,
tlf varchar(13),
direccion varchar(15),
correo varchar(20))
GO

CREATE TABLE MonedaTransac
(idMoneda varchar(20) primary key,
moneda varchar(40) NOT NULL)
GO


CREATE TABLE CentroRespon
(idCentro varchar(20) primary key,
nombre varchar(40) NOT NULL)
GO

CREATE TABLE Negocio
(idNegocio varchar(20) primary key,
nombre varchar(40) NOT NULL,
idCentro varchar(20) NOT NULL,
direccion varchar(40))
GO

CREATE TABLE Vendedor
(idVendedor varchar(20) primary key,
 varchar(40) NOT NULL)
GO


CREATE TABLE Factura
(idFactura varchar(20) primary key,--consecutivo
idCliente varchar(20),
Prefijo varchar(4),
Nro varchar(4),
Fecha varchar(20),--dudas con las fechas
idFormaP varchar(4),
FechaVen varchar(20),
idMoneda varchar(20),
idCentro)
GO