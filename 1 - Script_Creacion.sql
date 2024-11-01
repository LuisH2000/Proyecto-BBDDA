/*
Fecha de Entrega: --/--/----
Comision: 5600
Grupo 13
Bases de Datos Aplicadas

Alumnos:
	- Diaz, Nicolas 41714473
	- Huang, Luis 43098142
	- Rolleri Vilalba, Santino 46026386

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

if not exists (select * from information_schema.tables where
	table_schema = 'catalogo' and table_name = 'Sucursal')
begin
	create table catalogo.Sucursal
	(
		id int identity (1,1) primary key,
		sucursal varchar(20) unique,
		direccion varchar(100) unique,
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
		constraint unique_producto unique(idProd, nombre, precio)
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
		sucursal varchar(20),
		turno varchar(20) check(turno in ('TM', 'TT', 'Jornada Completa')),
		activo int default 1,
		constraint FK_Cargo foreign key (cargo) references recursosHumanos.Cargo(id),
		constraint FK_Surcursal foreign key (sucursal) references catalogo.Sucursal(sucursal)
	)
end
go

if not exists (select * from information_schema.tables where
	table_schema = 'ventas' and table_name = 'MedioDePago')
begin
	create table ventas.MedioDePago
	(
		id int identity(1,1) primary key,
		nombreIng varchar(11) unique,
		nombreEsp varchar(22) unique
	)
end
go

if not exists (select * from information_schema.tables where
	table_schema = 'ventas' and table_name = 'TipoCliente')
begin
	create table ventas.TipoCliente
	(
		id int identity(1,1) primary key,
		tipo char(6) unique
	)
end

if not exists (select * from information_schema.tables where
	table_schema = 'ventas' and table_name = 'Venta')
begin
	create table ventas.Venta
	(
		id int identity(1,1) primary key,
		idFactura char(11) unique,
		tipoFactura char(1) check(tipoFactura in ('A', 'B', 'C')),
		ciudadCliente varchar(20),
		tipoCliente char(6),
		genero char(6) check(genero in ('Male', 'Female')),
		idProd int,
		precioUn decimal(6,2),
		cantidad int,
		fecha date,
		hora time,
		medioPago int,
		empleadoLeg int,
		idPago char(23),
		
		constraint FK_Prod foreign key (idProd) references catalogo.Producto(id),
		constraint FK_MedPago foreign key (medioPago) references ventas.MedioDePago(id),
		constraint FK_Empleado foreign key (empleadoLeg) references recursosHumanos.Empleado(legajo),
		constraint FK_Cliente foreign key (tipoCliente) references ventas.TipoCliente(tipo)
	)
end
go

/*
	crear sp para insertar ventas (verificar que tipo de producto es, si es electronico llamar al sp del dolar) y productos (tener en cuenta agregar el registro a la pertenece a)
	crear sp para update producto, empleado(dar de baja)
	crear sp para delete producto y empleado (dar de baja)

	crear sp para crear una nota de credito

	preguntas por los id de pago para hacer la nota de credito, verificar los id con un check
	preguntar donde meter las notas de credito
*/

if not exists (
    select 1 
    from sys.indexes 
    where name = 'IX_FacturaID' AND object_id = object_id('ventas.Venta')
)
begin
    create index IX_FacturaID on ventas.Venta (idFactura);
end