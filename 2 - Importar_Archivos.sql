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
Se proveen los archivos en el TP_integrador_Archivos.zip 
Ver archivo “Datasets para importar” en Miel. 
Se requiere que importe toda la información antes mencionada a la base de datos: 
• Genere los objetos necesarios (store procedures, funciones, etc.) para importar los 
archivos antes mencionados. Tenga en cuenta que cada mes se recibirán archivos de 
novedades con la misma estructura, pero datos nuevos para agregar a cada maestro.  
• Considere este comportamiento al generar el código. Debe admitir la importación de 
novedades periódicamente. 
• Cada maestro debe importarse con un SP distinto. No se aceptarán scripts que 
realicen tareas por fuera de un SP. 
• La estructura/esquema de las tablas a generar será decisión suya. Puede que deba 
realizar procesos de transformación sobre los maestros recibidos para adaptarlos a la 
estructura requerida.  
• Los archivos CSV/JSON no deben modificarse. En caso de que haya datos mal 
cargados, incompletos, erróneos, etc., deberá contemplarlo y realizar las correcciones 
en el fuente SQL. (Sería una excepción si el archivo está malformado y no es posible 
interpretarlo como JSON o CSV).  


*/

--use master
use Com5600G13
go

if not exists (select * from sys.schemas where name = 'importar')
begin
	exec('create schema importar')
end
go

if not exists (select * from information_schema.tables where
	table_schema = 'importar' and table_name = 'Direccion')
begin
	create table importar.Direccion
	(
		dir varchar(200)
	)
	insert into importar.Direccion values ('D:\OneDrive\Documents\SQL Server Management Studio\BDA\TP\TP_integrador_Archivos')
end
go

create or alter proc importar.importarVentas
as
begin
	create table #temporal
	(
		idFactura char(11),
		tipo char(1),
		ciudad varchar(20),
		tipoCliente char(6),
		genero char(6),
		nomProd varchar(100),
		precioUn decimal(6,2),
		cantidad int,
		fecha char(10),
		hora time,
		medioPago char(11),
		empleado int,
		idPago char(23)
	)

	declare @dir varchar(200)
	select @dir = dir + '\Ventas_registradas.csv'
	from importar.Direccion

	declare @sql nvarchar(MAX)
	set @sql = 'BULK INSERT #temporal
             FROM ''' + @dir + '''
             WITH (
                 FIELDTERMINATOR = '';'',  -- Delimitador de campos
                 ROWTERMINATOR = ''\n'',   -- Delimitador de filas
                 FIRSTROW = 2,              -- Si el archivo tiene encabezados
				 FORMAT = ''CSV'',
				 CODEPAGE = ''65001''
             );';

	exec sp_executesql @sql

	insert into ventas.Factura(idFactura, tipo, ciudad, tipoCliente, genero, nomProd, precioUn, cantidad, fecha, hora, medioPago, empleado, idPago)
	select idFactura, tipo, ciudad, tipoCliente, genero, nomProd, precioUn, cantidad, 
		convert(date, Fecha, 101) as Fecha,   -- Convertir de mm/dd/yyyy a DATE
		hora, medioPago, empleado, idPago
	from #temporal

	drop table #temporal
end
go

create or alter proc importar.reemplazarCaracteres
as
begin
	update ventas.Factura
	set nomProd = replace(replace(replace(replace(replace(replace(replace(replace(replace(nomProd, 'Ã±', 'ñ'), 'Ã³', 'ó'), 'Ã©', 'é'), 'Ã¡', 'á'), 'Ãº', 'ú'), 'Ã­', 'í'), 'ÃƒÂº', 'ú'), 'Ã‘', 'Ñ') , 'Ã', 'Á')
end
go

create or alter proc importar.configurarImportacionArchivosExcel
as
begin
	exec sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1
	exec sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1
	exec sp_configure 'show advanced options', 1
	reconfigure
	exec sp_configure 'Ad Hoc Distributed Queries', 1
	reconfigure
end
go

create or alter proc importar.importarSucursal
as
begin
	declare @dir varchar(200)
	select @dir = dir + '\Informacion_complementaria.xlsx'
	from importar.Direccion

	declare @sql nvarchar(MAX)
	set @sql = 'insert into catalogo.Sucursal
				select *
				from openrowset(''Microsoft.ACE.OLEDB.12.0'',
				''Excel 12.0; Database=' + @dir + ''', [sucursal$])';
	exec sp_executesql @sql
