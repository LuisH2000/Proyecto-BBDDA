/*
Fecha de Entrega: 29/11/2024
Comision: 5600
Grupo 13
Bases de Datos Aplicadas

Alumnos:
	- Diaz, Nicolas 41714473
	- Huang, Luis 43098142

**ENUNCIADO**
Genere store procedures para manejar la inserción, modificado, borrado (si corresponde, 
también debe decidir si determinadas entidades solo admitirán borrado lógico) de cada tabla. 
Los nombres de los store procedures NO deben comenzar con “SP”.  
*/

use Com5600G13
go
---***SUCURSAL***
create or alter proc sucursales.modificarDireccionSucursal
	@id int,
	@nvaDir varchar(100),
	@nvaCiudad varchar(20)
as
begin
	declare @error varchar(200) = ''
	if @nvaDir is null or ltrim(rtrim(@nvaDir)) = ''
		set @error = @error + 'La direccion ingresada esta vacia' + char(13) + char(10)
	if not exists (select 1 from sucursales.Sucursal where id = @id)
		set @error = @error + 'El id de la sucursal ingresada no existe' + char(13) + char(10)
	else
		if exists (select 1 from sucursales.Sucursal where direccion = @nvaDir and ciudad = @nvaCiudad)
			set @error = @error + 'Ya existe una sucursal para la direccion y ciudad ingresada' + char(13) + char(10)
	
	if @error <> ''
	begin
		raiserror(@error, 16, 1)
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
	if not exists (select 1 from sucursales.Sucursal where id = @id)
	begin
		raiserror('El id de la sucursal ingresada no existe', 16, 1)
		return
	end

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
	declare @error varchar(200) = ''

	if not exists (select 1 from sucursales.Sucursal where id = @id)
		set @error = @error + 'El id de la sucursal ingresada no existe' + char(13) + char(10)
	
	if @nvoHorario is null or ltrim(rtrim(@nvoHorario)) = ''
		set @error = @error + 'El horario ingresado esta vacio' + char(13) + char(10)

	if @error <> ''
	begin
		raiserror(@error, 16, 1)
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
	declare @error varchar(200) = ''

	if not exists (select 1 from sucursales.Sucursal where id = @id)
		set @error = @error + 'El id de la sucursal ingresada no existe' + char(13) + char(10)
	
	if @nvoTelefono is null or ltrim(rtrim(@nvoTelefono)) = ''
		set @error = @error + 'El telefono ingresado esta vacio' + char(13) + char(10)

	if @nvoTelefono not like ('[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]')
		set @error = @error + 'El telefono ingresado no es valido, formato te telefono: xxxx-xxxx' + char(13) + char(10)

	if @error <> ''
	begin
		raiserror(@error, 16, 1)
		return
	end

	update sucursales.Sucursal
	set
		telefono = @nvoTelefono
	where id = @id
end
go

---***EMPLEADO*** (acl: todos los SP de empleado van a tener una version donde al empleado se lo identifica por legajo, y otro donde se lo identifica por dni)
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
---***CARGO***
create or alter proc recursosHumanos.modificarNombreCargo
	@idCargo int,
	@nvoNombre varchar(20)
as
begin
	declare @error varchar(max) = ''
	set @nvoNombre = ltrim(rtrim(@nvoNombre))
	if not exists (select 1 from recursosHumanos.Cargo where id = @idCargo)
		set @error = @error + 'El id de cargo ingresado no existe' + char(13) + char(10)
	if @nvoNombre is null or @nvoNombre = ''
		set @error = @error + 'El nombre ingresado es invalido' + char(13) + char(10)
	else
		if exists (select 1 from recursosHumanos.Cargo where cargo = @nvoNombre)
			set @error = @error + 'Ya existe un cargo con ese nombre' + char(13) + char(10)
	
	if @error <> ''
	begin
		raiserror(@error, 16, 1)
		return
	end

	update recursosHumanos.Cargo
	set cargo = @nvoNombre
	where id = @idCargo
		
end
go

--***LINEAPRODUCTO***
create or alter proc catalogo.modificarNombreLineaProducto
	@idLn int,
	@nvoNombre varchar(10)
as
begin
	declare @error varchar(max) = ''
	set @nvoNombre = ltrim(rtrim(@nvoNombre))
	if not exists (select 1 from catalogo.LineaProducto where id = @idLn)
		set @error = @error + 'El id de linea de producto ingresado no existe' + char(13) + char(10)
	if @nvoNombre is null or @nvoNombre = ''
		set @error = @error + 'El nombre ingresado no es valido' + char(13) + char(10)
	else
		if exists (select 1 from catalogo.LineaProducto where lineaProd = @nvoNombre)
			set @error = @error + 'Ya existe una linea de producto con ese nombre' + char(13) + char(10)
	
	if @error <> ''
	begin
		raiserror(@error, 16, 1)
		return
	end

	update catalogo.LineaProducto
	set lineaProd = @nvoNombre
	where id = @idLn
end
go

--***TIPOCLIENTE***
create or alter proc clientes.modificarNombreTipoCliente
	@idTipo int,
	@nvoNombre char(6)
as
begin
	declare @error varchar(max) = ''
	set @nvoNombre = ltrim(rtrim(@nvoNombre))
	if not exists (select 1 from clientes.TipoCliente where id = @idTipo)
		set @error = @error + 'El id de tipo de cliente ingresado no existe' + char(13) + char(10)
	if @nvoNombre is null or @nvoNombre = ''
		set @error = @error + 'El nombre ingresado no es valido' + char(13) + char(10)
	else
		if exists (select 1 from clientes.TipoCliente where tipo = @nvoNombre)
			set @error = @error + 'Ya existe un tipo de cliente con ese nombre' + char(13) + char(10)
	
	if @error <> ''
	begin
		raiserror(@error, 16, 1)
		return
	end

	update clientes.TipoCliente
	set tipo = @nvoNombre
	where id = @idTipo
end
go



--***CATEGORIA***
create or alter proc catalogo.modificarNombreCategoria
	@idCat int,
	@nvoNombre varchar(50)
