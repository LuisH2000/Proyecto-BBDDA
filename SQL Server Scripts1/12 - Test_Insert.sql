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

--SP Para ingresar un cargo nuevo
--Valida que el cargo no exista, intentemos ingresar uno que ya existe, por ejemplo, cajero
exec recursosHumanos.insertarCargo 'cajero'
--Ahora intentemos ingresar un cargo nuevo, ejemplo, conserje
exec recursosHumanos.insertarCargo 'conSERje'

--vemos que se cargo
select * from recursosHumanos.cargo
order by id

--borramos el registro
delete from recursosHumanos.Cargo
where cargo='Conserje'

--SP para insertar una nueva linea de Producto junto con su categoria (tal como venian en el archivo, de a pares)
--Si la linea de producto no existe la crea, si ya existe asocia la categoria a ese LP existente, si la categoria ya existe tira error
--y avisa que la categoria ya esta registrada y asociada a un LP existente (y te muestra a cual)

--Intentemos ingresar una combinacion de linea de producto / categoria que ya existe
exec catalogo.insertarLineaProductoYCategoria 'Almacen', 'Condimentos'

--Intentamos ingresar una categoria que ya existe con una linea de productos que no existe
exec catalogo.insertarLineaProductoYCategoria 'Ocultos', 'Condimentos'

--Intentamos ingresar combinaciones vacias
exec catalogo.insertarLineaProductoYCategoria ' ', NULL

--Ingresamos una categoria nueva con una linea de productos existente
exec catalogo.insertarLineaProductoYCategoria 'Almacen', 'Bolsas reciclables'
--Vemos que este se asocia correctamente con la linea de productos
select * from catalogo.Categoria c
inner join catalogo.LineaProducto lp
on c.idLineaProd=lp.id
where c.categoria='Bolsas_reciclables'

--borramos el registro
delete from catalogo.Categoria
where categoria='Bolsas_reciclables'

--Ingresamos una categoria nueva con una linea de productos nueva
exec catalogo.insertarLineaProductoYCategoria 'Ocultos', 'Magicos'

--Vemos que se creo tanto la linea de productos como la categoria y se asociaron correctamente
select * from catalogo.Categoria c
inner join catalogo.LineaProducto lp
on c.idLineaProd=lp.id
where c.categoria='Magicos'

--borramos ambos registros
delete from catalogo.Categoria
where categoria='Magicos'

delete from catalogo.LineaProducto 
where lineaProd='Ocultos'

--SP para insertar una linea de producto (sola, sin categoria)
--Intentamos insertar una linea de producto nula
exec catalogo.insertarLineaProducto ' '
--o
exec catalogo.insertarLineaProducto NULL

--Intentamos ingresar una linea de producto existente
exec catalogo.insertarLineaProducto 'Almacen'

--Ingresamos una linea de producto totalmente nueva
exec catalogo.insertarLineaProducto 'Ocultos'

--vemos que se ingreso
select * from catalogo.LineaProducto
where lineaProd='Ocultos'

--borramos el registro
delete from catalogo.LineaProducto
where lineaProd='Ocultos'
