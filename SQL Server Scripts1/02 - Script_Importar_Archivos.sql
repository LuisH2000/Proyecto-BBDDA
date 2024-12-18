/*
Fecha de Entrega: 29/11/2024
Comision: 5600
Grupo 13
Bases de Datos Aplicadas

Alumnos:
	- Diaz, Nicolas 41714473
	- Huang, Luis 43098142

**ENUNCIADO**
Se proveen los archivos en el TP_integrador_Archivos.zip 
Ver archivo �Datasets para importar� en Miel. 
Se requiere que importe toda la informaci�n antes mencionada a la base de datos: 
� Genere los objetos necesarios (store procedures, funciones, etc.) para importar los 
archivos antes mencionados. Tenga en cuenta que cada mes se recibir�n archivos de 
novedades con la misma estructura, pero datos nuevos para agregar a cada maestro.  
� Considere este comportamiento al generar el c�digo. Debe admitir la importaci�n de 
novedades peri�dicamente. 
� Cada maestro debe importarse con un SP distinto. No se aceptar�n scripts que 
realicen tareas por fuera de un SP. 
� La estructura/esquema de las tablas a generar ser� decisi�n suya. Puede que deba 
realizar procesos de transformaci�n sobre los maestros recibidos para adaptarlos a la 
estructura requerida.  
� Los archivos CSV/JSON no deben modificarse. En caso de que haya datos mal 
cargados, incompletos, err�neos, etc., deber� contemplarlo y realizar las correcciones 
en el fuente SQL. (Ser�a una excepci�n si el archivo est� malformado y no es posible 
interpretarlo como JSON o CSV).  
*/

use Com5600G13
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
		ciudad varchar(100),
		sucursal varchar(100),
		direccion varchar(100),
		horario varchar(100),
		telefono varchar(100)
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

	insert into sucursales.Sucursal(ciudad, direccion, horario, telefono)
	select sucursal, direccion, horario, telefono 
	from #sucTemp t
	where not exists (select 1 from sucursales.Sucursal s where s.direccion = t.direccion)
	drop table #sucTemp
end
go

create or alter proc importar.importarEmpleados @dir varchar(200)
as
begin
	create table #empTemp (
		legajo varchar(100),
		nombre varchar(100),
		apellido varchar(100),
		dni varchar(100),
		direccion varchar(100),
		emailPer varchar(100),
		emailEmp varchar(100),
		cuil varchar(100),
		cargo varchar(100),
		sucursal varchar(100),
		turno varchar(100)
	)

	declare @sql nvarchar(MAX)
	set @sql = 'insert into #empTemp
				select *
				from openrowset(''Microsoft.ACE.OLEDB.12.0'',
				''Excel 12.0; Database=' + @dir + ';HDR=NO; IMEX=1'', [Empleados$])'
	begin try
		exec sp_executesql @sql
	end try
	begin catch
		drop table #empTemp
		print('Hubo un error en la carga, codigo de error OLE DB:'+cast(error_number() as varchar))
		return
	end catch

	delete from #empTemp where legajo = 'Legajo/ID'
	
	insert into recursosHumanos.Cargo 
	select distinct cargo from #empTemp t
	where cargo is not null 
			and not exists(select 1 from recursosHumanos.Cargo c where c.cargo = t.cargo)

	insert into recursosHumanos.Empleado(legajo, nombre, apellido, dni, direccion, emailPer, emailEmp, cuil, cargo, idSucursal,
										turno)
	select cast(legajo as int), nombre, apellido, cast(dni as int), t.direccion, emailPer, emailEmp, cuil, c.id, s.id, turno
	from #empTemp t join recursosHumanos.Cargo c on c.cargo = t.cargo
					join sucursales.Sucursal s on s.ciudad = t.sucursal
	where legajo is not null
			and not exists(select 1 from recursosHumanos.Empleado e where e.legajo = cast(t.legajo as int))
	
	drop table #empTemp 
end
go

create or alter proc importar.importarMediosDePago @dir varchar(200)
as
begin
	create table #mpTemp (
		col1 varchar(100), 
		nomIng varchar(100), 
		nomEsp varchar(100)
	)

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

	insert into comprobantes.MedioDePago(nombreIng, nombreEsp)
	select nomIng, nomEsp from #mpTemp t
	where not exists (select 1 from comprobantes.MedioDePago m where m.nombreEsp = t.nomEsp and m.nombreIng = t.nomIng)

	drop table #mpTemp
end
go

