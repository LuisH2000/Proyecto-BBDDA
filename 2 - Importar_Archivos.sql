/*
Fecha de Entrega: --/--/----
Comision: 5600
Grupo 13
Bases de Datos Aplicadas

Alumnos:
	-
	-
	-

**ENUNCIADO**
Se proveen los archivos en el TP_integrador_Archivos.zip 
Ver archivo ìDatasets para importarî en Miel. 
Se requiere que importe toda la informaciÛn antes mencionada a la base de datos: 
ï Genere los objetos necesarios (store procedures, funciones, etc.) para importar los 
archivos antes mencionados. Tenga en cuenta que cada mes se recibir·n archivos de 
novedades con la misma estructura, pero datos nuevos para agregar a cada maestro.  
ï Considere este comportamiento al generar el cÛdigo. Debe admitir la importaciÛn de 
novedades periÛdicamente. 
ï Cada maestro debe importarse con un SP distinto. No se aceptar·n scripts que 
realicen tareas por fuera de un SP. 
ï La estructura/esquema de las tablas a generar ser· decisiÛn suya. Puede que deba 
realizar procesos de transformaciÛn sobre los maestros recibidos para adaptarlos a la 
estructura requerida.  
ï Los archivos CSV/JSON no deben modificarse. En caso de que haya datos mal 
cargados, incompletos, errÛneos, etc., deber· contemplarlo y realizar las correcciones 
en el fuente SQL. (SerÌa una excepciÛn si el archivo est· malformado y no es posible 
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

create or alter proc importar.importarSucursal @dir varchar(200)
as
begin
	create table #sucTemp
	(
		id int identity (1,1) primary key,
		ciudad varchar(20),
		sucursal varchar(20),
		direccion varchar(100),
		horario varchar(50),
		telefono char(9)
	)

	declare @sql nvarchar(MAX)
	set @sql = 'insert into #sucTemp
				select *
				from openrowset(''Microsoft.ACE.OLEDB.12.0'',
				''Excel 12.0; Database=' + @dir + ''', [sucursal$])';

	begin try
		exec sp_executesql @sql
	end try
	begin catch
		drop table #sucTemp
		print('Hubo un error en la carga, codigo de error OLE DB:'+cast(error_number() as varchar))
		return
	end catch

	insert into catalogo.Sucursal(sucursal, direccion, horario, telefono)
	select sucursal, direccion, horario, telefono
	from #sucTemp t
	where not exists (select 1 from catalogo.Sucursal s where s.direccion = t.direccion)
	drop table #sucTemp
end
go

create or alter proc importar.importarEmpleados @dir varchar(200)
as
begin
	create table #empTemp (
		legajo int,
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
	set @sql = 'insert into #empTemp
				select *
				from openrowset(''Microsoft.ACE.OLEDB.12.0'',
				''Excel 12.0; Database=' + @dir + ''', [Empleados$])'
	begin try
		exec sp_executesql @sql
	end try
	begin catch
		drop table #empTemp
		print('Hubo un error en la carga, codigo de error OLE DB:'+cast(error_number() as varchar))
		return
	end catch

	insert into recursosHumanos.Cargo 
	select distinct cargo from #empTemp t
	where cargo is not null 
			and not exists(select 1 from recursosHumanos.Cargo c where c.cargo = t.cargo)

	insert into recursosHumanos.Empleado(legajo, nombre, apellido, dni, direccion, emailPer, emailEmp, cuil, cargo, sucursal, turno)
	select legajo, nombre, apellido, dni, direccion, emailPer, emailEmp, cuil, cargo, sucursal, turno from #empTemp t
	where legajo is not null
			and not exists(select 1 from recursosHumanos.Empleado e where e.legajo = t.legajo)

	drop table #empTemp 
end
go

create or alter proc importar.importarMediosDePago @dir varchar(200)
as
begin
	create table #mpTemp (col1 char(11), nomIng char(11), nomEsp char(22))

	declare @sql nvarchar(MAX)
	set @sql = 'insert into #mpTemp
				select *
				from openrowset(''Microsoft.ACE.OLEDB.12.0'',
				''Excel 12.0; Database=' + @dir + ''', [''medios de pago$''])'

	begin try
		exec sp_executesql @sql
	end try
	begin catch
		drop table #mpTemp
		print('Hubo un error en la carga, codigo de error OLE DB:'+cast(error_number() as varchar))
		return
	end catch

	insert into ventas.MedioDePago(nombreIng, nombreEsp)
	select nomIng, nomEsp from #mpTemp t
	where not exists (select 1 from ventas.MedioDePago m where m.nombreEsp = t.nomEsp and m.nombreIng = t.nomIng)

	drop table #mpTemp
end
go

create or alter proc importar.ImportarClasificacion @dir varchar(200)
as
begin
	create table #clasifTemp
	(
		lineaProd varchar(10),
		categoria varchar(50)
	)
	declare @sql nvarchar(MAX)
	set @sql = 'insert into #clasifTemp
				select *
				from openrowset(''Microsoft.ACE.OLEDB.12.0'',
				''Excel 12.0; Database=' + @dir + ''', [''Clasificacion Productos$''])'
	begin try
		exec sp_executesql @sql
	end try
	begin catch
		drop table #clasifTemp
		print('Hubo un error en la carga, codigo de error OLE DB:'+cast(error_number() as varchar))
		return
	end catch

	insert into catalogo.LineaProducto(lineaProd)
	select distinct lineaProd from #clasifTemp t
	where not exists(select 1 from catalogo.LineaProducto l where l.lineaProd = t.lineaProd)

	insert into catalogo.Categoria(categoria, idLineaProd)
	select distinct categoria, l.id
	from #clasifTemp t join catalogo.LineaProducto l on l.lineaProd = t.lineaProd
	where not exists (select 1 from catalogo.Categoria c where t.categoria = c.categoria)

	drop table #clasifTemp
end
go

create or alter proc importar.importarCatalogo @dir varchar(200)
as
begin
	create table #catalogoTemp
	(
		id int primary key,
		categoria varchar(50),
		nombre varchar(100),
		precio decimal(9,2),
		precioRef decimal(9,2),
		unidadRef varchar(10),
		fecha smalldatetime
	)
	declare @sql nvarchar(MAX)
	set @sql = 'BULK INSERT #catalogoTemp
             FROM ''' + @dir + '''
             WITH (
                 FIELDTERMINATOR = '','',  -- Delimitador de campos
                 ROWTERMINATOR = ''0x0a'',   -- Delimitador de filas
                 FIRSTROW = 2,              -- Si el archivo tiene encabezados
				 FORMAT = ''CSV'',
				 FIELDQUOTE=''"'',
				 CODEPAGE = ''65001''
             );'
	begin try
		exec sp_executesql @sql
	end try
	begin catch
		drop table #catalogoTemp
		print('Hubo un error en la carga, codigo de error OLE DB:'+cast(error_number() as varchar))
		return
	end catch

	update #catalogoTemp
	set nombre = replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(nombre, '?', 'Ò'), '√≥', 'Û'), '√©', 'È'), '√°', '·'), '√∫', '˙'), '√≠', 'Ì'), '√É¬∫', '˙'), '√ë', '—'), '¬∫' , '∫'), 'Âçò', 'Ò') , '√', '¡')

	insert into catalogo.Catalogo(idProd, nombre, precio, precioRef, unidadRef, fecha)
	select id, nombre, precio, precioRef, unidadRef, fecha
	from #catalogoTemp t
	where not exists (select 1 from catalogo.Catalogo c where c.nombre = t.nombre and c.precio = t.precio);

	with catalogoDuplicados as
	(
		select nombre, precio, row_number() over(partition by nombre, precio order by nombre, precio) as duplicados
		from catalogo.Catalogo
	)
	delete from catalogoDuplicados where duplicados > 1;

	insert into catalogo.PerteneceA(idCategoria, idProd)
	select c.id, ca.id
	from #catalogoTemp t join catalogo.Categoria c on c.categoria = t.categoria join catalogo.Catalogo ca on ca.nombre = t.nombre and ca.precio = t.precio
	where not exists (select 1 from catalogo.PerteneceA p where p.idCategoria = c.id and p.idProd = ca.id )

	drop table #catalogoTemp
end
go

create or alter proc importar.importarAccesoriosElectronicos @dir varchar(200)
as
begin
	create table #electronicTemp
	(
		id int identity(1,1) primary key,
		nombre varchar(50),
		precio decimal(9,2)
	)
	declare @sql nvarchar(MAX)
	set @sql = 'INSERT INTO #electronicTemp
            SELECT *
            FROM OPENROWSET(''Microsoft.ACE.OLEDB.12.0'',
            ''Excel 12.0; Database=' + @dir + ''', [Sheet1$])'
	begin try
		exec sp_executesql @sql
	end try
	begin catch
		drop table #electronicTemp
		print('Hubo un error en la carga, codigo de error OLE DB:'+cast(error_number() as varchar))
		return
	end catch

	if not exists (select 1 from catalogo.Categoria where categoria like 'electronica')
	begin
		insert into catalogo.LineaProducto(lineaProd) values('Tecnologia')
		insert into catalogo.Categoria(categoria, idLineaProd) select 'electronica', id from catalogo.LineaProducto where lineaProd like 'Tecnologia'
	end

	insert into catalogo.Catalogo(idProd, nombre, precioUSD)
	select id, nombre, precio
	from #electronicTemp t
	where not exists (select 1 from catalogo.Catalogo c where c.precioUSD = t.precio and c.nombre = t.nombre);

	with catalogoDuplicados as
	(
		select nombre, precio, row_number() over(partition by nombre, precio order by nombre, precio) as duplicados
		from catalogo.Catalogo
	)
	delete from catalogoDuplicados where duplicados > 1;

	insert into catalogo.PerteneceA(idCategoria, idProd)
	select c.id, ca.id
	from #electronicTemp t join catalogo.Catalogo ca on ca.nombre = t.nombre and ca.precioUSD = t.precio, catalogo.Categoria c
	where not exists (select 1 from catalogo.PerteneceA p where p.idCategoria = c.id and p.idProd = ca.id ) and c.categoria like 'electronica'

	drop table #electronicTemp
end
go

create or alter proc importar.importarProductosImportados @dir varchar(200)
as
begin
	create table #importTemp
	(
		id int primary key,
		nombre varchar(50),
		proveedor varchar(50),
		categoria varchar(20),
		cantidad varchar(20),
		precio decimal(9,2)
	)
	declare @sql nvarchar(MAX)
	set @sql = 'INSERT INTO #importTemp
            SELECT *
            FROM OPENROWSET(''Microsoft.ACE.OLEDB.12.0'',
            ''Excel 12.0; Database=' + @dir + ''', [''Listado de Productos$''])'
	begin try
		exec sp_executesql @sql
	end try
	begin catch
		drop table #importTemp
		print('Hubo un error en la carga, codigo de error OLE DB:'+cast(error_number() as varchar))
		return
	end catch

	insert into catalogo.Categoria(categoria) 
	select distinct categoria 
	from #importTemp t
	where not exists (select 1 from catalogo.Categoria c where c.categoria = t.categoria);

	with catalogoDuplicados as
	(
		select nombre, precio, row_number() over(partition by nombre, precio order by nombre, precio) as duplicados
		from catalogo.Catalogo
	)
	delete from catalogoDuplicados where duplicados > 1;

	insert into catalogo.Catalogo (idProd, nombre, proveedor, cantXUn, precio)
	select id, nombre, proveedor, cantidad, precio
	from #importTemp t 
	where not exists (select 1 from catalogo.Catalogo c where c.idProd = t.id and c.nombre = t.nombre)

	insert into catalogo.PerteneceA(idCategoria, idProd)
	select c.id, ca.id
	from #importTemp t join catalogo.Categoria c on c.categoria = t.categoria join catalogo.Catalogo ca on ca.nombre = t.nombre and ca.precio = t.precio
	where not exists (select 1 from catalogo.PerteneceA p where p.idCategoria = c.id and p.idProd = ca.id )

	drop table #importTemp
end
go

create or alter proc importar.AgregarLineasDeProducto
as
begin
	update catalogo.Categoria
	set idLineaProd =  (select id from catalogo.LineaProducto where lineaProd like 'Bebidas')
	where categoria like 'Bebidas'

	update catalogo.Categoria
	set idLineaProd =  (select id from catalogo.LineaProducto where lineaProd like 'Almacen')
	where categoria like 'Condimentos'

	update catalogo.Categoria
	set idLineaProd =  (select id from catalogo.LineaProducto where lineaProd like 'Almacen')
	where categoria like 'Granos/Cereales'

	update catalogo.Categoria
	set idLineaProd =  (select id from catalogo.LineaProducto where lineaProd like 'Almacen')
	where categoria like 'L·cteos'

	update catalogo.Categoria
	set idLineaProd =  (select id from catalogo.LineaProducto where lineaProd like 'Almacen')
	where categoria like 'ReposterÌa'

	update catalogo.Categoria
	set idLineaProd =  (select id from catalogo.LineaProducto where lineaProd like 'Frescos')
	where categoria like 'Frutas/Verduras'

	update catalogo.Categoria
	set idLineaProd =  (select id from catalogo.LineaProducto where lineaProd like 'Frescos')
	where categoria like 'Pescado/Marisco'

	update catalogo.Categoria
	set idLineaProd =  (select id from catalogo.LineaProducto where lineaProd like 'Frescos')
	where categoria like 'Carnes'
end
go

create or alter proc importar.importarVentas @dir varchar(200)
as
begin
	create table #ventasTemp
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

	declare @sql nvarchar(MAX)
	set @sql = 'BULK INSERT #ventasTemp
             FROM ''' + @dir + '''
             WITH (
                 FIELDTERMINATOR = '';'',  -- Delimitador de campos
                 ROWTERMINATOR = ''\n'',   -- Delimitador de filas
                 FIRSTROW = 2,              -- Si el archivo tiene encabezados
				 FORMAT = ''CSV'',
				 CODEPAGE = ''65001''
             );';

	begin try
		exec sp_executesql @sql
	end try
	begin catch
		drop table #ventasTemp
		print('Hubo un error en la carga, codigo de error OLE DB:'+cast(error_number() as varchar))
		return
	end catch

	insert into ventas.TipoCliente 
	select distinct tipoCliente from #ventasTemp t
	where not exists (select 1 from ventas.TipoCliente c where c.tipo = t.tipoCliente)
	

	update #ventasTemp
	set nomProd = replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(nomProd, '√±', 'Ò'), '√≥', 'Û'), '√©', 'È'), '√°', '·'), '√∫', '˙'), '√≠', 'Ì'), '√É¬∫', '˙'), '√ë', '—') , '√', '¡'), '?', 'Ò'), '√ë', '—'), '¬∫' , '∫'), 'Âçò', 'Ò'), '¡Åguila', '¡guila')

	insert into ventas.VentaRegistrada(idFactura, tipoFactura, ciudadCliente, tipoCliente, genero, precioUn, cantidad, fecha, hora, empleadoLeg, idPago, medioPago, idProd)
	select t.idFactura, t.tipo, t.ciudad, t.tipoCliente, t.genero, t.precioUn, t.cantidad, 
		convert(date, t.fecha, 101) as Fecha,  
		t.hora, t.empleado, t.idPago, m.id, c.idProd
	from #ventasTemp t join ventas.MedioDePago m on m.nombreIng = t.medioPago join catalogo.Catalogo c on c.nombre =  t.nomProd and c.precio = t.precioUn
	where not exists (select 1 from ventas.VentaRegistrada v where v.idFactura = t.idFactura and v.tipoFactura = t.tipo)

	drop table #ventasTemp
end
go

/*
use master
exec importar.configurarImportacionArchivosExcel

exec importar.importarSucursal 'C:\TP_integrador_Archivos\Informacion_complementaria.xlsx'
select * from catalogo.Sucursal

exec importar.importarEmpleados 'C:\TP_integrador_Archivos\Informacion_complementaria.xlsx'
select * from recursosHumanos.Cargo
select * from recursosHumanos.Empleado

exec importar.importarMediosDePago 'C:\TP_integrador_Archivos\Informacion_complementaria.xlsx'
select * from ventas.MedioDePago

exec importar.importarClasificacion 'C:\TP_integrador_Archivos\Informacion_complementaria.xlsx'
select * from catalogo.LineaProducto 
select * from catalogo.Categoria 

exec importar.importarCatalogo 'C:\TP_integrador_Archivos\Productos\catalogo.csv'
exec importar.importarAccesoriosElectronicos 'C:\TP_integrador_Archivos\Productos\Electronic accessories.xlsx'
exec importar.importarProductosImportados 'C:\TP_integrador_Archivos\Productos\Productos_importados.xlsx'
select * from catalogo.Catalogo where nombre like '70% Alcohol limpieza hogar Bosque Verde' and precio = 1.8
select * from catalogo.PerteneceA order by idProd
select * from catalogo.PerteneceA where idProd = 6029

exec importar.AgregarLineasDeProducto
select * from catalogo.Categoria

exec importar.importarVentas 'C:\TP_integrador_Archivos\Ventas_registradas.csv'
select * from ventas.VentaRegistrada

select distinct unidadRef from catalogo.Catalogo
select distinct cantXUn from catalogo.Catalogo

*/

/*
truncate table ventas.ventaRegistrada
truncate table catalogo.Sucursal
truncate table recursosHumanos.Empleado
truncate table recursosHumanos.Cargo
truncate table ventas.MedioDePago
truncate table catalogo.LineaProducto
truncate table catalogo.Catalogo
*/



