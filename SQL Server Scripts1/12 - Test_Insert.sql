use [Com5600G13]
go
--***SUCURSAL***
-- Probamos insertar valores nulos o vacios, nos deberia aparecer mensajes de errores
exec sucursales.insertarSucursal null, null, null, null
exec sucursales.insertarSucursal ' ', '', '       ', ' '

--Probamos un telefono invalido
exec sucursales.insertarSucursal 'La Matanza', 'AV. Don Bosco', 'L a V: 8 - 20, S y D: 10 - 20', '151111-1111'

-- Probamos insertar una direccion y ciudad en donde ya existe una sucursal
exec sucursales.insertarSucursal 'San Justo', 'Av. Brig. Gral. Juan Manuel de Rosas 3634, B1754 San Justo, Provincia de Buenos Aires', 'L a V: 8 - 20, S y D: 10 - 20', '1111-1111'
-- Probamos una direccion que existe pero en otra ciudad
exec sucursales.insertarSucursal 'La Matanza', 'Av. Brig. Gral. Juan Manuel de Rosas 3634, B1754 San Justo, Provincia de Buenos Aires', 'L a V: 8 - 20, S y D: 10 - 20', '1111-1111'
select * from sucursales.Sucursal

--***EMPLEADO***
