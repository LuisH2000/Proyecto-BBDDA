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
--SUCURSAL
create or alter proc sucursales.modificarDireccionSucursal
	@id int,
	@nvaDir varchar(100),
	@nvaCiudad varchar(20)
as
begin
	if @nvaDir is null or ltrim(rtrim(@nvaDir)) = ''
	begin
		raiserror('La direccion ingresada esta vacia', 16, 1)
		return
	end

	if exists (select 1 from sucursales.Sucursal where direccion = @nvaDir and ciudad = @nvaCiudad)
	begin
		raiserror('Ya existe una sucursal para la direccion y ciudad ingresada', 16, 1)
		return
	end

	update sucursales.Sucursal
	set
		direccion = @nvaDir,
		ciudad = @nvaCiudad
	where id = @id
end
go

create or alter proc sucursales.darAltaSucursalEnBaja
	@id int
as
begin
	update sucursales.Sucursal
	set
		activo = 1
	where id = @id
end
go

create or alter proc sucursales.modificarHorarioSucursal
	@id int,
	@nvoHorario varchar(50)
as
begin
	if @nvoHorario is null or ltrim(rtrim(@nvoHorario)) = ''
	begin
		raiserror('El horario ingresado esta vacio', 16, 1)
		return
	end

	update sucursales.Sucursal
	set
		horario = @nvoHorario
	where id = @id
end
go

create or alter proc sucursales.modificarTelefonoSucursal
	@id int,
	@nvoTelefono char(9)
as
begin
	if @nvoTelefono is null or ltrim(rtrim(@nvoTelefono)) = ''
	begin
		raiserror('El telefono ingresado esta vacio', 16, 1)
		return
	end

	if @nvoTelefono not like ('[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]')
	begin
		raiserror ('El telefono ingresado no es valido, formato te telefono: xxxx-xxxx', 16, 1)
		return
	end

	update sucursales.Sucursal
	set
		telefono = @nvoTelefono
	where id = @id
end
go

--EMPLEADO (acl: todos los SP de empleado van a tener una version donde al empleado se lo identifica por legajo, y otro donde se lo identifica por dni)
	--cambiar nombre
create or alter procedure recursosHumanos.cambiarNombreEmpleadoPorLegajo
@legajo int,
@nombre varchar(50)
as
begin
	declare @error varchar(max)=''
	set @nombre=ltrim(rtrim(@nombre))
	if @nombre='' or @nombre is null
		set @error=@error+'No se ingreso un nombre.'+char(13)+char(10)
	if @legajo is null
		set @error=@error+'No se ingreso un legajo.'+char(13)+char(10)
	else if not exists (select 1 from recursosHumanos.Empleado where legajo=@legajo)
		set @error=@error+'No existe un empleado con el legajo ingresado'+char(13)+char(10)
	if @error<>''
	begin
		raiserror(@error,16,1)
		return
	end
	update recursosHumanos.Empleado
	set nombre=@nombre
	where legajo=@legajo
end
go
--Lo mismo que el anterior nomas que al empleado lo identificas por dni
create or alter procedure recursosHumanos.cambiarNombreEmpleadoPorDni
@dni int,
@nombre varchar(50)
as
begin
	declare @error varchar(max)=''
	set @nombre=ltrim(rtrim(@nombre))
	if @nombre='' or @nombre is null
		set @error=@error+'No se ingreso un nombre.'+char(13)+char(10)
	if @dni is null
		set @error=@error+'No se ingreso un dni.'+char(13)+char(10)
	else if not exists (select 1 from recursosHumanos.Empleado where dni=@dni)
		set @error=@error+'No existe un empleado con el legajo ingresado'+char(13)+char(10)
	if @error<>''
	begin
		raiserror(@error,16,1)
		return
	end
	update recursosHumanos.Empleado
	set nombre=@nombre
	where dni=@dni
end
go
	--cambiar apellido
