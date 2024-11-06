/*
Fecha de Entrega: 15/11/2024
Comision: 5600
Grupo 13
Bases de Datos Aplicadas

Alumnos:
	- Diaz, Nicolas 41714473
	- Huang, Luis 43098142
	- Rolleri Vilalba, Santino 46026386

**ENUNCIADO**
Genere store procedures para manejar la inserción, modificado, borrado (si corresponde, 
también debe decidir si determinadas entidades solo admitirán borrado lógico) de cada tabla. 
Los nombres de los store procedures NO deben comenzar con “SP”.  
*/

use Com5600G13
go
--***SUCURSAL***
create or alter proc sucursales.insertarSucursal 
	@ciudad varchar(20), 
	@dir varchar(100), 
	@horario varchar(50),
	@telefono char(9)
as
begin
	--Nico: hice que el resultado de trimmear los datos de entrada se guarden en variables, las validaciones funcionan igual
	--solo que ahora en la tabla se insertan trimmeadas (antes podias insertar algo como '   La matanza  ' en ciudad y hubiera sido valido por ej.
	declare @error varchar(500)=''
	declare @ciudadTrim varchar(20)=''
	declare @dirTrim varchar(100)=''
	declare @horarioTrim varchar(50)=''
	
	set @ciudadTrim=ltrim(rtrim(@ciudad))
	if @ciudad is null or @ciudadTrim = ''
	begin
		set @error = 'No paso el nombre de la sucursal o paso un nombre vacio' + char(13) + char(10)
	end

	set @dirTrim=ltrim(rtrim(@dir))
	if @dir is null or @dirTrim = ''
	begin
		set @error = @error + 'No paso la direccion de la sucursal o paso una direccion vacia' + char(13) + char(10)
	end
	
	set @horarioTrim=ltrim(rtrim(@horario))
	if @horario is null or @horarioTrim = ''
	begin
		set @error = @error + 'No paso el horario de la sucursal o paso un horario vacio' + char(13) + char(10)
	end

	if @telefono is null or ltrim(rtrim(@telefono)) = ''
	begin
		set @error = @error + 'No paso el telefono de la sucursal o paso un telefono vacio' + char(13) + char(10)
	end

	if @telefono not like ('[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]')
	begin
		set @error = @error + 'El telefono ingresado no es valido, formato de telefono: xxxx-xxxx' + char(13) + char(10)
	end

	if exists (select 1 from sucursales.Sucursal where (direccion = @dir and ciudad = @ciudad) or (direccion=@dirTrim and ciudad=@ciudadTrim))
	begin
		set @error = @error + 'Ya existe una sucursal en: ' + @dir + char(13) + char(10)
	end
	
	if @error <> ''
	begin
		raiserror(@error, 16, 1)
		return
	end
	
	insert into sucursales.Sucursal(ciudad, direccion, horario, telefono)
	values(@ciudadTrim, @dirTrim, @horarioTrim, @telefono)
end
go
--***EMPLEADO***
--SP para ingresar empleado en una sucursal donde la sucursal se determina por ciudad y direccion de la misma
create or alter procedure recursosHumanos.insertarEmpleadoSucursalPorCiudadDireccion
@legajo int,
@nombre varchar(50),
@apellido varchar(50),
@dni int,
@direccionEmp varchar(100),
@emailPer varchar(60),
@emailEmp varchar(60),
@cuil char(13),
@cargo varchar(20),
@turno varchar(20),
@ciudadSuc varchar(20),
@direccionSuc varchar(100)
as
begin
	declare @error varchar(max)=''
	declare @idSuc int
	declare @idCargo int
	--Validaciones criticas (campos que no pueden ser nulos: legajo, dni, emailPer, emailEmp, cargo, ciudadSuc, direccionSuc, turno)
	if @legajo is null or @dni is null or @emailPer is null or @emailEmp is null or @cargo is null or @ciudadSuc is null or @direccionSuc is null or @turno is null
	begin
		raiserror('Como minimo, un registro de empleado debe tener un legajo, dni, email personal, email empresarial, cargo, ciudad y direccion de sucursal y un turno. Ingrese estos 
		datos e intente nuevamente',16,1)
		return
	end
	--Validaciones generales
	--Validacion de legajo unico
	if (select 1 from recursosHumanos.Empleado where legajo=@legajo) is not null
		set @error=@error+'Ya existe un empleado con legajo '+cast(@legajo as varchar)+ CHAR(13)+CHAR(10)
	--Validacion de DNI unico
	if (select 1 from recursosHumanos.Empleado where dni=@dni) is not null
		set @error=@error+'Ya existe un empleado con DNI '+ cast(@dni as varchar)+ CHAR(13)+CHAR(10)
	--Validacion de formato de correo correcto, que no sean iguales entre si y que sean unicos ambos
	set @emailPer=LTRIM(RTRIM(@emailPer))
	set @emailEmp=LTRIM(RTRIM(@emailEmp))
	if(@emailPer=@emailEmp)
		set @error=@error+'El correo personal es igual que el correo empresarial, deben ser diferentes.'+CHAR(13)+CHAR(10)
	if(CHARINDEX('@',@emailPer)=0)
		set @error=@error+'El correo personal ingresado no tiene formato de correo (no contiene un @)'+CHAR(13)+CHAR(10)
	if(CHARINDEX('@',@emailEmp)=0)
		set @error=@error+'El correo empresarial ingresado no tiene formato de correo (no contiene un @)'+CHAR(13)+CHAR(10)
	if(select 1 from recursosHumanos.Empleado where emailEmp=@emailEmp) is not null
		set @error=@error+'El correo empresarial '+@emailEmp+' ya se encuentra en uso.'+CHAR(13)+CHAR(10)
	if(select 1 from recursosHumanos.Empleado where emailPer=@emailPer) is not null
		set @error=@error+'El correo personal '+@emailPer+' ya se encuentra en uso.'+CHAR(13)+CHAR(10)
	--Validacion de que el cargo existe, obtencion de su id
	set @cargo=LTRIM(RTRIM(@cargo))
	set @idCargo=(select id from recursosHumanos.Cargo where cargo=@cargo)
	if @idCargo is null
		set @error=@error+'El cargo '+@cargo+' no existe, ingrese el cargo usando recursosHumanos.insertarCargo y luego cargue al empleado'+CHAR(13)+CHAR(10)
	--Validacion del turno 
	set @turno=LTRIM(RTRIM(@turno))
	if @turno not in ('TM', 'TT', 'Jornada Completa')
		set @error=@error+'El turno ingresado no es valido, este debe ser TM, TT o Jornada Completa'+CHAR(13)+CHAR(10)
	--Validacion de que la ciudad y direccion ingresadas correspondan a una sucursal, obtencion de ID sucursal
	set @ciudadSuc=LTRIM(rtrim(@ciudadSuc))
	set @direccionSuc=LTRIM(RTRIM(@direccionSuc))
	set @idSuc=(select id from sucursales.Sucursal where ciudad=@ciudadSuc and direccion=@direccionSuc)
	if @idSuc is null
		set @error=@error+'No se encontro la sucursal ingresada, asegurese de que esta existe y sino carguela usando sucursales.insertarSucursal y luego cargue al empleado'+CHAR(13)+CHAR(10)
	--Validacion de formato de cuil y si este fue ingresado como '' o con espacios asignarle null
	set @cuil=LTRIM(rtrim(@cuil))
	if @cuil=''
		set @cuil=null
	if @cuil is not null
	begin
		if @cuil not like ('[0-9][0-9]-[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]-[0-9]')
			set @error=@error+'Formato de cuil ingresado incorrecto, debe ser xx-xxxxxxxx-x'+CHAR(13)+CHAR(10)
	end
	if @error <> ''
	begin
		raiserror(@error, 16, 1)
		return
	end
	--Insercion
	insert into recursosHumanos.Empleado (legajo,nombre,apellido,dni,direccion,emailPer,emailEmp,cuil,cargo,idSucursal,turno,activo)
	values(@legajo,@nombre,@apellido,@dni,RTRIM(ltrim(@direccionEmp)),@emailPer,@emailEmp,@cuil,@idCargo,@idSuc,@turno,1)
end
go
--SP para ingresar empleado en una sucursal donde la sucursal se determina por ID
create or alter procedure recursosHumanos.insertarEmpleadoSucursalPorId
@legajo int,
@nombre varchar(50),
@apellido varchar(50),
@dni int,
@direccionEmp varchar(100),
@emailPer varchar(60),
@emailEmp varchar(60),
@cuil char(13),
@cargo varchar(20),
@turno varchar(20),
@idSucursal int
as
begin
	declare @error varchar(max)=''
	declare @idCargo int
	--Validaciones criticas (campos que no pueden ser nulos: legajo, dni, emailPer, emailEmp, cargo, idSucursal, turno)
	if @legajo is null or @dni is null or @emailPer is null or @emailEmp is null or @cargo is null or @idSucursal is null or @turno is null
	begin
		raiserror('Como minimo, un registro de empleado debe tener un legajo, dni, email personal, email empresarial, cargo y un Id de sucursal valido. Ingrese estos 
		datos e intente nuevamente',16,1)
		return
	end
	--Validaciones generales
	--Validacion de legajo unico
	if (select 1 from recursosHumanos.Empleado where legajo=@legajo) is not null
		set @error=@error+'Ya existe un empleado con legajo '+cast(@legajo as varchar)+ CHAR(13)+CHAR(10)
	--Validacion de DNI unico
	if (select 1 from recursosHumanos.Empleado where dni=@dni) is not null
		set @error=@error+'Ya existe un empleado con DNI '+ cast(@dni as varchar)+ CHAR(13)+CHAR(10)
	--Validacion de formato de correo correcto, que no sean iguales entre si y que sean unicos ambos
	set @emailPer=LTRIM(RTRIM(@emailPer))
	set @emailEmp=LTRIM(RTRIM(@emailEmp))
	if(@emailPer=@emailEmp)
		set @error=@error+'El correo personal es igual que el correo empresarial, deben ser diferentes.'+CHAR(13)+CHAR(10)
	if(CHARINDEX('@',@emailPer)=0)
		set @error=@error+'El correo personal ingresado no tiene formato de correo (no contiene un @)'+CHAR(13)+CHAR(10)
	if(CHARINDEX('@',@emailEmp)=0)
		set @error=@error+'El correo empresarial ingresado no tiene formato de correo (no contiene un @)'+CHAR(13)+CHAR(10)
	if(select 1 from recursosHumanos.Empleado where emailEmp=@emailEmp) is not null
		set @error=@error+'El correo empresarial '+@emailEmp+' ya se encuentra en uso.'+CHAR(13)+CHAR(10)
	if(select 1 from recursosHumanos.Empleado where emailPer=@emailPer) is not null
		set @error=@error+'El correo personal '+@emailPer+' ya se encuentra en uso.'+CHAR(13)+CHAR(10)
	--Validacion de que el cargo existe, obtencion de su id
	set @cargo=LTRIM(RTRIM(@cargo))
	set @idCargo=(select id from recursosHumanos.Cargo where cargo=@cargo)
	if @idCargo is null
		set @error=@error+'El cargo '+@cargo+' no existe, ingrese el cargo usando recursosHumanos.insertarCargo y luego cargue al empleado'+CHAR(13)+CHAR(10)
	--Validacion del turno 
	set @turno=LTRIM(RTRIM(@turno))
	if @turno not in ('TM', 'TT', 'Jornada Completa')
		set @error=@error+'El turno ingresado no es valido, este debe ser TM, TT o Jornada Completa'+CHAR(13)+CHAR(10)
	--Validacion de que la ciudad y direccion ingresadas correspondan a una sucursal, obtencion de ID sucursal
	if not exists(select 1 from sucursales.Sucursal where id=@idSucursal)
		set @error=@error+'No se encontro la sucursal ingresada, asegurese de que el ID ingresado corresponde con alguna sucursal.'+CHAR(13)+CHAR(10)
	--Validacion de formato de cuil y si este fue ingresado como '' o con espacios asignarle null
	set @cuil=LTRIM(rtrim(@cuil))
	if @cuil=''
		set @cuil=null
	if @cuil is not null
	begin
		if @cuil not like ('[0-9][0-9]-[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]-[0-9]')
			set @error=@error+'Formato de cuil ingresado incorrecto, debe ser xx-xxxxxxxx-x'+CHAR(13)+CHAR(10)
	end
	if @error <> ''
	begin
		raiserror(@error, 16, 1)
		return
	end
	--Insercion
	insert into recursosHumanos.Empleado (legajo,nombre,apellido,dni,direccion,emailPer,emailEmp,cuil,cargo,idSucursal,turno,activo)
	values(@legajo,@nombre,@apellido,@dni,RTRIM(ltrim(@direccionEmp)),@emailPer,@emailEmp,@cuil,@idCargo,@idSucursal,@turno,1)
end
go
--***CARGO***
--SP para insertar un cargo
create or alter procedure recursosHumanos.insertarCargo
@nombreCargo varchar(20)
as
begin
	--Quitamos espacios al inicio y al final, primera letra mayuscula y el resto todo minuscula
	SET @nombreCargo = UPPER(LEFT(LTRIM(RTRIM(@nombreCargo)), 1)) + LOWER(SUBSTRING(LTRIM(RTRIM(@nombreCargo)), 2, LEN(@nombreCargo) - 1))
	--Validacion de que no sea nulo ni vacio
	if @nombreCargo is null or @nombreCargo=''
	begin
		raiserror('No se ingreso un nombre de cargo',16,1)
		return
	end
	--Validacion de cargo unico
	if(select 1 from recursosHumanos.Cargo where cargo=@nombreCargo) is not null
	begin
		raiserror('El cargo ingresado ya existe.',16,1)
		return
	end
	--insercion
	insert into recursosHumanos.Cargo (cargo)
	values(@nombreCargo)
end
go

---***CATEGORIA***
--SP para insertar una linea de Producto junto con su categoria (tal como venian en el archivo, de a pares)
--Si la linea de producto no existe la crea, si ya existe asocia la categoria a ese LP existente, si la categoria ya existe tira error
--y avisa que la categoria ya esta registrada y asociada a un LP existente
create or alter procedure catalogo.insertarLineaProductoYCategoria
@lineaProd varchar(10),
@categoria varchar(50)
as
begin
	declare @error varchar(max)=''
	declare @resuValLP bit
	declare @LPError varchar(10)
	declare @idLP int
	declare @resuValC bit
	declare @resuValComb bit
	set @lineaProd=replace(RTRIM(ltrim(@lineaProd)),' ','_')
	set @categoria=replace(RTRIM(ltrim(@categoria)),' ','_')
	--Validamos que ambos campos no esten vacios
	if @lineaProd is null or @lineaProd=''
		set @error=@error+'No se ingreso una linea de producto.'+CHAR(13)+CHAR(10)
	if @categoria is null or @categoria=''
		set @error=@error+'No se ingreso una categoria.'+CHAR(13)+CHAR(10)
	--Validamos que no existan ambos campos ya en alguna de las tablas
	set @resuValLP=(select 1 from catalogo.LineaProducto where lineaProd=@lineaProd)
	set @resuValC=(select 1 from catalogo.Categoria where categoria=@categoria)
	set @resuValComb=(select 1 from catalogo.Categoria c inner join catalogo.LineaProducto lp on c.idLineaProd=lp.id where categoria=@categoria and lineaProd=@lineaProd)
	if @resuValComb is not null
	begin
		set @error=@error+'La combinacion linea de producto con categoria ingresada ya esta registrada.'+CHAR(13)+CHAR(10)
	end
	else if @resuValC is not null
	begin
		set @LPError=(select lp.lineaProd from catalogo.LineaProducto lp
						inner join catalogo.Categoria c
							on lp.id=c.idLineaProd
						where c.categoria=@categoria)
		set @error=@error+'La categoria de producto ingresada ya esta registrada y asociada con la linea de productos: '+@LPError+'.'+CHAR(13)+CHAR(10)
	end
	if @error <> ''
	begin
		raiserror(@error,16,1)
		return
	end
	--Habiendo validado insertamos la combinacion
	if @resuValLP is null --insertamos la linea de producto solo si este no existia previamente
	begin
		insert into catalogo.LineaProducto(lineaProd)
		values (@lineaProd)
	end
	set @idLP=(select id from catalogo.LineaProducto where lineaProd=@lineaProd) --obtenemos el id de la LP 
	insert into catalogo.Categoria (categoria,idLineaProd) --ingresamos la categoria
	values(@categoria,@idLP)
end
go
---***LINEA DE PRODUCTO***
--SP para insertar una linea de producto (sola, sin categoria)
create or alter procedure catalogo.insertarLineaProducto
@lineaProd varchar(10)
as
begin
	set @lineaProd=RTRIM(ltrim(@lineaProd))
	--Verificamos que no sea null ni vacio
	if @lineaProd is null or @lineaProd=''
	begin
		raiserror('No se ingreso una linea de producto o esta vacia',16,1)
		return
	end
	--verificamos que no exista ya
	if (select 1 from catalogo.LineaProducto where lineaProd=@lineaProd) is not null
	begin
		raiserror('La linea de producto ingresada ya esta registrada.',16,1)
		return
	end
	--insertamos
	insert into catalogo.LineaProducto (lineaProd)
	values(@lineaProd)
end
go

--***PRODUCTO***
--SP Para ingresar un producto
create or alter procedure catalogo.insertarProducto
@idProd int, --puede ser null
@nombre varchar(100), --no null
@precio decimal(9,2), --puede ser null pero si esta debe ser positivo
@precioUSD decimal(9,2), --puede ser null pero si esta debe ser positivo
						-- precio y precioUSD no pueden ser null a la vez, si o si
						-- debe tener uno
@precioRef decimal(9,2), --puede ser null pero si esta debe ser positivo
@unidadRef varchar(10), --puede ser null
@proveedor varchar(50), --puede ser null
@cantXUn varchar(20), --puede ser null
@categoria varchar(50) --no null
as
begin
	declare @idCat int
	declare @idProductoTab int
	declare @error varchar(max)=''
	set @nombre=LTRIM(rtrim(@nombre))
	set @unidadRef=LTRIM(rtrim(@unidadRef))
	set @proveedor=LTRIM(rtrim(@proveedor))
	set @cantXUn=LTRIM(rtrim(@cantXUn))
	set @categoria=LTRIM(RTRIM(@categoria))
	--Verificacion de nombre
	if @nombre is null or @nombre=''
	begin
		set @error=@error+'No se ingreso un nombre de producto.'+CHAR(13)+CHAR(10)
	end
	--verificacion de que hayan pasado algun precio y ademas sean positivo
	if @precio is null and @precioUSD is null
	begin
		set @error=@error+'No se ingreso un precio para el producto. Ingresar el precio o precio en USD'+CHAR(13)+CHAR(10)
	end
	if @precio is not null
	begin
		if @precio<0
		begin
			set @error=@error+'El precio del producto no puede ser negativo.'+CHAR(13)+CHAR(10)
		end
	end
	if @precioUSD is not null
	begin
		if @precioUSD<0
			set @error=@error+'El precio en USD del producto no puede ser negativo.'+CHAR(13)+CHAR(10)
	end
	--verificacion de precioRef positivo de no ser nulo
	if @precioRef is not null
	begin
		if @precioRef<0
			set @error=@error+'El precio de referencia no puede ser negativo.'+CHAR(13)+CHAR(10)
	end
	--verificacion de que categoria no es nula
	if @categoria is null or @categoria=''
		set @error=@error+'No se ingreso una categoria para el producto.'+CHAR(13)+CHAR(10)
	--y si no es nula verificamos que la categoria existe
	else
	begin
		set @idCat=(select id from catalogo.Categoria where categoria=@categoria)
		if @idCat is null
			set @error=@error+'La categoria ingresada no existe. Agreguela primero usando catalogo.insertarLineaProductoYCategoria y luego cargue este producto.'+CHAR(13)+CHAR(10)
	end
	--verificamos que la combinacion de idProd, nombre y precio sean unicos
	if exists (select 1 from catalogo.Producto where idProd=@idProd and nombre=@nombre and precio=@precio)
		set @error=@error+'El producto ingresado ya se encuentra registrado.'+CHAR(13)+CHAR(10)
	--verificamos si hubo algun error
	if @error<>''
	begin
		raiserror(@error,16,1)
		return
	end
	--insertamos el producto
	insert into catalogo.Producto(idProd, nombre, precio, precioUSD, precioRef, unidadRef, fecha, proveedor, cantXUn, activo)
	values(@idProd,@nombre,@precio,@precioUSD,@precioRef,@unidadRef,cast(GETDATE() as smalldatetime),@proveedor,@cantXUn,1);
	--obtenemos el id del producto para cargarlo en perteneceA
	if @precio is not null
		set @idProductoTab=(select id from catalogo.Producto where nombre=@nombre and precio = @precio)
	else
		set @idProductoTab=(select id from catalogo.Producto where nombre=@nombre and precioUSD = @precioUSD)
	--Lo cargamos a perteneceA para establecer la relacion
	insert into catalogo.PerteneceA(idCategoria, idProd)
	values(@idCat,@idProductoTab)
end
go

--***TIPO CLIENTE***
--SP para insertar un tipo de cliente nuevo
create or alter procedure clientes.insertarTipoCliente
@tipo char(6)
as
begin
	set @tipo=LTRIM(rtrim(@tipo))
	--Verificamos que no sea nulo
	if @tipo is null or @tipo=''
	begin
		raiserror('No se inserto un tipo de cliente.',16,1)
		return
	end
	--Verificamos que no exista ya
	if exists (select 1 from clientes.TipoCliente where tipo=@tipo)
	begin
		raiserror('El tipo de cliente que se intento ingresar ya existe.',16,1)
		return
	end
	--insertamos
	insert into clientes.TipoCliente (tipo)
	values(@tipo)
end
go

--***MEDIO DE PAGO***
--SP Para insertar un nuevo medio de pago (nota: estaria bueno usar una api de traduccion aca, si me da el tiempo despues voy a intentar incorporar eso).
create or alter procedure comprobantes.insertarMedioDePago
@medioDePagoIng varchar(11), --no puede ser null
@medioDePagoEsp varchar(22)  --no puede ser null
as
begin
	declare @error varchar(max)=''
	set @medioDePagoIng=LTRIM(rtrim(@medioDePagoIng))
	set @medioDePagoEsp=LTRIM(rtrim(@medioDePagoEsp))
	--verificamos que no sean nulos ni vacios
	if @medioDePagoIng is null or @medioDePagoIng=''
		set @error=@error+'No se ingreso el nombre del medio de pago en ingles.'+CHAR(13)+CHAR(10)
	if @medioDePagoEsp is null or @medioDePagoEsp=''
		set @error=@error+'No se ingreso el nombre del medio de pago en español.'+CHAR(13)+CHAR(10)
	--verificamos que no existan ya
	if exists (select 1 from comprobantes.MedioDePago where nombreEsp=@medioDePagoEsp)
		set @error=@error+'El medio de pago en español ingresado ya esta registrado, este debe ser unico'+CHAR(13)+CHAR(10)
	if exists (select 1 from comprobantes.MedioDePago where nombreIng=@medioDePagoIng)
		set @error=@error+'El medio de pago en ingles ingresado ya esta registrado, este debe ser unico'+CHAR(13)+CHAR(10)
	--verificamos errores
	if @error<>''
	begin
		raiserror(@error,16,1)
		return
	end
	--insertamos medioDePago
	insert into comprobantes.MedioDePago (nombreIng,nombreEsp)
	values(@medioDePagoIng,@medioDePagoEsp)
end
go

--***FACTURA***
--SP para insertar una factura (venta)
if not exists (select * from sys.types where name = 'tablaProductosIdCant' and is_user_defined = 1)
begin
	CREATE TYPE tablaProductosIdCant AS TABLE (
		idProd int,
		cantidad int
	);
end
go --Este tipo de dato es necesario para poder pasarle multiples productos al sp
create or alter procedure ventas.insertarFactura 
@idFactura char(11), --no null, unico
@tipoFactura char(1), --no null, debe ser A B o C
@empleadoLeg int, --no null, debe existir
@ciudadCliente varchar(20), --puede ser null, si viene vacio se reemplaza por null
@genero char(6), --no puede ser null, debe ser male o female
@tipoCliente char(6), --no null
@prodsId tablaProductosIdCant READONLY --debe venir con al menos 1 registro valido con cantidades validas
as
begin
	declare @error varchar(max)=''
	declare @idTipoCliente int
	declare @idProductosConf table
	(
	idProd int,
	cant int,
	precio decimal(9,2),
	precioUsd decimal(9,2)
	)
	declare @idRealFactura int
	declare @idMedioPago int
	--normalizamos los datos de entrada
	set @idFactura=RTRIM(ltrim(@idFactura))
	set @ciudadCliente=RTRIM(ltrim(@ciudadCliente))
	set @genero=RTRIM(ltrim(@genero))
	set @tipoCliente=RTRIM(ltrim(@tipoCliente))
	set @tipoFactura=UPPER(@tipoFactura)
	--verificamos campos que no pueden ser nulos
	if @idFactura is null or @idFactura=''
		set @error=@error+'No se ingreso un id de factura.'+CHAR(13)+CHAR(10)
	if @tipoFactura is null or @tipoFactura=''
		set @error=@error+'No se ingreso un tipo de factura.'+CHAR(13)+CHAR(10)
	if @empleadoLeg is null
		set @error=@error+'No se ingreso un legajo para indicar el empleado que realizo la venta.'+CHAR(13)+CHAR(10)
	if @tipoCliente is null or @tipoCliente=''
		set @error=@error+'No se ingreso un tipo de cliente.'+CHAR(13)+CHAR(10)
	if @genero is null or @genero=''
		set @error=@error+'No se ingreso un genero para el cliente, este debe ser male o female.'+char(13)+char(10)
	--seteamos aquellos campos que vienen vacios en null
	if @ciudadCliente=''
		set @ciudadCliente=null
	--verificaciones generales
	--Pasamos a una tabla variable aquellos productos que si existen en catalogo.producto
	insert into @idProductosConf
	select pid.idProd, pid.cantidad, p.precio,p.precioUSD from @prodsId pid
	left join catalogo.Producto p
	on pid.idProd=p.id
	where p.id is not null
	and pid.cantidad>0
	and p.activo=1
	--verificamos que la tabla de productos confirmados tenga al menos un producto cargado
	if (select COUNT(1) from @idProductosConf)<>(select COUNT(1) from @prodsId)
		set @error=@error+'Se ingresaron productos que no existen o cantidades negativas.'+CHAR(13)+CHAR(10)
	--verificamos que el idFactura tenga el formato correcto y que no este registrado ya
	--verificamos que el idFactura no este duplicado
	if @idFactura not like ('[0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9]')
		set @error=@error+'El formato de la factura es incorrecto, debe ser xxx-xx-xxxx.'+CHAR(13)+CHAR(10)
	else if exists(select 1 from ventas.Factura where idFactura=@idFactura)
		set @error=@error+'El id de factura ingresado ya se encuentra registrado.'+char(13)+char(10)
	--verificamos que el tipo de factura sea correcto
	if @tipoFactura not in ('A','B','C')
		set @error=@error+'El tipo de factura debe ser A, B o C'+CHAR(13)+CHAR(10)
	--verificamos que el empleado exista
	if not exists (select 1 from recursosHumanos.Empleado where legajo=@empleadoLeg)
		set @error=@error+'El empleado ingresado no existe, inserte ese empleado usando recursosHumanos.insertarEmpleadoSucursalPorCiudadDireccion y luego cargue la factura.'+CHAR(13)+CHAR(10)
	--verificamos que el tipo de cliente ingresado exista
	set @idTipoCliente=(select id from clientes.TipoCliente where tipo=@tipoCliente)
	if @idTipoCliente is null
		set @error=@error+'El tipo de cliente ingresado no existe, inserte este tipo de cliente usando clientes.insertarTipoCliente y luego cargue la factura.'+CHAR(13)+CHAR(10)
	--verificamos que el genero del cliente sea male o female
	if @genero not in ('male','female')
		set @error=@error+'El genero del cliente debe ser male o female.'+char(13)+char(10)
	if @error<>''
	begin
		raiserror(@error,16,1)
		return
	end
	--Preprocesamos la tabla de productos confirmados, especificamente usamos el sp para convertir usd a pesos y a aquellos productos que no tengan
	--precio en pesos le asignamos un precio usando su precio en dolares
	declare @cantUsdProd int
	declare @precioDolarPeso decimal(9,2)
	set @cantUsdProd=(select count(1) from @idProductosConf where precioUsd is not null)
	if(@cantUsdProd>0)
	begin
		exec ventas.obtenerPrecioDolar @precioDolarPeso output;
		select @precioDolarPeso as precioDolarUsado
		if(@precioDolarPeso is null)
		begin
			raiserror('Los productos que se intentaron comprar contenian algunos precios en dolares, la API de conversion de moneda no respondio la solicitud, intente mas tarde.',16,1)
			return
		end
		update @idProductosConf
		set precio=precioUsd*@precioDolarPeso
		where precio is null
	end
	--Una vez pasadas todas las verificaciones insertamos
	insert into ventas.factura (idFactura, tipoFactura,fecha,hora,empleadoLeg,ciudadCliente,genero,idTipoCliente)
	values(@idFactura,@tipoFactura,cast(getdate() as date), cast(getdate() as time),@empleadoLeg,@ciudadCliente,@genero,@idTipoCliente);
	--capturamos el id real autogenerado de la factura
	set @idRealFactura=(select id from ventas.factura where idFactura=@idFactura)
	--creamos las lineas de factura asociadas
	insert into ventas.LineaDeFactura (idFactura,idProd,precioUn,cantidad,subtotal)
	select @idRealFactura,pf.idProd, pf.precio, pf.cant, pf.precio*pf.cant
	from @idProductosConf pf
end
go

create or alter proc comprobantes.insertarComprobante
	@idPago char(23),
	@mp int,
	@factura char(11)
as
begin
	declare @error varchar(max) = ''
	declare @idFactura int
	set @idPago = ltrim(rtrim(@idPago))
	set @factura = ltrim(rtrim(@factura))
	--verificamos que el id de pago no este vacio
	if @idPago is null or @idPago = ''
		set @error = @error + 'No se ingreso el id de pago' +CHAR(13)+CHAR(10)
	--verificamos que el medio de pago ingresado exista
	if not exists (select 1 from comprobantes.MedioDePago where id = @mp)
	begin
		set @error = @error + 'El medio de pago ingresado no existe' +CHAR(13)+CHAR(10)
	end
	--verificamos que la factura no este vacia y que exista
	if @factura is null or @factura=''
		set @error=@error+'No se ingreso un id de factura.'+CHAR(13)+CHAR(10)
	if not exists (select 1 from ventas.Factura where idFactura = @factura)
		set @error=@error+'La factura ingresada no existe'+CHAR(13)+CHAR(10)
	--verificamos que el id de pago no exista en caso que el medio de pago no sea cash
	--si es cash, no tiene idPago
	if (select id from comprobantes.MedioDePago where nombreIng = 'Cash') <> @mp
	begin
		if exists (select 1 from comprobantes.Comprobante where idPago = @idPago)
		begin
			set @error=@error+'El id de pago ya existe'+CHAR(13)+CHAR(10)
		end
	end
	else
		set @idPago = '--'
	--verificamos que la factura no tenga un comprobante asociado ya
	set @idFactura = (select id from ventas.Factura where idFactura = @factura)
	if exists (select 1 from comprobantes.Comprobante where idFactura = @idFactura and tipoComprobante = 'Factura')
		set @error=@error+'La factura ingresada ya tiene un comprobante'+CHAR(13)+CHAR(10)

	if @error <> ''
	begin
		raiserror(@error, 16, 1)
		return
	end

	update ventas.Factura
	set estado = 'Pagada'
	where id = @idFactura
	
	insert into comprobantes.Comprobante(tipoComprobante, idPago, idMedPago, idFactura)
		values('Factura', @idPago, @mp, @idFactura)
end


--EMPLEADO
--CARGO
--LINEAPRODUCTO
--CATEGORIA
--PRODUCTO
--TIPOCLIENTE
--FACTURA (recibe una tabla con los productos a guardar en lineafactura)
--MEDIODEPAGO
--COMPROBANTE
