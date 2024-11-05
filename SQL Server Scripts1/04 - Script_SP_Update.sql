use [Com5600G13]
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

--EMPLEADO
	--cammbiar nombre
	--cambiar apellido
	--cambiar direccion
	--cambiar mail personal
	--cambiar mail empresaria
	--cambiar cargo
	--cambiar sucursal
	--cambiar turno
	--dar de alta empleado que estaba de baja
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