as
begin
	declare @error varchar(max) = ''
	set @nvoNombre = ltrim(rtrim(@nvoNombre))
	if not exists (select 1 from catalogo.Categoria where id = @idCat)
		set @error = @error + 'El id de la categoria ingresada no existe' + char(13) + char(10)
	if @nvoNombre is null or @nvoNombre = ''
		set @error = @error + 'El nombre ingresado no es valido' + char(13) + char(10)
	else
		if exists (select 1 from catalogo.Categoria where categoria = @nvoNombre)
			set @error = @error + 'Ya existe una categoria con ese nombre' + char(13) + char(10)
	
	if @error <> ''
	begin
		raiserror(@error, 16, 1)
		return
	end

	update catalogo.Categoria
	set categoria = @nvoNombre
	where id = @idCat
end
go

create or alter proc catalogo.modificarLineaDeCategoria
	@idCat int,
	@idLin int
as
begin
	declare @error varchar(200) = ''
	
	if not exists (select 1 from catalogo.Categoria where id = @idCat)
		set @error = @error + 'El id de la categoria ingresada no existe' + char(13) + char(10)
	if not exists (select 1 from catalogo.LineaProducto where id = @idLin)
		set @error = @error + 'El id de la linea de producto ingresada no es valida' + char(13) + char(10)

	if @error <> ''
	begin
		raiserror(@error, 16, 1)
		return
	end

	update catalogo.Categoria
	set idLineaProd = @idLin
	where id = @idCat

end
go
--***MEDIODEPAGO***
create or alter proc comprobantes.modificarNombresMedioPago
	@idMp int,
	@nvoNomIng varchar(11),
	@nvoNomEsp varchar(22)
as
begin
	declare @error varchar(200) = ''
	set @nvoNomEsp = ltrim(rtrim(@nvoNomEsp))
	set @nvoNomIng = ltrim(rtrim(@nvoNomIng))

	if not exists (select 1 from comprobantes.MedioDePago where id = @idMp)
		set @error = @error + 'El id del medio de pago ingresado no existe' + char(13) + char(10)
	if @nvoNomEsp is null or @nvoNomEsp = ''
		set @error = @error + 'El nombre en español ingresado no es valido' + char(13) + char(10)
	else
		if exists (select 1 from comprobantes.MedioDePago where nombreEsp = @nvoNomEsp)
			set @error = @error + 'El nombre en español ingresado ya existe' + char(13) + char(10)
	if @nvoNomIng is null or @nvoNomIng = ''
		set @error = @error + 'El nombre en español ingresado no es valido' + char(13) + char(10)
	else
		if exists (select 1 from comprobantes.MedioDePago where nombreIng = @nvoNomIng)
			set @error = @error + 'El nombre en ingles ingresado ya existe' + char(13) + char(10)

	if @error <> ''
	begin
		raiserror(@error, 16, 1)
		return
	end

	update comprobantes.MedioDePago
	set nombreEsp = @nvoNomEsp,
		nombreIng = @nvoNomIng
	where id = @idMp
end
go

create or alter proc comprobantes.darAltaMedioDePagoEnBaja
@idMp int
as
begin
	if @idMp is null or not exists(select 1 from comprobantes.MedioDePago where id=@idMp)
	begin
		raiserror('No se ingreso un medio de pago o no existe',16,1)
		return
	end
	update comprobantes.MedioDePago
	set activo=1
	where id=@idMp
end
go
--***PRODUCTO***
create or alter proc catalogo.modificarPrecioProducto
	@idProd int,
	@nvoPrecio decimal(9,2)
as
begin
	declare @error varchar(200) = ''

	if @idProd is null or not exists (select 1 from catalogo.Producto where id = @idProd)
		set @error = @error + 'El id del producto ingresado no existe' + char(13) + char(10)
	if @nvoPrecio <= 0 or @nvoPrecio is null
		set @error = @error + 'EL precio ingresado no es valido' + char(13) + char(10)

	if @error <> ''
	begin
		raiserror(@error, 16, 1)
		return
	end

	update catalogo.Producto
	set precio = @nvoPrecio
	where id = @idProd
end
go

create or alter proc catalogo.modificarPrecioUSDProducto
	@idProd int,
	@nvoPrecio decimal(9,2)
as
begin
	declare @error varchar(200) = ''

	if @idProd is null or not exists (select 1 from catalogo.Producto where id = @idProd)
		set @error = @error + 'El id del producto ingresado no existe' + char(13) + char(10)
	if @nvoPrecio <= 0 or @nvoPrecio is null
		set @error = @error + 'EL precio ingresado no es valido' + char(13) + char(10)

	if @error <> ''
	begin
		raiserror(@error, 16, 1)
		return
	end

	update catalogo.Producto
	set precioUSD = @nvoPrecio
	where id = @idProd
end
go

create or alter proc catalogo.modificarPrecioReferenciaProducto
	@idProd int,
	@nvoPrecio decimal(9,2)
as
begin
	declare @error varchar(200) = ''

	if @idProd is null or not exists (select 1 from catalogo.Producto where id = @idProd)
		set @error = @error + 'El id del producto ingresado no existe' + char(13) + char(10)
	if @nvoPrecio <= 0 or @nvoPrecio is null
		set @error = @error + 'EL precio ingresado no es valido' + char(13) + char(10)

	if @error <> ''
	begin
		raiserror(@error, 16, 1)
		return
	end

	update catalogo.Producto
	set precioRef = @nvoPrecio
	where id = @idProd
end
go

create or alter proc catalogo.modificarFechaProducto
	@idProd int,
	@fechaYHora smalldatetime
as
begin
	declare @error varchar(200) = ''

	if @idProd is null or not exists (select 1 from catalogo.Producto where id = @idProd)
		set @error = @error + 'El id del producto ingresado no existe' + char(13) + char(10)
	else
		if (select datediff(day, fecha, @fechaYHora) from catalogo.Producto where id = @idProd) < 0
			set @error = @error + 'La fecha ingresada es anterior a la fecha que tiene asociada el producto' + char(13) + char(10)

	if @error <> ''
	begin
		raiserror(@error, 16, 1)
		return
	end

	update catalogo.Producto
	set fecha = @fechaYHora
	where id = @idProd
