CREATE DATABASE Facturas
GO
USE Facturas
GO

CREATE TABLE FormaPago
(idFormaP varchar(4) primary key,
descripcion text NOT NULL)
GO

CREATE TABLE Cliente
(idCliente varchar(20) primary key,
numId varchar(20) NOT NULL, --NIT O CC
nombre varchar(20) NOT NULL,
tlf varchar(13) CONSTRAINT DF_tlfCliente DEFAULT '57',
direccion varchar(100),
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
idCliente varchar(20) NOT NULL CONSTRAINT FK_clienteFactura FOREIGN KEY (idCliente) REFERENCES Cliente(idCliente),
prefijo varchar(4) NOT NULL,
nroFactura varchar(4) NOT NULL,
fecha varchar(20) NOT NULL,--dudas con las fechas
idFormaP varchar(4) NOT NULL constraint FK_fpFactura FOREIGN KEY(idFormaP) references FormaPago(idFormaP),
fechaVen varchar(20) NOT NULL,
idMoneda varchar(20) NOT NULL constraint FK_monedaFactura FOREIGN KEY(idMoneda) references MonedaTransac(idMoneda) ,
idCentro varchar(20) NOT NULL constraint FK_centroResponFac FOREIGN KEY(idCentro) references CentroRespon(idCentro),
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

CREATE TABLE Impuestos
(idImpuesto varchar(20) primary key,
valor decimal)
GO

CREATE TABLE Productos
(idItemProd varchar(20) primary key,
descripcion varchar(50) NOT NULL UNIQUE,
idCodMed varchar(4) NOT NULL constraint FK_medProd FOREIGN KEY(idCodMed) references CodMedidas(idCodMed),
precio decimal NOT NULL,
idImpuesto VARCHAR(20) NOT NULL CONSTRAINT FK_impuestoProd FOREIGN KEY(idImpuesto) REFERENCES Impuestos(idImpuesto))
GO

CREATE TABLE Descuentos
(idDescuento varchar(4) primary key,
valor decimal)
GO

CREATE TABLE DetallesFactura
(idDetalles varchar(20),
idItemProd varchar(20) constraint FK_prodDetalles FOREIGN KEY(idItemProd) references Productos(idItemProd),
cantidad int,
idFactura varchar(20) constraint FK_facDetalles FOREIGN KEY(idFactura) references Factura(idFactura),
IdDescuento varchar(4) constraint FK_descDetalles FOREIGN KEY(IdDescuento) references Descuentos(IdDescuento),
total decimal NOT NULL) --procedure
GO

--TRIGGER PARA VALIDAR SI UNA FACTURA EXISTE
CREATE OR ALTER TRIGGER TG_validarFactura
ON Factura
FOR INSERT
AS
IF (SELECT COUNT(1) FROM inserted AS i
	INNER JOIN Factura AS f ON f.idFactura = i.idFactura
	WHERE f.prefijo = i.prefijo AND f.nroFactura = i.nroFactura) > 1
BEGIN 
	RAISERROR('ESTA FACTURA YA EXISTE', 16, 16)
END
GO

--TRIGER PARA IMPEDIR ALTERACION DE FACTURAS
CREATE OR ALTER TRIGGER TG_alterarFactura
ON Factura
FOR UPDATE, DELETE
AS
IF EXISTS(SELECT 1 FROM inserted) AND EXISTS(SELECT 1 FROM deleted)
	RAISERROR('NO DEBES MODIFICAR FACTURAS', 16, 16)
IF NOT EXISTS(SELECT 1 FROM inserted) AND EXISTS(SELECT 1 FROM deleted)
	RAISERROR('NO DEBES ELIMINAR FACTURAS', 16, 16)
GO

--PROCEDIMIENTO PARA INSERTAR ENCABEZADO DE FACTURA
CREATE OR ALTER PROCEDURE SP_crearFactura(	
@id VARCHAR(20),
@idCliente VARCHAR(20),
@prefijo VARCHAR(4),
@nroFactura VARCHAR(4),
@fecha VARCHAR(20),
@formaPago VARCHAR(4),
@vencimiento VARCHAR(20),
@moneda VARCHAR(20),
@centro VARCHAR(20),
@comentario TEXT)
AS
BEGIN 
	BEGIN TRY
		BEGIN TRANSACTION TRANS_Fac
			INSERT INTO Factura VALUES (@id, @idCliente, @prefijo, @nroFactura, @fecha, @formaPago, @vencimiento,@moneda, @centro, @comentario)
		COMMIT TRANSACTION TRANS_Fac
	END TRY
	BEGIN CATCH 
		ROLLBACK TRANSACTION TRANS_Fac
		RAISERROR('SE PRESENTÓ UN ERROR EN LA INSERCIÓN DE LA FACTURA',16,16)
	END CATCH
END
GO

--PROCEDIMIENTO PARA INSERTAR DETALLE DE FACTURA
CREATE OR ALTER PROCEDURE SP_crearDetalleFac(
@id VARCHAR(20),
@idProd VARCHAR(20),
@cant int,
@idFac VARCHAR(20),
@idDes VARCHAR(4),
@total DECIMAL output)
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION TRANS
			INSERT INTO DetallesFactura VALUES 
			(@id, @idProd, @cant, @idFac, @idDes)
			SELECT @total = SUM((@cant*pp.precio)-des.valor+im.valor)
			FROM DetallesFactura AS df
			INNER JOIN Productos AS pp
			ON df.idItemProd = pp.idItemProd
			INNER JOIN Descuentos AS des
			ON des.idDescuento = df.IdDescuento
			INNER JOIN Impuestos AS im
			ON im.idImpuesto = pp.idImpuesto

		COMMIT TRANSACTION TRANS
	END TRY
	BEGIN CATCH 
		ROLLBACK TRANSACTION TRANS
		RAISERROR('SE PRESENTÓ UN ERROR EN LA INSERCIÓN DEL DETALLE',16,16)
	END CATCH
END
GO


--CREACION DE USUARIOS
CREATE LOGIN admin WITH PASSWORD = '123'
CREATE LOGIN consultor WITH PASSWORD = '123'

CREATE USER juana FOR LOGIN admin
CREATE USER cristian FOR LOGIN consultor

GRANT CONTROL ON DATABASE::Facturas TO juana /*no estoy seguro*/
GRANT SELECT ON DATABASE::Facturas TO cristian

INSERT INTO CodMedidas VALUES
('001', 'Unidad'),
('002', 'Kilo'),
('003', 'Gramos'),
('004', 'Libras')
GO

INSERT INTO Impuestos VALUES
('iva19', 0.19),
('iva16', 0.16),
('iva5', 0.5),
('exento', 1)
GO

INSERT INTO Descuentos VALUES
('ds5', 0.5),
('ds10', 0.10)
GO

INSERT INTO TipoDocR VALUES
('001', 'Orden de entrega (Remisión)'),
('002', 'Despacho'),
('003', 'Orden de compra'),
('004', 'Recepción')
GO

INSERT INTO MonedaTransac VALUES
('COP', 'Pesos colombianos'),
('USD', 'Dólares americanos'),
('EUR', 'Euros')
GO

INSERT INTO FormaPago VALUES
('001', 'Contado'),
('002', 'Credito Total Credito'),
('003', 'Credito 15 Días')
GO

INSERT INTO CentroRespon VALUES
('617', 'Texart'),
('8081', 'Index')
GO

INSERT INTO Cliente VALUES
('001', '489071324', 'Cris', '10201357', 'Prado', 'cris@correo.com'),
('002', '1029123849', 'Juana', '84932180', 'Barrio Antioquia', 'juana@correo.com')
GO

INSERT INTO Productos VALUES
('001', 'Pasta', '002', '30000', 'iva19'),
('002', 'Platano', '001', '1000', 'iva19')
GO

EXEC SP_crearFactura '001', '001', 'A', '01', '2/11/2022', '001', '2/12/2022', 'COP', '617', 'nada que comentar mi fai'
GO

SELECT * FROM Factura