create or alter proc importar.ImportarClasificacion @dir varchar(200)
as
begin
	create table #clasifTemp
	(
		lineaProd varchar(100),
		categoria varchar(100)
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
		id varchar(100),
		categoria varchar(100),
		nombre varchar(100),
		precio varchar(100),
		precioRef varchar(100),
		unidadRef varchar(100),
		fecha varchar(100)
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
	set nombre = replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(nombre, '?', '�'), 'ó', '�'), 'é', '�'), 'á', '�'), 'ú', '�'), 'í', '�'), 'Ãº', '�'), 'Ñ', '�'), 'º' , '�'), '単', '�') , '�', '�');

	insert into catalogo.Producto(idProd, nombre, precio, precioRef, unidadRef, fecha)
	select cast(id as int), nombre, cast(precio as decimal(9,2)), cast(precioRef as decimal(9,2)), unidadRef, cast(replace(fecha, '-', '') as smalldatetime)
	from #catalogoTemp t
	where not exists (select 1 from catalogo.Producto p where p.nombre = t.nombre and p.precio = t.precio);

	with catalogoDuplicados as
	(
		select nombre, precio, row_number() over(partition by nombre, precio order by nombre, precio) as duplicados
		from catalogo.Producto
	)
	delete from catalogoDuplicados where duplicados > 1;
	
	insert into catalogo.PerteneceA(idCategoria, idProd)
	select c.id, pr.id
	from #catalogoTemp t join catalogo.Categoria c on c.categoria = t.categoria join catalogo.Producto pr on pr.nombre = t.nombre and pr.precio = cast(t.precio as decimal(9,2))
	where not exists (select 1 from catalogo.PerteneceA p where p.idCategoria = c.id and p.idProd = pr.id )

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
		precio varchar(50)
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
	end;

	with catalogoDuplicados as
	(
		select nombre, precio, row_number() over(partition by nombre, precio order by nombre, precio) as duplicados
		from #electronicTemp
	)
	delete from catalogoDuplicados where duplicados > 1;

	insert into catalogo.Producto(idProd, nombre, precioUSD)
	select id, nombre, cast(precio as decimal(9,2))
	from #electronicTemp t
	where not exists (select 1 from catalogo.Producto p where p.precioUSD = cast(t.precio as decimal(9,2)) and p.nombre = t.nombre);

	insert into catalogo.PerteneceA(idCategoria, idProd)
	select c.id, pr.id
	from #electronicTemp t join catalogo.Producto pr on pr.nombre = t.nombre and pr.precioUSD = cast(t.precio as decimal(9,2)), catalogo.Categoria c
	where not exists 
		(select 1 from catalogo.PerteneceA p where p.idCategoria = c.id and p.idProd = pr.id )
													and c.categoria like 'electronica'

	drop table #electronicTemp
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
	where categoria like 'L�cteos'

	update catalogo.Categoria
	set idLineaProd =  (select id from catalogo.LineaProducto where lineaProd like 'Almacen')
	where categoria like 'Reposter�a'

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

create or alter proc importar.importarProductosImportados @dir varchar(200)
as
begin
	create table #importTemp
	(
		id varchar(100),
		nombre varchar(100),
		proveedor varchar(100),
		categoria varchar(100),
		cantidad varchar(100),
		precio varchar(100)
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
		from catalogo.Producto
	)
	delete from catalogoDuplicados where duplicados > 1;

	insert into catalogo.Producto (idProd, nombre, proveedor, cantXUn, precio)
	select cast(t.id as int), nombre, proveedor, cantidad, cast(precio as decimal(9,2))
	from #importTemp t 
	where not exists (select 1 from catalogo.Producto p where p.idProd = cast(t.id as int) and p.nombre = t.nombre)

	insert into catalogo.PerteneceA(idCategoria, idProd)
	select c.id, pr.id
	from #importTemp t join catalogo.Categoria c on c.categoria = t.categoria join catalogo.Producto pr on pr.nombre = t.nombre and pr.precio = cast(t.precio as decimal(9,2))
	where not exists (select 1 from catalogo.PerteneceA p where p.idCategoria = c.id and p.idProd = pr.id )

	drop table #importTemp

	exec importar.AgregarLineasDeProducto
end
go