end
go

create or alter proc catalogo.darAltaProductoEnBaja
	@idProd int
as
begin
	if @idProd is null or not exists (select 1 from catalogo.Producto where id = @idProd)
	begin
		raiserror('El id del producto ingresado no existe', 16, 1)
		return
	end

	update catalogo.Producto set activo = 1 where id = @idProd
end
go

create or alter proc catalogo.aumentarPrecioProductoPorCategoria
@idCategoria int,
@porcentaje int
as
begin
	declare @error varchar(max)=''
	declare @mult decimal(5,4)
	if @idCategoria is null
		set @error=@error+'No se ingreso un id de categoria.'+char(13)+char(10)
	else if not exists(select 1 from catalogo.categoria where id=@idCategoria)
		set @error=@error+'El id de categoria ingresado no existe.'+char(13)+char(10)
	if @porcentaje is null
		set @error=@error+'No se ingreso un porcentaje de aumento.'+char(13)+char(10)
	else if @porcentaje<=0
		set @error=@error+'El porcentaje debe ser mayor que 0.'+char(13)+char(10)
	if @error<>''
	begin
		raiserror(@error,16,1)
		return
	end
	set @mult=1+@porcentaje/100.0;
	with productosDeLaCategoria (idProd)
	as
	(select p.id from catalogo.Producto p
	inner join catalogo.PerteneceA pa
	on p.id=pa.idProd
	where pa.idCategoria=@idCategoria)
	update catalogo.Producto
	set precio=precio*@mult
	where id in (select idProd from productosDeLaCategoria)
end
go

create or alter proc catalogo.aumentarPrecioUSDProductoPorCategoria
@idCategoria int,
@porcentaje int
as
begin
	declare @error varchar(max)=''
	declare @mult decimal(5,4)
	if @idCategoria is null
		set @error=@error+'No se ingreso un id de categoria.'+char(13)+char(10)
	else if not exists(select 1 from catalogo.categoria where id=@idCategoria)
		set @error=@error+'El id de categoria ingresado no existe.'+char(13)+char(10)
	if @porcentaje is null
		set @error=@error+'No se ingreso un porcentaje de aumento.'+char(13)+char(10)
	else if @porcentaje<=0
		set @error=@error+'El porcentaje debe ser mayor que 0.'+char(13)+char(10)
	if @error<>''
	begin
		raiserror(@error,16,1)
		return
	end
	set @mult=1+@porcentaje/100.0;
	with productosDeLaCategoria (idProd)
	as
	(select p.id from catalogo.Producto p
	inner join catalogo.PerteneceA pa
	on p.id=pa.idProd
	where pa.idCategoria=@idCategoria)
	update catalogo.Producto
	set precioUSD=precioUSD*@mult
	where id in (select idProd from productosDeLaCategoria)
	and precioUSD is not null
end
go

create or alter proc catalogo.reducirPrecioProductoPorCategoria
@idCategoria int,
@porcentaje int
as
begin
	declare @error varchar(max)=''
	declare @mult decimal(5,4)
	if @idCategoria is null
		set @error=@error+'No se ingreso un id de categoria.'+char(13)+char(10)
	else if not exists(select 1 from catalogo.categoria where id=@idCategoria)
		set @error=@error+'El id de categoria ingresado no existe.'+char(13)+char(10)
	if @porcentaje is null
		set @error=@error+'No se ingreso un porcentaje de aumento.'+char(13)+char(10)
	else if @porcentaje<=0 or @porcentaje>=100
		set @error=@error+'El porcentaje debe estar entre 0 y 100 (sin incluir estos).'+char(13)+char(10)
	if @error<>''
	begin
		raiserror(@error,16,1)
		return
	end
	set @mult=@porcentaje/100.0;
	with productosDeLaCategoria (idProd)
	as
	(select p.id from catalogo.Producto p
	inner join catalogo.PerteneceA pa
	on p.id=pa.idProd
	where pa.idCategoria=@idCategoria)
	update catalogo.Producto
	set precio=precio-precio*@mult
	where id in (select idProd from productosDeLaCategoria)
end
go

create or alter proc catalogo.reducirPrecioUSDProductoPorCategoria
@idCategoria int,
@porcentaje int
as
begin
	declare @error varchar(max)=''
	declare @mult decimal(5,4)
	if @idCategoria is null
		set @error=@error+'No se ingreso un id de categoria.'+char(13)+char(10)
	else if not exists(select 1 from catalogo.categoria where id=@idCategoria)
		set @error=@error+'El id de categoria ingresado no existe.'+char(13)+char(10)
	if @porcentaje is null
		set @error=@error+'No se ingreso un porcentaje de aumento.'+char(13)+char(10)
	else if @porcentaje<=0 or @porcentaje>=100
		set @error=@error+'El porcentaje debe estar entre 0 y 100 (sin incluir estos).'+char(13)+char(10)
	if @error<>''
	begin
		raiserror(@error,16,1)
		return
	end
	set @mult=@porcentaje/100.0;
	with productosDeLaCategoria (idProd)
	as
	(select p.id from catalogo.Producto p
	inner join catalogo.PerteneceA pa
	on p.id=pa.idProd
	where pa.idCategoria=@idCategoria)
	update catalogo.Producto
	set precioUSD=precioUSD-precioUSD*@mult
	where id in (select idProd from productosDeLaCategoria)
	and precioUSD is not null
end
go


create or alter proc catalogo.modificarNombreProducto
@idProducto int,
@nombreNvo varchar(100)
as
begin
	declare @error varchar(max)=''
	set @nombreNvo=ltrim(rtrim(@nombreNvo))
	if @idProducto is null
		set @error=@error+'No se ingreso un id de producto.'+char(13)+char(10)
	else if not exists(select 1 from catalogo.producto where id=@idProducto)
		set @error=@error+'El producto ingresado no existe.'+char(13)+char(10)
	if @nombreNvo is null or @nombreNvo=''
		set @error=@error+'No se ingreso un nombre nuevo para el producto.'+char(13)+char(10)
	if @error<>''
	begin
		raiserror(@error,16,1)
		return
	end
	update catalogo.producto
	set nombre=@nombreNvo
	where id=@idProducto
