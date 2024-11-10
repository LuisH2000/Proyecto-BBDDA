/*
Fecha de Entrega: 15/11/2024
Comision: 5600
Grupo 13
Bases de Datos Aplicadas

Alumnos:
	- Diaz, Nicolas 41714473
	- Huang, Luis 43098142

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

/*
use master 
go
drop database Com5600G13
*/

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

if not exists (select * from sys.schemas where name = 'clientes')
begin
	exec('create schema clientes')
end
go


if not exists (select * from sys.schemas where name = 'comprobantes')
begin
	exec('create schema comprobantes')
end
go

if not exists (select * from sys.schemas where name = 'sucursales')
begin
	exec('create schema sucursales')
end
go

if not exists (select * from sys.schemas where name = 'importar')
begin
	exec('create schema importar')
end
go

if not exists (select * from sys.schemas where name = 'reportes')
begin
	exec('create schema reportes')
end
go

if not exists (select * from information_schema.tables where
	table_schema = 'sucursales' and table_name = 'Sucursal')
begin
	create table sucursales.Sucursal
	(
		id int identity (1,1) primary key,
		ciudad varchar(20),
		direccion varchar(100),
		horario varchar(50),
		telefono char(9),
		activo bit default 1
		constraint unique_sucursal UNIQUE (ciudad, direccion)
	)
end
go

if not exists (select * from information_schema.tables where
	table_schema = 'catalogo' and table_name = 'LineaProducto')
begin
	create table catalogo.LineaProducto
	(
		id int identity(1,1) primary key,
		lineaProd varchar(10),
	)
end
go

if not exists (select * from information_schema.tables where
	table_schema = 'catalogo' and table_name = 'Producto')
begin
	create table catalogo.Producto
	(
		id int identity(1,1) primary key,
		idProd int,
		nombre varchar(100),
		precio decimal(9,2),
		precioUSD decimal(9,2),
		precioRef decimal(9,2),
		unidadRef varchar(10),
		fecha smalldatetime,
		proveedor varchar(50),
		cantXUn varchar(20),
		activo int default 1,
		constraint unique_producto unique(idProd, nombre, precio, precioUSD)
	)
end

if not exists (select * from information_schema.tables where
	table_schema = 'catalogo' and table_name = 'Categoria')
begin
	create table catalogo.Categoria
	(
		id int identity(1,1) primary key,
		categoria varchar(50) unique,
		idLineaProd int,
		constraint FK_LineaProd foreign key (idLineaProd) references catalogo.LineaProducto(id)
	)
end

if not exists (select * from information_schema.tables where
	table_schema = 'catalogo' and table_name = 'PerteneceA')
begin
	create table catalogo.PerteneceA
	(
		id int identity(1,1) primary key,
		idCategoria int,
		idProd int,
		constraint FK_Categoria foreign key (idCategoria) references catalogo.Categoria(id),
		constraint FK_Producto foreign key (idProd) references catalogo.Producto(id)
	)
end

if not exists (select * from information_schema.tables where
	table_schema = 'recursosHumanos' and table_name = 'Cargo')
begin
	create table recursosHumanos.Cargo
	(
		id int identity(1,1) primary key,
		cargo varchar(20) unique
	)
end

if not exists (select * from information_schema.tables where
	table_schema = 'recursosHumanos' and table_name = 'Empleado')
begin
	create table recursosHumanos.Empleado
	(
		legajo int primary key,
		nombre varchar(50),
		apellido varchar(50),
		dni int unique,
		direccion varchar(100),
		emailPer varchar(60) unique,
		emailEmp varchar(60) unique,
		cuil char(13),
		cargo int,
		idSucursal int,
		turno varchar(20) check(turno in ('TM', 'TT', 'Jornada Completa')),
		activo bit default 1,
		constraint FK_Cargo foreign key (cargo) references recursosHumanos.Cargo(id),
		constraint FK_Surcursal foreign key (idSucursal) references sucursales.Sucursal(id)
	)
end
go

if not exists (select * from information_schema.tables where
	table_schema = 'clientes' and table_name = 'TipoCliente')
begin
	create table clientes.TipoCliente
	(
		id int identity(1,1) primary key,
		tipo char(6) unique
	)
end

if not exists (select * from information_schema.tables where
	table_schema = 'clientes' and table_name = 'Cliente')
begin
	create table clientes.Cliente
	(
		id int identity(1,1) primary key,
		idTipo int,
		nombre varchar(50),
		apellido varchar(50),
		ciudad varchar(20),
		genero char(6) check(genero in ('Male', 'Female')),
		activo bit default 1,
		constraint FK_TipoCliente foreign key (idTipo) references clientes.TipoCliente(id)
	)
end

if not exists (select * from information_schema.tables where
	table_schema = 'ventas' and table_name = 'Factura')
begin
	create table ventas.Factura
	(
		id int identity(1,1) primary key,
		idFactura char(11) unique,
		tipoFactura char(1) check(tipoFactura in ('A', 'B', 'C')),
		fecha date,
		hora time,
		empleadoLeg int,
		idCliente int,
		estado char(6) default 'Impaga' check(estado in ('Pagada', 'Impaga')),
		constraint FK_Empleado foreign key (empleadoLeg) references recursosHumanos.Empleado(legajo),
		constraint FK_Cliente foreign key (idCliente) references clientes.Cliente(id)
	)
end
go

if not exists (select * from information_schema.tables where
	table_schema = 'ventas' and table_name = 'LineaDeFactura')
begin
	create table ventas.LineaDeFactura
	(
		id int identity(1,1) primary key,
		idFactura int,
		idProd int,
		precioUn decimal(15,2),
		cantidad int,
		subtotal decimal(15,2),
		constraint FK_Factura foreign key (idFactura) references ventas.Factura(id),
		constraint FK_Prod foreign key (idProd) references catalogo.Producto(id)
	)
end

if not exists (select * from information_schema.tables where
	table_schema = 'comprobantes' and table_name = 'MedioDePago')
begin
	create table comprobantes.MedioDePago
	(
		id int identity(1,1) primary key,
		nombreIng varchar(11) unique,
		nombreEsp varchar(22) unique,
		activo bit default 1
	)
end
go

if not exists (select * from information_schema.tables where
	table_schema = 'comprobantes' and table_name = 'Comprobante')
begin
	create table comprobantes.Comprobante
	(
		id int identity(1,1) primary key,
		tipoComprobante varchar(15) check(tipoComprobante in ('Factura', 'Nota de Credito')),
		idPago char(23),
		idMedPago int,
		idFactura int,
		fecha date,
		hora time,
		monto decimal(15,2),
		constraint FK_MedPago foreign key (idMedPago) references comprobantes.MedioDePago(id),
		constraint FK_Comprobante_Factura foreign key (idFactura) references ventas.Factura(id)
	)
end
go

