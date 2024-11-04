use [Com5600G13]
go
--SUCURSAL
create or alter proc sucursales.bajaSucursalId 
	@id int
as
begin
	update sucursales.Sucursal 
	set activo = 0
	where id = @id
end
go

--EMPLEADO
--CARGO
--LINEAPRODUCTO
--PRODUCTO
--CATEGORIA
--TIPOCLIENTE
--FACTURA
--MEDIODEPAGO
--COMPROBANTE