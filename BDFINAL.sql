CREATE DATABASE Facturas
USE FacturasDeVentas
GO

CREATE TABLE FormaPago
(idFormaP varchar(4) primary key,
descripcion varchar(20) NOT NULL  constraint CHK_descripcionFP CHECK (descripcion IN ('Contado','Tarjeta Crédito','Tarjeta Débido'))) 
GO

CREATE TABLE Cliente
(idCliente varchar(20) primary key,
numId varchar(20) NOT NULL, --NIT O CC
nombre varchar(20) NOT NULL,
tlf varchar(13) CONSTRAINT DF_tlfCliente DEFAULT '57',
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
idCentro varchar(20) NOT NULL constraint FK_cenNeg FOREIGN KEY(idCentro) references CentroRespon(idCentro),
direccion varchar(40))
GO

CREATE TABLE Vendedor
(idVendedor varchar(20) primary key,
numId varchar(20) NOT NULL, --NIT O CC
nombre varchar(20) NOT NULL,
tlf varchar(13) CONSTRAINT DF_tlfVen DEFAULT '57',
direccion varchar(15),
correo varchar(20),
idNegocio varchar(20) constraint FK_negVen FOREIGN KEY(idNegocio) references Negocio(idNegocio),
idCentro varchar(20) constraint FK_cenVen FOREIGN KEY(idCentro) references CentroRespon(idCentro))
GO


CREATE TABLE Factura
(idFactura varchar(20) primary key,--consecutivo
idCliente varchar(20) NOT NULL,
prefijo varchar(4) NOT NULL,
nroFactura varchar(4) NOT NULL,
fecha varchar(20) NOT NULL,--dudas con las fechas
idFormaP varchar(4) NOT NULL constraint FK_fpFactura FOREIGN KEY(idFormaP) references FormaPago(idFormaP),
fechaVen varchar(20) NOT NULL,
idMoneda varchar(20) NOT NULL constraint FK_monedaFactura FOREIGN KEY(idMoneda) references MonedaTransac(idMoneda) ,
idCentro varchar(20) NOT NULL constraint FK_centroResponFac FOREIGN KEY(idCentro) references CentroRespon(idCentro),
iva decimal NOT NULL,
total decimal NOT NULL,
comentario text)
GO

CREATE TABLE TipoDocR
(idTipoDoc varchar(4) primary key,
descripcion varchar(50) NOT NULL  constraint CHK_descripcionDoc CHECK (descripcion IN ('Orden de entrega (Remisión)','Despacho','Orden de compra', 'Recepción')))
GO

--TABLA ASOCIATIVA ENTRE FACTURA Y TIPODOC
CREATE TABLE DocumentoRef
(idDocumentoRef varchar(20) primary key,
fecha date NOT NULL,
comentario text,
idFactura varchar(20) NOT NULL constraint FK_facDoc FOREIGN KEY(idFactura) references Factura(idFactura),
idTipoDoc varchar(4) NOT NULL constraint FK_centroRespon FOREIGN KEY(idTipoDoc) references TipoDocR(idTipoDoc))
GO

CREATE TABLE CodMedidas
(IdCodMed varchar(4) primary key,
Nombre varchar(20) NOT NULL  constraint CHK_nombreMed CHECK (Nombre IN ('Unidad','Kilo','Gramos', 'Libras')))
GO

CREATE TABLE Productos
(idItemProd varchar(20) primary key,
descripcion varchar(50) NOT NULL UNIQUE,
idCodMed varchar(4) NOT NULL constraint FK_medProd FOREIGN KEY(idCodMed) references CodMedidas(idCodMed),
precio decimal NOT NULL)
GO

CREATE TABLE Impuestos--creo que no deberiamos colocarlo
(idImpuesto varchar(20) primary key,
descripcion text)
GO

CREATE TABLE Descuentos
(idDescuento varchar(4) primary key,
descripcion text NOT NULL,
valor decimal)
GO

CREATE TABLE DetallesFactura
(idDetalles varchar(20),
idItemProd varchar(20) constraint FK_prodDetalles FOREIGN KEY(idItemProd) references Productos(idItemProd),
idFactura varchar(20) constraint FK_facDetalles FOREIGN KEY(idFactura) references Factura(idFactura),
idImpuesto varchar(20) constraint FK_impDetalles FOREIGN KEY(idImpuesto) references Impuestos(idImpuesto),
IdDescuento varchar(4) constraint FK_descDetalles FOREIGN KEY(IdDescuento) references Descuentos(IdDescuento))
GO


