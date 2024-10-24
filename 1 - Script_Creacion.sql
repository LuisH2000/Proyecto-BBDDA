/*
Fecha de Entrega: 
Comision: 5600
Grupo 13
Bases de Datos Aplicadas

Alumnos:
	-
	-
	-

**ENUNCIADO**
Luego de decidirse por un motor de base de datos relacional, llegó el momento de generar la 
base de datos. 
Deberá instalar el DMBS y documentar el proceso. No incluya capturas de pantalla. Detalle 
las configuraciones aplicadas (ubicación de archivos, memoria asignada, seguridad, puertos, 
etc.) en un documento como el que le entregaría al DBA. 
Cree la base de datos, entidades y relaciones. Incluya restricciones y claves. Deberá entregar 
un archivo .sql con el script completo de creación (debe funcionar si se lo ejecuta “tal cual” es 
entregado). Incluya comentarios para indicar qué hace cada módulo de código.  
Genere store procedures para manejar la inserción, modificado, borrado (si corresponde, 
también debe decidir si determinadas entidades solo admitirán borrado lógico) de cada tabla. 
Los nombres de los store procedures NO deben comenzar con “SP”.  
Genere esquemas para organizar de forma lógica los componentes del sistema y aplique esto 
en la creación de objetos. NO use el esquema “dbo”.  
*/

use master 
go

--drop database Com5600G13

if not exists (select name from master.dbo.sysdatabases where name = 'Com5600G13')
begin
	create database Com5600G13
end
go

use Com5600G13
go

if not exists (select * from sys.schemas where name = 'ventas')
begin
	exec('create schema ventas')
end
go

if not exists (select * from sys.schemas where name = 'recursosHumanos')
begin
	exec('create schema recursosHumanos')
end
go

if not exists (select * from sys.schemas where name = 'catalogo')
begin
	exec('create schema catalogo')
end
go

if not exists (select * from information_schema.tables where
	table_schema = 'catalogo' and table_name = 'Sucursal')
begin
	create table catalogo.Sucursal
	(
		id int identity (1,1) primary key,
		ciudad varchar(20),
		nombre varchar(20),
		direccion varchar(100),
		horario varchar(50),
		telefono char(9)
	)
end
go

if not exists (select * from information_schema.tables where
	table_schema = 'catalogo' and table_name = 'LineaProducto')
begin
	create table catalogo.LineaProducto
	(
		id int identity(1,1),
		lineaProd varchar(10),
		producto varchar(50)
	)
end
go

if not exists (select * from information_schema.tables where
	table_schema = 'catalogo' and table_name = 'Nacional')
begin
	create table catalogo.Nacional
	(
		id int primary key,
		categoria varchar(50),
		nombre varchar(100),
		precio decimal(9,2),
		precioRef decimal(9,2),
		unidadRef varchar(10),
		fecha smalldatetime
	)
end
go

if not exists (select * from information_schema.tables where
	table_schema = 'catalogo' and table_name = 'Importado')
begin
	create table catalogo.Importado
	(
		id int primary key,
		nombre varchar(50),
		proveedor varchar(50),
		categoria varchar(20),
		cantidad varchar(20),
		precio decimal(9,2)
	)
end
go

if not exists (select * from information_schema.tables where
	table_schema = 'catalogo' and table_name = 'Electronico')
begin
	create table catalogo.Electronico
	(
		id int identity(1,1) primary key,
		nombre varchar(50),
		precio decimal(9,2)
	)
end
go

if not exists (select * from information_schema.tables where
	table_schema = 'recursosHumanos' and table_name = 'Empleado')
begin
	create table recursosHumanos.Empleado
	(
		legajo int primary key,
		nombre varchar(50),
		apellido varchar(50),
		dni int,
		direccion varchar(100),
		emailPer varchar(60),
		emailEmp varchar(60),
		cuil char(13),
		cargo varchar(20),
		sucursal varchar(20),
		turno varchar(20)
	)
end
go

if not exists (select * from information_schema.tables where
	table_schema = 'ventas' and table_name = 'MedioDePago')
begin
	create table ventas.MedioDePago
	(
		id int identity(1,1) primary key,
		nombreIng varchar(11),
		nombreEsp varchar(22)
	)
end
go

if not exists (select * from information_schema.tables where
	table_schema = 'ventas' and table_name = 'Factura')
begin
	create table ventas.Factura
	(
		idFactura char(11),
		tipo char(1),
		ciudad varchar(20),
		tipoCliente char(6),
		genero char(6),
		nomProd varchar(100),
		precioUn decimal(6,2),
		cantidad int,
		fecha date,
		hora time,
		medioPago char(11),
		empleado int,
		idPago char(23),
	)
end
go