end
go

create or alter proc catalogo.modificarProveedorProducto
@idProducto int,
@proveedorNvo varchar(50)
as
begin
	declare @error varchar(max)=''
	set @proveedorNvo=rtrim(ltrim(@proveedorNvo))
	if @idProducto is null
		set @error=@error+'No se ingreso un id de producto.'+char(13)+char(10)
	else if not exists (select 1 from catalogo.Producto where id=@idProducto)
		set @error=@error+'El producto ingresado no existe.'+char(13)+char(10)
	if @proveedorNvo is null or @proveedorNvo=''
		set @error=@error+'No se ingreso un proveedor nuevo.'+char(13)+char(10)
	if @error<>''
	begin
		raiserror(@error,16,1)
		return
	end
	update catalogo.Producto
	set proveedor=@proveedorNvo
	where id=@idProducto
end
go

create or alter proc catalogo.modificarCantXUnProducto
@idProducto int,
@cantXUn varchar(20)
as
begin
	declare @error varchar(max)=''
	set @cantXUn=rtrim(ltrim(@cantXUn))
	if @idProducto is null
		set @error=@error+'No se ingreso un id de producto.'+char(13)+char(10)
	else if not exists (select 1 from catalogo.Producto where id=@idProducto)
		set @error=@error+'El producto ingresado no existe.'+char(13)+char(10)
	if @cantXUn is null or @cantXUn=''
		set @error=@error+'No se ingreso la cantidad por unidad nueva.'+char(13)+char(10)
	if @error<>''
	begin
		raiserror(@error,16,1)
		return
	end
	update catalogo.Producto
	set cantXUn=@cantXUn
	where id=@idProducto
end
go

--PERTENECEA
create or alter proc catalogo.modificarCategoriaDeProducto
@idProd int,
@idCatAnt int,
@idCatNvo int
as
begin
	declare @error varchar(max)=''
	if @idProd is null
		set @error=@error+'No se ingreso un id de producto'+char(13)+char(10)
	else if not exists(select 1 from catalogo.Producto where id=@idProd)
		set @error=@error+'El id de producto ingresado no existe.'+char(13)+char(10)
	if @idCatNvo is null
		set @error=@error+'No se ingreso el id de la nueva categoria.'+char(13)+char(10)
	else if not exists(select 1 from catalogo.categoria where id=@idCatNvo)
		set @error=@error+'El id de la nueva categoria ingresada no existe.'+char(13)+char(10)
	if @idCatAnt is null
		set @error=@error+'No se ingreso el id de la anterior categoria.'+char(13)+char(10)
	else if not exists(select 1 from catalogo.categoria where id=@idCatAnt)
		set @error=@error+'El id de la anterior categoria ingresada no existe.'+char(13)+char(10)
	if not exists (select 1 from catalogo.PerteneceA where idProd = @idProd and idCategoria = idCategoria)
		set @error=@error+'El producto no pertenecia a la categoria ingresada'+char(13)+char(10)

	if @error<>''
	begin
		raiserror(@error,16,1)
		return
	end
	update catalogo.PerteneceA
	set idCategoria=@idCatNvo
	where idProd=@idProd and idCategoria = @idCatAnt
end
go

--CLIENTE
--cambiar tipo de cliente de un cliente
create or alter procedure clientes.cambiarTipoCliente
@idCli int,
@idTipoNvo int
as
begin
	declare @error varchar(max)=''
	--verificamos que los datos no sean nulos, que el cliente exista y que el tipo de cliente exista.
	if @idCli is null or not exists(select 1 from clientes.cliente where id=@idCli)
		set @error=@error+'No se ingreso un id de cliente o no existe.'+char(13)+char(10)
	if @idTipoNvo is null or not exists(select 1 from clientes.TipoCliente where id=@idTipoNvo)
		set @error=@error+'No se ingreso un id de tipo de cliente o no existe.'+char(13)+char(10)
	if @error<>''
	begin
		raiserror(@error,16,1)
		return
	end
	update clientes.Cliente
	set idTipo=@idTipoNvo
	where id=@idCli
end
go
--pasar todos los clientes de un tipo a otro tipo (podria ser util en conjunto con clientes.borrartipodecliente en caso de que se de de baja un tipo de cliente,
--y quieras pasar esos clientes a su nuevo tipo, ej: el tipo de cliente member se descontinua y debes pasar todos a normal)
create or alter procedure clientes.cambiarClientesDeUnTipoAOtro
@idTipoViejo int,
@idTipoNvo int
as
begin
	declare @error varchar(max)=''
	--verificamos que tanto el tipo de cliente actual como el nuevo existan y no sean null.
	if @idTipoViejo is null or not exists(select 1 from clientes.TipoCliente where id=@idTipoViejo)
		set @error=@error+'El id de tipo de cliente actual ingresado no existe.'+char(13)+char(10)
	if @idTipoNvo is null or not exists(select 1 from clientes.TipoCliente where id=@idTipoNvo)
		set @error=@error+'El id de tipo de cliente nuevo ingresado no existe.'+char(13)+char(10)
	if @error<>''
	begin
		raiserror(@error,16,1)
		return
	end
	update clientes.Cliente
	set idTipo=@idTipoNvo
	where idTipo=@idTipoViejo
end
go

--cambiar nombre de cliente
create or alter procedure clientes.cambiarNombreCliente
@idCli int,
@nombreNvo varchar(50)
as
begin
	declare @error varchar(max)=''
	--normalizamos el nombre
	set @nombreNvo=ltrim(rtrim(@nombreNvo))
	--Verificamos que el cliente exista y que el nombre sea valido
	if @idCli is null or not exists (select 1 from clientes.cliente where id=@idCli)
		set @error=@error+'No se ingreso un id de cliente o no existe.'+char(13)+char(10)
	if @nombreNvo is null or @nombreNvo=''
		set @error=@error+'No se ingreso un nombre nuevo para el cliente.'+char(13)+char(10)
	if @error<>''
	begin
		raiserror(@error,16,1)
		return
	end
	update clientes.cliente
	set nombre=@nombreNvo
	where id=@idCli
