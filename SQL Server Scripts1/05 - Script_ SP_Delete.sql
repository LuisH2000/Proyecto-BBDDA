/*
Fecha de Entrega: 15/11/2024
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
--SUCURSAL
create or alter proc sucursales.bajaSucursalId 
	@id int
as
begin
	if not exists (select 1 from sucursales.Sucursal where id = @id)
	begin
		raiserror('La sucursal ingresada no existe', 16, 1)
		return
	end
	update sucursales.Sucursal 
	set activo = 0
	where id = @id
end
go

--EMPLEADO
create or alter proc recursosHumanos.bajaEmpleado
	@legEmp int
as
begin
	if not exists(select 1 from recursosHumanos.Empleado where legajo = @legEmp)
	begin
		raiserror('El empleado ingresado no existe', 16, 1)
		return
	end

	update recursosHumanos.Empleado
	set activo = 0
	where legajo = @legEmp
end
go

--baja empleado pero por dni
create or alter proc recursosHumanos.bajaEmpleadoDni
	@dniEmp int
as
begin
	if not exists(select 1 from recursosHumanos.Empleado where dni=@dniEmp) or @dniEmp is null
	begin
		raiserror('El empleado ingresado no existe', 16, 1)
		return
	end

	update recursosHumanos.Empleado
	set activo = 0
	where dni=@dniEmp
end
go
--CARGO
create or alter proc recursosHumanos.eliminarCargoId
	@idCargo int
as
begin
	declare @error varchar(200) = ''
	if not exists (select 1 from recursosHumanos.Cargo where id = @idCargo)
		set @error = @error + 'El cargo ingresado no existe' + char(13) + char(10)
	else
		if exists (select 1 from recursosHumanos.Empleado where cargo = @idCargo)
			set @error = @error + 'Existen empleados con este cargo, modificar el cargo de estos' + char(13) + char(10)
	
	if @error <> ''
	begin
		raiserror(@error, 16, 1)
		return 
	end

	delete from recursosHumanos.Cargo where id = @idCargo
end
go
--LINEAPRODUCTO
create or alter proc catalogo.eliminarLineaProductoId
	@idLP int
as
begin
	declare @error varchar(200) = ''
	if not exists (select 1 from catalogo.LineaProducto where id = @idLP)
		set @error = @error + 'La linea de producto ingresada no existe' + char(13) + char(10)
	else
		if exists (select 1 from catalogo.Categoria where idLineaProd = @idLP)
			set @error = @error + 'Existen categorias de producto que pertenecen a la linea ingresada, cambiar la linea a la que pertenecen' + char(13) + char(10)
	
	if @error <> ''
	begin
		raiserror(@error, 16, 1)
		return 
	end

	delete from catalogo.LineaProducto where id = @idLP
end
go

--PRODUCTO
create or alter proc catalogo.bajaProductoId
	@idProd int
as
begin
	if not exists (select 1 from catalogo.Producto where id = @idProd)
	begin
		raiserror('El producto ingresado no existe', 16, 1)
		return
	end

	update catalogo.Producto
	set activo = 0
	where id = @idProd
end
go

--CATEGORIA
create or alter proc catalogo.eliminarCategoriaId
	@idCat int
as
begin
	declare @error varchar(200) = ''
	if not exists (select 1 from catalogo.Categoria where id = @idCat)
		set @error = @error + 'La categoria ingresada no existe' + char(13) + char(10)
	else
		if exists (select 1 from catalogo.PerteneceA where idCategoria = @idCat)
			set @error = @error + 'Existen productos que pertenecen a esa categoria, cambiar la categoria de esos productos' + char(13) + char(10)

	if @error <> ''
	begin
		raiserror(@error, 16, 1)
		return
	end

	delete from catalogo.Categoria where id = @idCat
end
go

--PERTENECEA
create or alter proc catalogo.eliminarProductoDeUnaCategoria
	@idProd int,
	@idCat int
as
begin
	declare @error varchar(max) = ''
	if not exists (select 1 from catalogo.Producto where id = @idProd)
		set @error = @error + 'El producto ingresado no existe' + char(13) + char(10)
	if not exists (select 1 from catalogo.Categoria where id = @idCat)
		set @error = @error + 'La categoria ingresada no existe' + char(13) + char(10)
	if not exists (select 1 from catalogo.PerteneceA 
						where idProd = @idProd
						and idCategoria = @idCat)
		set @error = @error + 'El producto ingresado no pertenece a esa categoria'+ char(13) + char(10)

	if @error <> ''
	begin
		raiserror(@error, 16, 1)
		return
	end

	delete from catalogo.PerteneceA where idProd = @idProd and idCategoria = @idCat
end
go

--MEDIODEPAGO
create or alter proc comprobantes.bajaMedioPagoId
	@idMp int
as
begin
	if not exists (select 1 from comprobantes.MedioDePago where id = @idMp)
	begin
		raiserror('El medio de pago ingresado no existe', 16, 1)
		return
	end

	update comprobantes.MedioDePago
	set activo = 0
	where id = @idMp
end
go

--TIPO CLIENTE
--Borrar un tipo de cliente (pensado para usarse en conjunto con clientes.cambiarClientesDeUnTipoAOtro)
create or alter procedure clientes.borrarTipoDeCliente 
@idTipoBr int
as
begin
	declare @error varchar(max)=''
	--verificamos que el tipo exista y que no hayan clientes que aun tienen ese tipo
	if @idTipoBr is null or not exists (select 1 from clientes.TipoCliente where id=@idTipoBr)
		set @error=@error+'No se ingreso un tipo de cliente o no existe.'+char(13)+char(10)
	if exists (select 1 from clientes.Cliente where idTipo=@idTipoBr)
		set @error=@error+'Aun existen clientes que pertenecen al tipo ingresado, migrelos a otro tipo usando clientes.cambiarClientesDeUnTipoAOtro primero.'+char(13)+char(10)
	if @error<>''
	begin
		raiserror(@error,16,1)
		return
	end
	delete from clientes.TipoCliente
	where id=@idTipoBr
end
go

--CLIENTE
create or alter proc clientes.bajaCliente
	@id int
as
begin
	if @id is null or not exists(select 1 from clientes.Cliente where id = @id)
	begin
		raiserror('No se ingreso el cliente o no existe.', 16, 1)
		return
	end

	update clientes.Cliente
		set activo = 0
	where id = @id
end
go

--FACTURA
create or alter proc ventas.anularFactura
	@id int
as
begin
	declare @error varchar(200) = ''
	if @id is null
		set @error=@error+'No se ingreso el id de la factura'+char(13)+char(10)
	else
		if not exists (select 1 from ventas.Factura where id = @id)
			set @error=@error+'La factura ingresada no existe'+char(13)+char(10)
		else
			if (select estado from ventas.Factura where id = @id) = 'Pagada'
				set @error=@error+'La factura ingresada se encuentra pagada'+char(13)+char(10)

	if @error <> ''
	begin
		raiserror(@error, 16, 1)
		return
	end

	delete from ventas.Factura where id = @id
end
go

--LINEAFACTURA
create or alter proc ventas.anularLineaFactura
	@id int
as
begin
	declare @error varchar(200) = ''
	if @id is null
		set @error=@error+'No se ingreso el id de la linea de factura'+char(13)+char(10)
	else
		if not exists (select 1 from ventas.LineaDeFactura where id = @id)
			set @error=@error+'La linea de factura ingresada no existe'+char(13)+char(10)
		else
			if (select estado from ventas.Factura f join ventas.LineaDeFactura l on f.id = l.idFactura
				where l.id = @id) = 'Pagada'
				set @error=@error+'La linea de factura ingresada, se encuentra asociada a una factura pagada'+char(13)+char(10)

	if @error <> ''
	begin
		raiserror(@error, 16, 1)
		return
	end

	delete from ventas.LineaDeFactura where id = @id
end
go

--COMPROBANTE
create or alter proc comprobantes.anularComprobante
	@id int
as
begin
	declare @error varchar(200) = ''
	if @id is null
		set @error=@error+'No se ingreso el id del comprobante'+char(13)+char(10)
	else
		if not exists (select 1 from comprobantes.Comprobante where id = @id)
			set @error=@error+'El comprobante ingresado no existe'+char(13)+char(10)
	
	if @error <> ''
	begin
		raiserror(@error, 16, 1)
		return
	end

	declare @idFactura int = (select idFactura from comprobantes.Comprobante where id = @id)
	update ventas.Factura
		set estado = 'Impaga'
	where id = @idFactura

	delete from comprobantes.Comprobante where id = @id
end