create or alter procedure recursosHumanos.cambiarApellidoEmpleadoPorLegajo
@legajo int,
@apellido varchar(50)
as
begin
	declare @error varchar(max)=''
	set @apellido=upper(ltrim(rtrim(@apellido)))
	if @apellido='' or @apellido is null
		set @error=@error+'No se ingreso un apellido.'+char(13)+char(10)
	if @legajo is null
		set @error=@error+'No se ingreso un legajo.'+char(13)+char(10)
	else if not exists (select 1 from recursosHumanos.Empleado where legajo=@legajo)
		set @error=@error+'No existe un empleado con el legajo ingresado'+char(13)+char(10)
	if @error<>''
	begin
		raiserror(@error,16,1)
		return
	end
	update recursosHumanos.Empleado
	set apellido=@apellido
	where legajo=@legajo
end
go
--Lo mismo que el anterior nomas que al empleado lo identificas por dni
create or alter procedure recursosHumanos.cambiarApellidoEmpleadoPorDni
@dni int,
@apellido varchar(50)
as
begin
	declare @error varchar(max) = ''
	set @apellido = upper(ltrim(rtrim(@apellido)))
	if @apellido = '' or @apellido is null
		set @error = @error + 'No se ingreso un apellido.' + char(13) + char(10)
	if @dni is null
		set @error = @error + 'No se ingreso un dni.' + char(13) + char(10)
	else if not exists (select 1 from recursosHumanos.Empleado where dni = @dni)
		set @error = @error + 'No existe un empleado con el legajo ingresado' + char(13) + char(10)
	if @error <> ''
	begin
		raiserror(@error, 16, 1)
		return
	end
	update recursosHumanos.Empleado
	set apellido = @apellido
	where dni = @dni
end
go
	--cambiar direccion
--con legajo:
create or alter procedure recursosHumanos.cambiarDireccionEmpleadoPorLegajo
@legajo int,
@direccion varchar(100)
as
begin
	declare @error varchar(max)=''
	set @direccion=ltrim(rtrim(@direccion))
	if @direccion='' or @direccion is null
		set @error=@error+'No se ingreso una direccion.'+char(13)+char(10)
	if @legajo is null
		set @error=@error+'No se ingreso un legajo.'+char(13)+char(10)
	else if not exists (select 1 from recursosHumanos.Empleado where legajo=@legajo)
		set @error=@error+'No existe un empleado con el legajo ingresado'+char(13)+char(10)
	if @error<>''
	begin
		raiserror(@error,16,1)
		return
	end
	update recursosHumanos.Empleado
	set direccion=@direccion
	where legajo=@legajo
end
go
--con dni:
CREATE OR ALTER PROCEDURE recursosHumanos.cambiarDireccionEmpleadoPorDni
@dni INT,
@direccion VARCHAR(100)
AS
BEGIN
    DECLARE @error VARCHAR(MAX) = ''
    SET @direccion = LTRIM(RTRIM(@direccion))

    IF @direccion = '' OR @direccion IS NULL
        SET @error = @error + 'No se ingresó una dirección.' + CHAR(13) + CHAR(10)
    IF @dni IS NULL
        SET @error = @error + 'No se ingresó un DNI.' + CHAR(13) + CHAR(10)
    ELSE IF NOT EXISTS (SELECT 1 FROM recursosHumanos.Empleado WHERE dni = @dni)
        SET @error = @error + 'No existe un empleado con el DNI ingresado.' + CHAR(13) + CHAR(10)

    IF @error <> ''
    BEGIN
        RAISERROR(@error, 16, 1)
        RETURN
    END

    UPDATE recursosHumanos.Empleado
    SET direccion = @direccion
    WHERE dni = @dni
END
GO


	--cambiar mail personal (Nota: por alguna razon los espacios en los correos de los empleados en realidad son tabs, por eso en el sp los reemplazo por un espacio
	--comun y corriente. char(9) por ' ' . Esto se repite en los sps de correos.)
