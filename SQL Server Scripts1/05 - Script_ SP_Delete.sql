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
			set @error = @error + 'Existe empleados con este cargo, modificar el cargo de estos' + char(13) + char(10)
	
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

--TIPOCLIENTE
--FACTURA
--LINEAFACTURA
--COMPROBANTE