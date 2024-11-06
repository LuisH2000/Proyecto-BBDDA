use [Com5600G13]
go

--SUCURSAL
--Vemos que al dar de baja la sucursal, sigue en la tabla pero deja de estar activo
exec sucursales.bajaSucursalId 3
select * from sucursales.Sucursal