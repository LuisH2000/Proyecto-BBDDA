use Com5600G13
go


execute as login = 'supervisor';
--Probamos hacer un select en una tabla que no le dimos permisos
select * from recursosHumanos.Empleado
--Probamos hacer un select en una tabla que le dimos permisos
select * from ventas.Factura

revert

