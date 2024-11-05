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
--SP para ingresar empleado en una sucursal donde la sucursal se determina por ciudad y direccion de la misma
--Probamos insertando un empleado que falle las validaciones criticas (como minimo el empleado
--debe tener un registro de empleado debe tener un legajo, dni, email personal, email empresarial, cargo, ciudad y direccion de sucursal y un turno).
exec recursosHumanos.insertarEmpleadoSucursalPorCiudadDireccion NULL,'Pollito', 'Perez', 41714473, 'Luisito 298','camilotierra@gmail.com', 'camilotierra@gmail.com2', 20, NULL, NULL, NULL, NULL 
--Ahora intentemos ingresar un empleado que falle las verificaciones generales:
/*Validaciones generales:
legajo unico
dni unico
formato de correo, que no sean iguales entre si, y que sean unicos ambos
que el cargo ingresado exista
que el turno sea valido
que la ciudad y direccion ingresadas correspondan con una sucursal
que el cuil tenga el formato correspondiente (solo si no es nulo)*/
exec recursosHumanos.insertarEmpleadoSucursalPorCiudadDireccion 257020, 'Pollito', 'Perez', 36383025, 'Av. Vergara 1910 , Hurlingham , Buenos Aires','pollitoPerez@gmail.com','pollitoPerez@gmail.com', 20349,'Barrendero', 'Turno madrugada', 'La matanza','Avenida siempre viva 239' 

--Ahora intentemos con un registro valido
exec recursosHumanos.insertarEmpleadoSucursalPorCiudadDireccion 300000, 'Pollito', 'Perez', 41714474, 'Av. Vergara 1910 , Hurlingham , Buenos Aires','pollitoPerez@gmail.com','pollitoPEREZ@superA.com','21-41714474-1','Cajero', 'TM', 'San Justo','Av. Brig. Gral. Juan Manuel de Rosas 3634, B1754 San Justo, Provincia de Buenos Aires'
--Comprobamos que efectivamente se pudo ingresar
select * from recursosHumanos.empleado
where legajo=300000 

--borramos el registro
delete from recursosHumanos.Empleado
where legajo=300000

--SP para ingresar empleado en una sucursal donde la sucursal se determina por ID
--Funciona igual que el anterior solo que en vez de la ciudad y direccion de la sucursal este se determina con el ID, las validaciones
--son iguales salvo que ahora se verifica que el id ingresado corresponda con una sucursal y que no sea null

--intentamos fallar las verificaciones criticas
exec recursosHumanos.insertarEmpleadoSucursalPorId NULL,'Pollito', 'Perez', 41714473, 'Luisito 298','camilotierra@gmail.com', 'camilotierra@gmail.com2', 20, NULL, NULL, NULL

--intentamos fallar las verificaciones generales
exec recursosHumanos.insertarEmpleadoSucursalPorId 257020, 'Pollito', 'Perez', 36383025, 'Av. Vergara 1910 , Hurlingham , Buenos Aires','pollitoPerez@gmail.com','pollitoPerez@gmail.com', 20349,'Barrendero', 'Turno madrugada', 900

--Ingresamos un registro valido
exec recursosHumanos.insertarEmpleadoSucursalPorId 300000, 'Pollito', 'Perez', 41714474, 'Av. Vergara 1910 , Hurlingham , Buenos Aires','pollitoPerez@gmail.com','pollitoPEREZ@superA.com','21-41714474-1','Cajero', 'TM', 1
--Comprobamos que efectivamente se pudo ingresar
select * from recursosHumanos.empleado
where legajo=300000 

--borramos el registro
delete from recursosHumanos.Empleado
where legajo=300000

