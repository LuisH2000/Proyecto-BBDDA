use [Com5600G13]
go
--SUCURSAL
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
select * from sucursales.sucursal
--EMPLEADO
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
select * from recursosHumanos.Empleado
select * from recursosHumanos.cargo
select * from sucursales.Sucursal
--EMPLEADO
--CARGO
--LINEAPRODUCTO
--PRODUCTO
--CATEGORIA
--TIPOCLIENTE
--FACTURA (recibe una tabla con los productos a guardar en lineafactura)
--MEDIODEPAGO
--COMPROBANTE