end
go
--cambiar apellido de cliente
create or alter procedure clientes.cambiarApellidoCliente
@idCli int,
@apellidoNvo varchar(50)
as
begin
	declare @error varchar(max)=''
	--normalizamos el nombre
	set @apellidoNvo=ltrim(rtrim(@apellidoNvo))
	--Verificamos que el cliente exista y que el nombre sea valido
	if @idCli is null or not exists (select 1 from clientes.cliente where id=@idCli)
		set @error=@error+'No se ingreso un id de cliente o no existe.'+char(13)+char(10)
	if @apellidoNvo is null or @apellidoNvo=''
		set @error=@error+'No se ingreso un apellido nuevo para el cliente.'+char(13)+char(10)
	if @error<>''
	begin
		raiserror(@error,16,1)
		return
	end
	update clientes.cliente
	set apellido=@apellidoNvo
	where id=@idCli
end
go

--cambiar ciudad de cliente
create or alter procedure clientes.cambiarCiudadCliente
@idCli int,
@ciudadNva varchar(20)
as
begin
	declare @error varchar(max)=''
	--normalizamos el nombre
	set @ciudadNva=ltrim(rtrim(@ciudadNva))
	--Verificamos que el cliente exista y que el nombre sea valido
	if @idCli is null or not exists (select 1 from clientes.cliente where id=@idCli)
		set @error=@error+'No se ingreso un id de cliente o no existe.'+char(13)+char(10)
	if @ciudadNva is null or @ciudadNva=''
		set @error=@error+'No se ingreso una ciudad nueva para el cliente.'+char(13)+char(10)
	if @error<>''
	begin
		raiserror(@error,16,1)
		return
	end
	update clientes.cliente
	set ciudad=@ciudadNva
	where id=@idCli
end
go

--cambiar genero de cliente
create or alter procedure clientes.cambiarGeneroCliente
@idCli int,
@generoNvo char(6)
as
begin
	declare @error varchar(max)=''
	--normalizamos el nombre
	set @generoNvo=ltrim(rtrim(@generoNvo))
	--Verificamos que el cliente exista y que el nombre sea valido
	if @idCli is null or not exists (select 1 from clientes.cliente where id=@idCli)
		set @error=@error+'No se ingreso un id de cliente o no existe.'+char(13)+char(10)
	if @generoNvo is null or @generoNvo=''
		set @error=@error+'No se ingreso un genero nuevo para el cliente.'+char(13)+char(10)
	else if @generoNvo not in ('Male','Female')
		set @error=@error+'El genero debe ser Male o Female.'+char(13)+char(10)
	if @error<>''
	begin
		raiserror(@error,16,1)
		return
	end
	update clientes.cliente
	set genero=@generoNvo
	where id=@idCli
end
go

create or alter proc clientes.darAltaClienteEnBaja
	@id int
as
begin
	if @id is null or not exists(select 1 from clientes.Cliente where id = @id)
	begin
		raiserror('No se ingreso el cliente o no existe.', 16, 1)
		return
	end

	update clientes.Cliente
		set activo = 1
	where id = @id
end
go

--cambiar dni cliente
create or alter proc clientes.cambiarDNICliente
	@idCli int,
	@nvoDNI int
as
begin
	declare @error varchar(max)=''
	if @idCli is null or not exists (select 1 from clientes.cliente where id=@idCli)
		set @error=@error+'No se ingreso un id de cliente o no existe.'+char(13)+char(10)
	if @nvoDNI is null or @nvoDNI < 0
		set @error=@error+'No se ingreso un dni valido'+char(13)+char(10)
	else 
		if exists (select 1 from clientes.Cliente where dni = @nvoDNI)
			set @error=@error+'Ya existe un cliente con el dni ingresado'+char(13)+char(10)

	if @error<>''
	begin
		raiserror(@error,16,1)
		return
	end

	update clientes.cliente
	set dni=@nvoDNI
	where id=@idCli
end
go

--FACTURA
--modificar el id de la factura
create or alter proc ventas.modificarIdFactura
	@id int,
	@idFactura char(11)
as
begin
	declare @error varchar(200) = ''
	if @id is null
		set @error=@error+'No ingreso el id de la factura'+char(13)+char(10)
	else
		if not exists (select 1 from ventas.Factura where id = @id)
			set @error=@error+'La factura ingresada no existe'+char(13)+char(10)
		else
			if (select estado from ventas.Factura where id = @id) = 'Pagada'
				set @error=@error+'No se puede modificar una factura pagada'+char(13)+char(10)

	if @idFactura is null
		set @error=@error+'No se ingreso el nuevo idFactura'+char(13)+char(10)
	else
		if @idFactura not like ('[0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9]')
			set @error=@error+'EL idFactura ingresado no es valido, respetar el formato xxx-xx-xxxx'+char(13)+char(10)
		else
			if exists (select 1 from ventas.Factura where idFactura = @idFactura)
				set @error=@error+'EL idFactura ingresado ya esta asociada a otra factura'+char(13)+char(10)


	if @error <> ''
	begin
		raiserror(@error, 16, 1)
		return
	end

	update ventas.Factura
		set idFactura = @idFactura
	where id = @id
end
go

--modificar el tipo de la factura
create or alter proc ventas.modificarTipoFactura
	@id int,
	@tipoFactura char(1)
as
begin
	declare @error varchar(200) = ''
	set @tipoFactura = upper(@tipoFactura)
	if @id is null
		set @error=@error+'No ingreso el id de la factura'+char(13)+char(10)
	else
		if not exists (select 1 from ventas.Factura where id = @id)
			set @error=@error+'La factura ingresada no existe'+char(13)+char(10)
		else
			if (select estado from ventas.Factura where id = @id) = 'Pagada'
				set @error=@error+'No se puede modificar una factura pagada'+char(13)+char(10)

	if @tipoFactura is null
		set @error=@error+'No se ingreso el tipo de factura'+char(13)+char(10)
	else
		if @tipoFactura not in ('A', 'B', 'C')
			set @error=@error+'El tipo de factura ingresado no es valido, puede ser A, B o C'+char(13)+char(10)
	
	if @error <> ''
	begin
		raiserror(@error, 16, 1)
		return
	end

	update ventas.Factura
		set tipoFactura = @tipoFactura
	where id = @id