--usando legajo
create or alter procedure recursosHumanos.cambiarMailPersonalEmpleadoPorLegajo
@legajo int,
@mailPer varchar(60)
as
begin
	declare @error varchar(max)=''
	set @mailPer=rtrim(ltrim(@mailPer))
	if @legajo is null
		set @error=@error+'No se ingreso un legajo.'+char(13)+char(10)
	if @mailPer is null or @mailPer =''
		set @error=@error+'No se ingreso un correo.'+char(13)+char(10)
	if exists (select 1 from recursosHumanos.Empleado where REPLACE(emailPer, CHAR(9), ' ')=@mailPer)
		set @error=@error+'Ya existe un empleado con el correo personal ingresado, ingrese otro.'+char(13)+char(10)
	if not exists (select 1 from recursosHumanos.Empleado where legajo=@legajo)
		set @error=@error+'El empleado ingresado no existe.'+char(13)+char(10)
	if @error<>''
	begin
		raiserror(@error,16,1)
		return
	end
	update recursosHumanos.Empleado
	set emailPer=@mailPer
	where legajo=@legajo
end
go

--usando dni
create or alter procedure recursosHumanos.cambiarMailPersonalEmpleadoPorDni
@dni int,
@mailPer varchar(60)
as
begin
	declare @error varchar(max)=''
	set @mailPer=rtrim(ltrim(@mailPer))
	if @dni is null
		set @error=@error+'No se ingreso un dni.'+char(13)+char(10)
	if @mailPer is null or @mailPer ='' 
		set @error=@error+'No se ingreso un correo.'+char(13)+char(10)
	if exists (select 1 from recursosHumanos.Empleado where REPLACE(emailPer, CHAR(9), ' ')=@mailPer)
		set @error=@error+'Ya existe un empleado con el correo personal ingresado, ingrese otro.'+char(13)+char(10)
	if not exists (select 1 from recursosHumanos.Empleado where dni=@dni)
		set @error=@error+'El empleado ingresado no existe.'+char(13)+char(10)
	if @error<>'' 
	begin
		raiserror(@error,16,1)
		return
	end
	update recursosHumanos.Empleado
	set emailPer=@mailPer
	where dni=@dni
end
go

	--cambiar mail empresaria
--usando legajo
create or alter procedure recursosHumanos.cambiarMailEmpresarialEmpleadoPorLegajo
@legajo int,
@mailEmp varchar(60)
as
begin
	declare @error varchar(max)=''
	set @mailEmp=rtrim(ltrim(@mailEmp))
	if @legajo is null
		set @error=@error+'No se ingreso un legajo.'+char(13)+char(10)
	if @mailEmp is null or @mailEmp =''
		set @error=@error+'No se ingreso un correo.'+char(13)+char(10)
	if exists (select 1 from recursosHumanos.Empleado where REPLACE(emailEmp, CHAR(9), ' ')=@mailEmp)
		set @error=@error+'Ya existe un empleado con el correo empresarial ingresado, ingrese otro.'+char(13)+char(10)
	if not exists (select 1 from recursosHumanos.Empleado where legajo=@legajo)
		set @error=@error+'El empleado ingresado no existe.'+char(13)+char(10)
	if @error<>''
	begin
		raiserror(@error,16,1)
		return
	end
	update recursosHumanos.Empleado
	set emailEmp=@mailEmp
	where legajo=@legajo
end
go

--usando dni
create or alter procedure recursosHumanos.cambiarMailEmpresarialEmpleadoPorDni
@dni int,
@mailEmp varchar(60)
as
begin
	declare @error varchar(max)=''
	set @mailEmp = rtrim(ltrim(@mailEmp))
	if @dni is null
		set @error = @error + 'No se ingresó un DNI.' + char(13) + char(10)
	if @mailEmp is null or @mailEmp = ''
		set @error = @error + 'No se ingresó un correo.' + char(13) + char(10)
	if exists (select 1 from recursosHumanos.Empleado where REPLACE(emailEmp, CHAR(9), ' ') = @mailEmp)
		set @error = @error + 'Ya existe un empleado con el correo empresarial ingresado, ingrese otro.' + char(13) + char(10)
	if not exists (select 1 from recursosHumanos.Empleado where dni = @dni)
		set @error = @error + 'El empleado ingresado no existe.' + char(13) + char(10)
	if @error <> ''
	begin
		raiserror(@error, 16, 1)
		return
	end
	update recursosHumanos.Empleado
	set emailEmp = @mailEmp
	where dni = @dni