end
go

create or alter proc importar.importarEmpleados
as
begin
	declare @dir varchar(200)
	select @dir = dir + '\Informacion_complementaria.xlsx'
	from importar.Direccion
	create table #temporal (legajo int,
		nombre varchar(50),
		apellido varchar(50),
		dni int,
		direccion varchar(100),
		emailPer varchar(60),
		emailEmp varchar(60),
		cuil char(13),
		cargo varchar(20),
		sucursal varchar(20),
		turno varchar(20))

	declare @sql nvarchar(MAX)
	set @sql = 'insert into #temporal
				select *
				from openrowset(''Microsoft.ACE.OLEDB.12.0'',
				''Excel 12.0; Database=' + @dir + ''', [Empleados$])'

	exec sp_executesql @sql
	insert into recursosHumanos.Empleado select * from #temporal where legajo is not null
	drop table #temporal
end
go

create or alter proc importar.importarMediosDePago
as
begin
	declare @dir varchar(200)
	select @dir = dir + '\Informacion_complementaria.xlsx'
	from importar.Direccion

	create table #temporal (col1 char(11), nomIng char(11), nomEsp char(22))

	declare @sql nvarchar(MAX)
	set @sql = 'insert into #temporal
				select *
				from openrowset(''Microsoft.ACE.OLEDB.12.0'',
				''Excel 12.0; Database=' + @dir + ''', [''medios de pago$''])'
	
	exec sp_executesql @sql
	insert into ventas.MedioDePago select nomIng, nomEsp from #temporal
	drop table #temporal
end
go

create or alter proc importar.ImportarClasificacion
as
begin
	declare @dir varchar(200)
	select @dir = dir + '\Informacion_complementaria.xlsx'
	from importar.Direccion

	declare @sql nvarchar(MAX)
	set @sql = 'insert into catalogo.LineaProducto
				select *
				from openrowset(''Microsoft.ACE.OLEDB.12.0'',
				''Excel 12.0; Database=' + @dir + ''', [''Clasificacion Productos$''])'
	
	exec sp_executesql @sql
end
go

create or alter proc importar.ImportarProductos
as
begin
	declare @dir varchar(200)
	select @dir = dir + '\Productos\catalogo.csv'
	from importar.Direccion

	declare @sql nvarchar(MAX)
	set @sql = 'BULK INSERT catalogo.Nacional
             FROM ''' + @dir + '''
             WITH (
                 FIELDTERMINATOR = '','',  -- Delimitador de campos
                 ROWTERMINATOR = ''0x0a'',   -- Delimitador de filas
                 FIRSTROW = 2,              -- Si el archivo tiene encabezados
				 FORMAT = ''CSV'',
				 CODEPAGE = ''65001''
             );'
	exec sp_executesql @sql
	
	select @dir = dir + '\Productos\Electronic accessories.xlsx'
	from importar.Direccion
	set @sql = 'INSERT INTO catalogo.Electronico
            SELECT *
            FROM OPENROWSET(''Microsoft.ACE.OLEDB.12.0'',
            ''Excel 12.0; Database=' + @dir + ''', [Sheet1$])'
	exec sp_executesql @sql

	select @dir = dir + '\Productos\Productos_importados.xlsx'
	from importar.Direccion
	set @sql = 'INSERT INTO catalogo.Importado
            SELECT *
            FROM OPENROWSET(''Microsoft.ACE.OLEDB.12.0'',
            ''Excel 12.0; Database=' + @dir + ''', [''Listado de Productos$''])'
	exec sp_executesql @sql
end

/*
exec importar.importarVentas
exec importar.reemplazarCaracteres
select *
from ventas.Factura

exec importar.configurarImportacionArchivosExcel

exec importar.importarSucursal
select * from catalogo.Sucursal

exec importar.importarEmpleados
select * from recursosHumanos.Empleado

exec importar.importarMediosDePago
select * from ventas.MedioDePago

exec importar.ImportarClasificacion
select * from catalogo.LineaProducto

exec importar.ImportarProductos
select * from catalogo.Nacional
select * from catalogo.Importado
select * from catalogo.Electronico
*/

/*
truncate table ventas.Factura
truncate table catalogo.Sucursal
truncate table recursosHumanos.Empleado
truncate table ventas.MedioDePago
truncate table catalogo.LineaProducto
truncate table catalogo.Nacional
truncate table catalogo.Electronico
truncate table catalogo.Importado
*/