end
go

--modificar la fecha
create or alter proc ventas.modificarFechaFactura
	@id int,
	@fecha date
as
begin
	declare @error varchar(200) = ''
	if @id is null
		set @error=@error+'No ingreso el id de la factura'+char(13)+char(10)
	else
		if not exists (select 1 from ventas.Factura where id = @id)
			set @error=@error+'La factura ingresada no existe'+char(13)+char(10)
		else
			if (select estado from ventas.Factura where id = @id) = 'Pagada'
				set @error=@error+'No se puede modificar una factura pagada'+char(13)+char(10)

	if @fecha is null
		set @error=@error+'No se ingreso la fecha'+char(13)+char(10)

	if @error <> ''
	begin
		raiserror(@error, 16, 1)
		return
	end

	update ventas.Factura
		set fecha = @fecha
	where id = @id
end
go

--modificar la hora
create or alter proc ventas.modificarHoraFactura
	@id int,
	@hora time
as
begin
	declare @error varchar(200) = ''
	if @id is null
		set @error=@error+'No ingreso el id de la factura'+char(13)+char(10)
	else
		if not exists (select 1 from ventas.Factura where id = @id)
			set @error=@error+'La factura ingresada no existe'+char(13)+char(10)
		else
			if (select estado from ventas.Factura where id = @id) = 'Pagada'
				set @error=@error+'No se puede modificar una factura pagada'+char(13)+char(10)

	if @hora is null
		set @error=@error+'No se ingreso la hora'+char(13)+char(10)

	if @error <> ''
	begin
		raiserror(@error, 16, 1)
		return
	end

	update ventas.Factura
		set hora = @hora
	where id = @id
end
go

--modificar el empleado
create or alter proc ventas.modificarEmpleadoDeFactura
	@id int,
	@legajoEmp int
as
begin
	declare @error varchar(200) = ''
	if @id is null
		set @error=@error+'No ingreso el id de la factura'+char(13)+char(10)
	else
		if not exists (select 1 from ventas.Factura where id = @id)
			set @error=@error+'La factura ingresada no existe'+char(13)+char(10)
		else
			if (select estado from ventas.Factura where id = @id) = 'Pagada'
				set @error=@error+'No se puede modificar una factura pagada'+char(13)+char(10)

	if @legajoEmp is null
		set @error=@error+'No ingreso el legajo del empleado'+char(13)+char(10)
	else
		if not exists (select 1 from recursosHumanos.Empleado where legajo = @legajoEmp)
			set @error=@error+'El empleado ingresado no existe'+char(13)+char(10)

	if @error <> ''
	begin
		raiserror(@error, 16, 1)
		return
	end

	update ventas.Factura
		set empleadoLeg = @legajoEmp
	where id = @id
	
end
go

--modificar el cliente
create or alter proc ventas.modificarClienteDeFactura
	@id int,
	@idCliente int
as
begin
	declare @error varchar(200) = ''
	if @id is null
		set @error=@error+'No ingreso el id de la factura'+char(13)+char(10)
	else
		if not exists (select 1 from ventas.Factura where id = @id)
			set @error=@error+'La factura ingresada no existe'+char(13)+char(10)
		else
			if (select estado from ventas.Factura where id = @id) = 'Pagada'
				set @error=@error+'No se puede modificar una factura pagada'+char(13)+char(10)

	if @idCliente is null
		set @error=@error+'No ingreso el id del cliente'+char(13)+char(10)
	else
		if not exists (select 1 from clientes.Cliente where id = @idCliente)
			set @error=@error+'El cliente ingresado no existe'+char(13)+char(10)

	if @error <> ''
	begin
		raiserror(@error, 16, 1)
		return
	end

	update ventas.Factura
		set idCliente = @idCliente
	where id = @id
	
end
go

--LINEA DE FACTURA
--modificar producto
create or alter proc ventas.modificarProductoLineaDeFactura
	@idLn int,
	@idFactura int,
	@idProd int
as
begin
	declare @error varchar(200) = ''
	if @idFactura is null
		set @error=@error+'No ingreso el id de la factura'+char(13)+char(10)
	else
		if not exists (select 1 from ventas.Factura where id = @idFactura)
			set @error=@error+'La factura ingresada no existe'+char(13)+char(10)
		else
			if (select estado from ventas.Factura where id = @idFactura) = 'Pagada'
				set @error=@error+'No se puede modificar una factura pagada'+char(13)+char(10)

	if @idLn is null
		set @error=@error+'No ingreso el id de la linea de factura'+char(13)+char(10)
	else
		if not exists (select 1 from ventas.LineaDeFactura where id = @idLn)
			set @error=@error+'La linea de factura ingresada no existe'+char(13)+char(10)
		else
			if not exists(select 1  from ventas.LineaDeFactura where id = @idLn and idFactura = @idFactura)
				set @error=@error+'La linea ingresada no pertenece a la factura ingresada'+char(13)+char(10)
			else
				if exists (select 1 from ventas.LineaDeFactura where idFactura = @idFactura and 
																	id <> @idLn and idProd = @idProd)
					set @error=@error+'La factura ingresada ya tiene una linea con el producto ingresado'+char(13)+char(10)

	if @idProd is null
		set @error=@error+'No se ingreso el id del producto'+char(13)+char(10)
	else
		if not exists (select 1 from catalogo.Producto where id = @idProd)
			set @error=@error+'El producto ingresado no existe'+char(13)+char(10)

	if @error <> ''
	begin
		raiserror(@error, 16, 1)
		return
	end

	declare @precio decimal(9,2)
	declare @valorDolar decimal(6,2)
	select @precio = precio from catalogo.Producto where id = @idProd
	if @precio is null
	begin
		select @precio = precioUSD from catalogo.Producto where id = @idProd
		exec ventas.obtenerPrecioDolar @valorDolar output
		set @precio = @precio * @valorDolar
	end
	update ventas.LineaDeFactura
		set idProd = @idProd,
			precioUn = @precio,
			subtotal = @precio * cantidad
	where id = @idLn

