use Com5600G13
go


execute as login = 'supervisor';
--Probamos hacer un select en una tabla que no le dimos permisos
select * from recursosHumanos.Empleado
--Probamos hacer un select en una tabla que le dimos permisos
select * from ventas.Factura
revert

--Probamos hacer una nota de credito como supervisor, nos deberia dejar
execute as login = 'supervisor';
exec comprobantes.generarNotaDeCredito @factura='750-67-8428', @idProd=4149, @cantidadDevolver=2
select * from comprobantes.Comprobante where idFactura = 1
revert
--Probamos hacer una nota de credito como cajero, no nos lo deberia permitir
execute as login = 'cajero';
exec comprobantes.generarNotaDeCredito @factura='750-67-8428', @idProd=4149, @cantidadDevolver=2
revert