create or alter proc importar.importarVentas @dir varchar(200)
as
begin
	create table #ventasTempVarchar
	(
		idFactura varchar(100),
		tipo varchar(100),
		ciudadCliente varchar(100),
		tipoCliente varchar(100),
		genero varchar(100),
		nomProd varchar(100),
		precioUn varchar(100),
		cantidad varchar(100),
		fecha varchar(100),
		hora varchar(100),
		medioPago varchar(100),
		empleado varchar(100),
		idPago varchar(100)
	)

	declare @sql nvarchar(MAX)
	set @sql = 'BULK INSERT #ventasTempVarchar
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
		drop table #ventasTempVarchar
		print('Hubo un error en la carga, codigo de error OLE DB:'+cast(error_number() as varchar))
		return
	end catch

	create table #ventasTemp
	(
		idFactura varchar(100),
		tipo varchar(100),
		ciudadCliente varchar(100),
		tipoCliente varchar(100),
		genero varchar(100),
		nomProd varchar(100),
		precioUn decimal(6,2),
		cantidad int,
		fecha date,
		hora time,
		medioPago varchar(100),
		empleado int,
		idPago varchar(100)
	)
	insert into #ventasTemp 
	select 
		idFactura,
		tipo,
		ciudadCliente,
		tipoCliente,
		genero,
		nomProd,
		cast(precioUn as decimal(6,2)),
		cast(cantidad as int),
		convert(date, fecha, 101),
		cast(hora as time),
		medioPago,
		cast(empleado as int),
		idPago
	from #ventasTempVarchar
	
	insert into clientes.TipoCliente 
	select distinct tipoCliente from #ventasTemp t
	where not exists (select 1 from clientes.TipoCliente c where c.tipo = t.tipoCliente)

	create table #clienteTemp
	(
		idTipo int,
		ciudad varchar(100),
		genero varchar(10)
	)

	insert into #clienteTemp(idTipo, ciudad, genero)
	select c.id, t.ciudadCliente, t.genero
	from #ventasTemp t join clientes.TipoCliente c on t.tipoCliente = c.tipo
	where not exists (select 1 from clientes.Cliente where idTipo = c.id and ciudad = t.ciudadCliente and genero = t.genero)
	order by t.tipoCliente, t.ciudadCliente, t.genero;
	with clientesDup as
	(
		select row_number() over(partition by idTipo, ciudad, genero order by idTipo, ciudad, genero) as dup
		from #clienteTemp
	)
	delete from clientesDup where dup >= 2

	insert into clientes.Cliente(idTipo, ciudad, genero)
	select * from #clienteTemp
	
	update #ventasTemp
	set nomProd = replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(nomProd, 'ñ', '�'), 'ó', '�'), 'é', '�'), 'á', '�'), 'ú', '�'), 'í', '�'), 'Ãº', '�'), 'Ñ', '�') , '�', '�'), '?', '�'), 'Ñ', '�'), 'º' , '�'), '単', '�'), '��guila', '�guila')
	
	insert into ventas.Factura(idFactura, tipoFactura, fecha, hora, empleadoLeg, estado, idCliente)
	select t.idFactura, t.tipo, t.fecha, t.hora, t.empleado, 'Pagada', cl.id
	from #ventasTemp t 
		join clientes.TipoCliente c on c.tipo = t.tipoCliente
		join clientes.Cliente cl on cl.idTipo = c.id and cl.ciudad = t.ciudadCliente and cl.genero = t.genero
	where not exists (select 1 from ventas.Factura v where v.idFactura = t.idFactura and v.tipoFactura = t.tipo)

	insert into ventas.LineaDeFactura(idFactura, idProd, precioUn, cantidad, subtotal)
	select fa.id , p.id, t.precioUn, t.cantidad, t.precioUn * t.cantidad
	from #ventasTemp t join catalogo.Producto p on p.nombre = t.nomProd and p.precio = t.precioUn join ventas.Factura fa on fa.idFactura = t.idFactura 
	where not exists( select 1 from ventas.LineaDeFactura f where fa.idFactura = t.idFactura and f.idProd = p.id and f.precioUn = t.precioUn);

	with totalPorFactura as
	(
		select idFactura, sum(subtotal) as total
		from ventas.LineaDeFactura
		group by idFactura
	)
	insert into comprobantes.Comprobante(tipoComprobante, idPago, idMedPago, idFactura, fecha, hora, monto)
	select 'Factura', t.idPago, m.id, fa.id, fa.fecha, fa.hora, tot.total
	from #ventasTemp t 
		join comprobantes.MedioDePago m on m.nombreIng = t.medioPago 
		join ventas.Factura fa on fa.idFactura = t.idFactura
		join totalPorFactura tot on tot.idFactura = fa.id
	where not exists (select 1 from comprobantes.Comprobante c where c.idPago = t.idPago)
	drop table #ventasTemp
	drop table #ventasTempVarchar
	drop table #clienteTemp
end
go