end
go

--modificar id de la factura
create or alter proc ventas.modificarIdFacturaLineaDeFactura
	@idLn int,
	@idFactura int
as
begin
	declare @error varchar(200) = ''
	if @idFactura is null
		set @error=@error+'No ingreso el id de la factura'+char(13)+char(10)
	else
		if not exists (select 1 from ventas.Factura where id = @idFactura)
			set @error=@error+'La factura ingresada no existe'+char(13)+char(10)
		else
			if (select estado from ventas.Factura where id = @idFactura) = 'Pagada'
				set @error=@error+'No se puede modificar una factura pagada'+char(13)+char(10)

	if @idLn is null
		set @error=@error+'No ingreso el id de la linea de factura'+char(13)+char(10)
	else
		if not exists (select 1 from ventas.LineaDeFactura where id = @idLn)
			set @error=@error+'La linea de factura ingresada no existe'+char(13)+char(10)
		else
		if (select estado from ventas.Factura f join ventas.LineaDeFactura l on l.idFactura = f.id
			where l.id = @idLn) = 'Pagada'
			set @error=@error+'La linea de factura que quiere cambiar, esta asociada a una factura pagada'+char(13)+char(10)
	
	if @error <> ''
	begin
		raiserror(@error, 16, 1)
		return
	end

	declare @idProd int = (select idProd from ventas.LineaDeFactura where id = @idLn)
	if @idProd in (select idProd from ventas.LineaDeFactura where idFactura = @idFactura)
	begin
		raiserror('La factura a la que quiere cambiar, ya tiene una linea con el producto', 16, 1)
		return
	end

	update ventas.LineaDeFactura
		set idFactura = @idFactura
	where id = @idLn

end
go

--modificar la cantidad
create or alter proc ventas.modificarCantidadLineaDeFactura
	@idLn int,
	@cantidad decimal(5,2)
as
begin
	declare @error varchar(200) = ''
	if @idLn is null
		set @error=@error+'No ingreso el id de la linea de factura'+char(13)+char(10)
	else
		if not exists (select 1 from ventas.LineaDeFactura where id = @idLn)
			set @error=@error+'La linea de factura ingresada no existe'+char(13)+char(10)
		else
		if (select estado from ventas.Factura f join ventas.LineaDeFactura l on l.idFactura = f.id
			where l.id = @idLn) = 'Pagada'
			set @error=@error+'La linea de factura que quiere cambiar, esta asociada a una factura pagada'+char(13)+char(10)
	
	if @cantidad is null or @cantidad <= 0
		set @error=@error+'La cantidad ingresada no es valida'+char(13)+char(10)

	if @error <> ''
	begin
		raiserror(@error, 16, 1)
		return
	end

	update ventas.LineaDeFactura
		set cantidad = @cantidad,
			subtotal = @cantidad * precioUn
	where id = @idLn

end
go

--COMPROBANTE
--modificar el idPago
create or alter proc comprobantes.cambiarIdPagoComprobante
	@id int,
	@nvoIdPago char(23)
as
begin
	declare @error varchar(200) = ''

	if @id is null 
		set @error=@error+'No se ingreso el id del comprobante'+char(13)+char(10)
	else
		if not exists (select 1 from comprobantes.Comprobante where id = @id)
			set @error=@error+'El id del comprobante ingresado, no existe'+char(13)+char(10)
		else
			if (select tipoComprobante from comprobantes.Comprobante where id = @id) = 'Nota de Credito'
				set @error=@error+'El comprobante ingresado es una nota de credito, no se puede modificar el id de pago porque no tiene'+char(13)+char(10)
			else
				if exists (select 1 from comprobantes.Comprobante where idPago = @nvoIdPago)
					set @error=@error+'El id de pago ingresado ya pertenece a otro comprobante de pago'+char(13)+char(10)


	if @nvoIdPago is null or @nvoIdPago = ''
		set @error=@error+'No se ingreso el nuevo id de pago'+char(13)+char(10)

	if @error <> ''
	begin
		raiserror(@error, 16, 1)
		return
	end

	update comprobantes.Comprobante
		set idPago = @nvoIdPago
	where id = @id
end
go

--modificar el medio de pago de un comprobante
create or alter proc comprobantes.modificarMedioPagoDeComprobante
	@id int,
	@idMedPago int
as
begin
	declare @error varchar(200) = ''

	if @id is null 
		set @error=@error+'No se ingreso el id del comprobante'+char(13)+char(10)
	else
		if not exists (select 1 from comprobantes.Comprobante where id = @id)
			set @error=@error+'El id del comprobante ingresado no existe'+char(13)+char(10)
		else
			if (select tipoComprobante from comprobantes.Comprobante where id = @id) = 'Nota de Credito'
				set @error=@error+'El comprobante ingresado es una nota de credito, no se puede modificar el medio de pago porque no tiene'+char(13)+char(10)
	
	if @idMedPago is null
		set @error=@error+'No se ingreso el nuevo medio de pago'+char(13)+char(10)
	else
		if not exists (select 1 from comprobantes.MedioDePago where id = @idMedPago)
			set @error=@error+'El medio de pago ingresado no existe'+char(13)+char(10)

	if @error <> ''
	begin
		raiserror(@error, 16, 1)
		return
	end

	update comprobantes.Comprobante
		set idMedPago = @idMedPago
	where id = @id
end
go

--modificar la factura asociada al comprobante 
create or alter proc comprobantes.modificarFacturaDeComprobante
	@id int,
	@nvoIdFactura int