end
go
	--cambiar cargo de un empleado
--usando legajo
create or alter procedure recursosHumanos.cambiarCargoEmpleadoPorLegajo
@legajo int,
@cargo varchar(20)
as
begin
	declare @error varchar(max)=''
	declare @idCargo int
	set @cargo=ltrim(rtrim(@cargo))
	if @cargo is null or @cargo=''
		set @error=@error+'No se ingreso un cargo.'+char(13)+char(10)
	else
	begin
		set @idCargo=(select id from recursosHumanos.cargo where cargo=@cargo)
		if @idCargo is null
		set @error=@error+'El cargo ingresado no existe.'+char(13)+char(10)
	end
	if @legajo is null
		set @error=@error+'No se ingreso un legajo.'+char(13)+char(10)
	else if not exists(select 1 from recursosHumanos.Empleado where legajo=@legajo)
		set @error=@error+'El empleado ingresado no existe.'+char(13)+char(10)
	if @error<>''
	begin
		raiserror(@error,16,1)
		return
	end
	update recursosHumanos.Empleado
	set cargo=@idCargo
	where legajo=@legajo
end
go
--usando dni
create or alter procedure recursosHumanos.cambiarCargoEmpleadoPorDni
@dni int,
@cargo varchar(20)
as
begin
	declare @error varchar(max) = ''
	declare @idCargo int
	set @cargo = ltrim(rtrim(@cargo))
	
	if @cargo is null or @cargo = ''
		set @error = @error + 'No se ingreso un cargo.' + char(13) + char(10)
	else
	begin
		set @idCargo = (select id from recursosHumanos.cargo where cargo = @cargo)
		if @idCargo is null
			set @error = @error + 'El cargo ingresado no existe.' + char(13) + char(10)
	end
	
	if @dni is null
		set @error = @error + 'No se ingreso un dni.' + char(13) + char(10)
	else if not exists(select 1 from recursosHumanos.Empleado where dni = @dni)
		set @error = @error + 'El empleado ingresado no existe.' + char(13) + char(10)
	
	if @error <> ''
	begin
		raiserror(@error, 16, 1)
		return
	end
	
	update recursosHumanos.Empleado
	set cargo = @idCargo
	where dni = @dni
end
go
	--cambiar sucursal empleado
--con legajo
create or alter procedure recursosHumanos.cambiarSucursalEmpleadoPorLegajo
@legajo int,
@idSucursal int
as
begin
	declare @error varchar(max) = ''
	if @legajo is null
		set @error=@error+'No se ingreso un legajo.'+char(13)+char(10)
	else if not exists (select 1 from recursosHumanos.empleado where legajo=@legajo)
		set @error=@error+'El legajo ingresado no se encuentra registrado.'+char(13)+char(10)
	if @idSucursal is null
		set @error=@error+'No se ingreso una id de sucursal.'+char(13)+char(10)
	else if not exists(select 1 from sucursales.sucursal where id=@idSucursal)
		set @error=@error+'La sucursal ingresada no existe.'+char(13)+char(10)
	if @error<>''
	begin
		raiserror(@error,16,1)
		return
	end
	update recursosHumanos.empleado
	set idSucursal=@idSucursal
	where legajo=@legajo
