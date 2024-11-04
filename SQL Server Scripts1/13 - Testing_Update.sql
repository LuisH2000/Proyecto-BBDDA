use [Com5600G13]
go

--SUCURSAL
exec sucursales.darAltaSucursalEnBaja 4
select * from sucursales.Sucursal

exec sucursales.modificarDireccionSucursal 4, 'AV. Don Bosco 123', 'Moron'
select * from sucursales.Sucursal
--Probamos cambiar la direccion a una que tiene otra sucursal
exec sucursales.modificarDireccionSucursal 1, 'AV. Don Bosco 123', 'Moron'

exec sucursales.modificarHorarioSucursal 4, 'L a V 8-10; S y D 10-12'
select * from sucursales.Sucursal

--Probamos un telefono invalido
exec sucursales.modificarTelefonoSucursal 4, '12'
exec sucursales.modificarTelefonoSucursal 4, '2222-2222'
select * from sucursales.Sucursal