as
begin
	declare @error varchar(200) = ''

	if @id is null 
		set @error=@error+'No se ingreso el id del comprobante'+char(13)+char(10)
	else
		if not exists (select 1 from comprobantes.Comprobante where id = @id)
			set @error=@error+'El id del comprobante ingresado no existe'+char(13)+char(10)
	
	if @nvoIdFactura is null
		set @error=@error+'No se ingreso el id de la factura'+char(13)+char(10)
	else
		if not exists (select 1 from ventas.Factura where id = @nvoIdFactura)
			set @error=@error+'La factura ingresada no existe'+char(13)+char(10)

	if (select tipoComprobante from comprobantes.Comprobante where id = @id) = 'Factura'
		if (select estado from ventas.Factura where id = @nvoIdFactura) = 'Pagada'
			set @error=@error+'La nueva factura ingresada ya se encuentra pagada, por lo que ya tiene un comprobante de pago asociado 
			y no se le puede asociar otro comprobante de pago'+char(13)+char(10)

	if @error <> ''
	begin
		raiserror(@error, 16, 1)
		return
	end

	update comprobantes.Comprobante
		set idFactura = @nvoIdFactura
	where id = @id
	
end
go

--modificar la fecha del comprobante
create or alter proc ventas.modificarFechaComprobante
	@id int,
	@fecha date
as
begin
	declare @error varchar(200) = ''
	if @id is null
		set @error=@error+'No ingreso el id del comprobante'+char(13)+char(10)
	else
		if not exists (select 1 from comprobantes.Comprobante where id = @id)
			set @error=@error+'El comprobante ingresado no existe'+char(13)+char(10)

	if @fecha is null
		set @error=@error+'No se ingreso la fecha'+char(13)+char(10)

	if @error <> ''
	begin
		raiserror(@error, 16, 1)
		return
	end

	update comprobantes.Comprobante
		set fecha = @fecha
	where id = @id
end
go

--modificar la hora del comprobante
create or alter proc ventas.modificarHoraComprobante
	@id int,
	@hora time
as
begin
	declare @error varchar(200) = ''
	if @id is null
		set @error=@error+'No ingreso el id del comprobante'+char(13)+char(10)
	else
		if not exists (select 1 from comprobantes.Comprobante where id = @id)
			set @error=@error+'El comprobante ingresado no existe'+char(13)+char(10)

	if @hora is null
		set @error=@error+'No se ingreso la hora'+char(13)+char(10)

	if @error <> ''
	begin
		raiserror(@error, 16, 1)
		return
	end

	update comprobantes.Comprobante
		set hora = @hora
	where id = @id
end
go

--SUPERMERCADO (DATOS DE AURORA)
--Modificar razon social
create or alter procedure supermercado.cambiarRazonSocial
@razonNva varchar(20)
as
begin
	declare @error varchar(max)=''
	set @razonNva=ltrim(rtrim(@razonNva))
	if not exists (select 1 from supermercado.Supermercado)
		set @error=@error+'La tabla supermercado.Supermercado no tiene registros, cargue uno usando supermercado.insertarSupermercado'+char(13)+char(10)
	if @razonNva is null or @razonNva=''
		set @error=@error+'No se ingreso una razon social nueva.'+char(13)+char(10)
	if @error<>''
	begin
		raiserror(@error,16,1)
		return
	end
	update supermercado.Supermercado
	set razonSocial=@razonNva
end
go
--modificar cuit
create or alter procedure supermercado.cambiarCuit
@cuitNvo char(13)
as
begin
	declare @error varchar(max)=''
	set @cuitNvo=ltrim(rtrim(@cuitNvo))
	if not exists (select 1 from supermercado.Supermercado)
		set @error=@error+'La tabla supermercado.Supermercado no tiene registros, cargue uno usando supermercado.insertarSupermercado'+char(13)+char(10)
	if @cuitNvo<>'' and @cuitNvo not like '[0-9][0-9]-[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]-[0-9]'
		set @error=@error+'No se ingreso un cuit valido. Respetar xx-xxxxxxxx-x'+char(13)+char(10)
	if @error<>''
	begin
		raiserror(@error,16,1)
		return
	end
	if @cuitNvo='' or @cuitNvo is null
	begin
		set @cuitNvo='20-22222222-3'
		raiserror('No se ingreso un cuit por lo que se mantendra el cuit generico 20-22222222-3.',10,1)
	end
	update supermercado.Supermercado
	set cuit=@cuitNvo
end
go

--modificar ingresos brutos
create or alter procedure supermercado.cambiarNroIngresosBrutos
@ingBrutosNvo char(11)
as
begin
	declare @error varchar(max)=''
	set @ingBrutosNvo=ltrim(rtrim(@ingBrutosNvo))
	if not exists (select 1 from supermercado.Supermercado)
		set @error=@error+'La tabla supermercado.Supermercado no tiene registros, cargue uno usando supermercado.insertarSupermercado'+char(13)+char(10)
	if @ingBrutosNvo not like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
		set @error=@error+'No se ingreso un numero de ingresos brutos valido'+char(13)+char(10)
	if @error<>''
	begin
		raiserror(@error,16,1)
		return
	end
	if @ingBrutosNvo=''
		set @ingBrutosNvo=null
	update supermercado.Supermercado
	set ingBrutos=@ingBrutosNvo
end
go

--modificar cond iva
create or alter procedure supermercado.cambiarCondIva
@condIVANva varchar(30)
as
begin
	declare @error varchar(max)=''
	set @condIVANva=ltrim(rtrim(@condIVANva))
	if not exists (select 1 from supermercado.Supermercado)
		set @error=@error+'La tabla supermercado.Supermercado no tiene registros, cargue uno usando supermercado.insertarSupermercado'+char(13)+char(10)
	if @condIVANva is null or @condIVANva=''
		set @error=@error+'No se ingreso una condicion frente al iva.'+char(13)+char(10)
	if @error<>''
	begin
		raiserror(@error,16,1)
		return
	end
	update supermercado.Supermercado
	set condIVA=@condIVANva
end
go
--cambiar fecha de inicio actividades
create or alter procedure supermercado.cambiarFechaInicioAct
@fInicioAct date
as
begin
	declare @error varchar(max)=''
	if not exists (select 1 from supermercado.Supermercado)
		set @error=@error+'La tabla supermercado.Supermercado no tiene registros, cargue uno usando supermercado.insertarSupermercado'+char(13)+char(10)
	update supermercado.Supermercado
	set fInicioAct=@fInicioAct
end
go