end
go
-- con dni
create or alter procedure recursosHumanos.cambiarSucursalEmpleadoPorDni
@dni int,
@idSucursal int
as
begin
	declare @error varchar(max) = ''
	if @dni is null
		set @error=@error+'No se ingreso un DNI.'+char(13)+char(10)
	else if not exists (select 1 from recursosHumanos.empleado where dni=@dni)
		set @error=@error+'El DNI ingresado no se encuentra registrado.'+char(13)+char(10)
	if @idSucursal is null
		set @error=@error+'No se ingreso una id de sucursal.'+char(13)+char(10)
	else if not exists(select 1 from sucursales.sucursal where id=@idSucursal)
		set @error=@error+'La sucursal ingresada no existe.'+char(13)+char(10)
	if @error<>'' 
	begin
		raiserror(@error,16,1)
		return
	end
	update recursosHumanos.empleado
	set idSucursal=@idSucursal
	where dni=@dni
end
go
	--cambiar turno de empleado
--con legajo
create or alter procedure recursosHumanos.cambiarTurnoEmpleadoPorLegajo
@legajo int,
@turno varchar(20)
as
begin
	declare @error varchar(max) = ''
	set @turno=ltrim(rtrim(@turno))
	if @legajo is null or not exists (select 1 from recursosHumanos.Empleado where legajo=@legajo)
		set @error=@error+'No se ingreso un legajo o no existe'+char(13)+char(10)
	if @turno is null or @turno=''
		set @error=@error+'No se ingreso un turno.'+char(13)+char(10)
	else if @turno not in ('TM','TT','Jornada Completa')
		set @error=@error+'El turno ingresado no es valido, debe ser TM, TT o Jornada Completa'+char(13)+char(10)
	if @error<>''
	begin
		raiserror(@error,16,1)
		return
	end
	update recursosHumanos.Empleado
	set turno=@turno
	where legajo=@legajo
end
go

--usando dni
create or alter procedure recursosHumanos.cambiarTurnoEmpleadoPorDni
@dni int,
@turno varchar(20)
as
begin
	declare @error varchar(max) = ''
	set @turno=ltrim(rtrim(@turno))
	if @dni is null or not exists (select 1 from recursosHumanos.Empleado where dni=@dni)
		set @error=@error+'No se ingreso un DNI o no existe'+char(13)+char(10)
	if @turno is null or @turno=''
		set @error=@error+'No se ingreso un turno.'+char(13)+char(10)
	else if @turno not in ('TM','TT','Jornada Completa')
		set @error=@error+'El turno ingresado no es valido, debe ser TM, TT o Jornada Completa'+char(13)+char(10)
	if @error<>'' 
	begin
		raiserror(@error,16,1)
		return
	end
	update recursosHumanos.Empleado
	set turno=@turno
	where dni=@dni
end
go

	--dar de alta empleado que estaba de baja
--usando legajo
create or alter procedure recursosHumanos.darDeAltaEmpleadoPorLegajo
@legajo int
as
begin
	if @legajo is null or not exists(select 1 from recursosHumanos.empleado where legajo=@legajo)
	begin
		raiserror('No se ingreso un legajo o no existe.',16,1)
		return
	end
	update recursosHumanos.empleado
	set activo=1
	where legajo=@legajo
end
go
--usando dni
create or alter procedure recursosHumanos.darDeAltaEmpleadoPorDni
@dni int
as
begin
	if @dni is null or not exists(select 1 from recursosHumanos.empleado where dni=@dni)
	begin
		raiserror('No se ingreso un dni o no existe.',16,1)
		return
	end
	update recursosHumanos.empleado
	set activo=1
	where dni=@dni
end
go
--CARGO, creo que no cambiamos nada
--LINEAPRODUCTO
	--cambiar nombre de linea
--PRODUCTO
	--cambiar nombre
	--cambiar precio
	--cambiar precio por categoria
	--cambiar precioRef
	--cambiar fecha
	--dar de alta producto que estaba en baja
--CATEGORIA
	--cambiar nombre
	--cambiar la linea a la que pertenece
--TIPOCLIENTE, creo que no cambiamos nada
--FACTURA , creo que no cambiamos nada
--MEDIODEPAGO, creo que no cambiamos nada
--COMPROBANTE, creo que no cambiamos nada