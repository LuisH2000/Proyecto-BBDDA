use [Com5600G13]
go

--***SUCURSAL***
--DAR DE ALTA SUCURSAL DE BAJA
--Probamos con una sucursal que no existe
exec sucursales.darAltaSucursalEnBaja -1
--Damos de alta una sucursal de baja
update sucursales.Sucursal set activo = 0 where id = 1
select * from sucursales.Sucursal where id = 1
exec sucursales.darAltaSucursalEnBaja 1
select * from sucursales.Sucursal where id = 1

--MODIFICAR DIRECCION
--Probamos con una sucursal que no existe
exec sucursales.modificarDireccionSucursal -1, 'AV. Don Bosco 123', 'Moron'
--Probamos cambiar la direccion a una que tiene otra sucursal
exec sucursales.modificarDireccionSucursal 1, ' Pres. Juan Domingo Perón 763, B1753AWO Villa Luzuriaga, Provincia de Buenos Aires', 'Lomas del Mirador'
--Modificamos la direccion
select * from sucursales.Sucursal
exec sucursales.modificarDireccionSucursal 1, 'AV. Don Bosco 123', 'Moron'

update sucursales.Sucursal set 
	direccion = 'Av. Brig. Gral. Juan Manuel de Rosas 3634, B1754 San Justo, Provincia de Buenos Aires',
	ciudad = 'San Justo' 
where id = 1

--MODIFICAR HORARIO
--Probamos con una sucursal que no existe
exec sucursales.modificarHorarioSucursal -1, 'L a V 8-10; S y D 10-12'
--Modificamos el horario
select * from sucursales.Sucursal where id = 1
exec sucursales.modificarHorarioSucursal 1, 'L a V 8-10; S y D 10-12'

update sucursales.Sucursal set horario = 'L a V 8 a. m.–9 p. m. S y D 9 a. m.-8 p. m.' where id = 1

--MODIFICAR TELEFONO
--Probamos con una sucursal que no existe y un telefono invalido
exec sucursales.modificarTelefonoSucursal -1, '12'
--Modificamos el telefono
select * from sucursales.Sucursal
exec sucursales.modificarTelefonoSucursal 1, '2222-2222'

update sucursales.Sucursal set telefono = '5555-5551' where id = 1

--***EMPLEADO***

--CAMBIAR NOMBRE DE EMPLEADO USANDO SU LEGAJO
--intentamos insertar un legajo y nombre nulo
exec recursosHumanos.cambiarNombreEmpleadoPorLegajo null,null
--ahora un legajo inexistente
exec recursosHumanos.cambiarNombreEmpleadoPorLegajo 1,'Roberto'
select * from recursosHumanos.Empleado
--ahora un caso valido
select nombre from recursosHumanos.Empleado where legajo=257020
--Vemos que originalmente se llama Romina Alejandra, la cambiamos por Romina Abigail
exec recursosHumanos.cambiarNombreEmpleadoPorLegajo 257020,'Romina Abigail'
--Vemos que los cambios se efectuaron
select nombre from recursosHumanos.Empleado where legajo=257020
--deshacemos los cambios
exec recursosHumanos.cambiarNombreEmpleadoPorLegajo 257020,'Romina Alejandra'

--Existe otra version de este SP, funciona exactamente igual pero identifica al
--empleado usando su dni en vez de legajo:
select nombre from recursosHumanos.Empleado where dni=36383025
--Vemos que originalmente se llama Romina Alejandra, la cambiamos por Romina Abigail
exec recursosHumanos.cambiarNombreEmpleadoPorDni 36383025,'Romina Abigail'
--Vemos que los cambios se efectuaron
select nombre from recursosHumanos.Empleado where dni=36383025
--deshacemos los cambios
exec recursosHumanos.cambiarNombreEmpleadoPorDni 36383025,'Romina Alejandra'

--CAMBIAR APELLIDO DE UN EMPLEADO
--usando legajo
--intentamos insertar parametros nulos
exec recursosHumanos.cambiarApellidoEmpleadoPorLegajo null,null
--ahora un caso valido donde cambiamos el apellido de lo que sea que tenga a Ramirez y luego denuevo al original (ejecuta todo el bloque)
declare @legajo int
declare @apellidoOri varchar(50)
set @legajo=(select top 1 legajo from recursosHumanos.empleado)
set @apellidoOri=(select apellido from recursosHumanos.Empleado where legajo=@legajo)
select * from recursosHumanos.Empleado where legajo=@legajo
exec recursosHumanos.cambiarApellidoEmpleadoPorLegajo @legajo,'Ramirez'
select * from recursosHumanos.Empleado where legajo=@legajo
exec recursosHumanos.cambiarApellidoEmpleadoPorLegajo @legajo,@apellidoOri
select * from recursosHumanos.Empleado where legajo=@legajo
go

--usando dni (ejecuta todo el bloque)
DECLARE @dni INT
DECLARE @apellidoOri VARCHAR(50)
SET @dni = (SELECT TOP 1 dni FROM recursosHumanos.Empleado)
SET @apellidoOri = (SELECT apellido FROM recursosHumanos.Empleado WHERE dni = @dni)
SELECT * FROM recursosHumanos.Empleado WHERE dni = @dni
EXEC recursosHumanos.cambiarApellidoEmpleadoPorDni @dni, 'Ramirez'
SELECT * FROM recursosHumanos.Empleado WHERE dni = @dni
EXEC recursosHumanos.cambiarApellidoEmpleadoPorDni @dni, @apellidoOri
select * from recursosHumanos.Empleado where dni =@dni
go

--CAMBIAR DIRECCION DE UN EMPLEADO
--usando legajo
--intentamos insertar con un legajo inexistente y una direccion vacia
exec recursosHumanos.cambiarDireccionEmpleadoPorLegajo 29320,'       '
--ahora probamos un caso valido cambiandole la direccion al empleado y luego restaurandolo. (ejecutar bloque entero)
declare @legajo int
declare @direccionOri varchar(100)
set @legajo=(select top 1 legajo from recursosHumanos.empleado)
set @direccionOri=(select direccion from recursosHumanos.Empleado where legajo=@legajo)
select * from recursosHumanos.Empleado where legajo=@legajo
exec recursosHumanos.cambiarDireccionEmpleadoPorLegajo @legajo,'Avenida SiempreViva 747, Springfield, USA'
select * from recursosHumanos.Empleado where legajo=@legajo
exec recursosHumanos.cambiarDireccionEmpleadoPorLegajo @legajo,@direccionOri
select * from recursosHumanos.Empleado where legajo=@legajo
go

--usando dni
--intentamos un caso de dni inexistente junto con direccion vacio
exec recursosHumanos.cambiarDireccionEmpleadoPorDni 2932,'   '
--Ahora un caso valido (ejecutar el bloque entero)
DECLARE @dni INT
DECLARE @direccionOri VARCHAR(100)
SET @dni = (SELECT TOP 1 dni FROM recursosHumanos.empleado)
SET @direccionOri = (SELECT direccion FROM recursosHumanos.Empleado WHERE dni = @dni)
SELECT * FROM recursosHumanos.Empleado WHERE dni = @dni
EXEC recursosHumanos.cambiarDireccionEmpleadoPorDni @dni, 'Avenida SiempreViva 747, Springfield, USA'
SELECT * FROM recursosHumanos.Empleado WHERE dni = @dni
EXEC recursosHumanos.cambiarDireccionEmpleadoPorDni @dni, @direccionOri
SELECT * FROM recursosHumanos.Empleado WHERE dni = @dni
GO

--CAMBIAR EMAIL PERSONAL DE UN EMPLEADO
--usando legajo
--intentamos insertar un correo vacio con un legajo inexistente
exec recursosHumanos.cambiarMailPersonalEmpleadoPorLegajo 2392,''
--ahora intentamos ingresar un correo que ya existe
exec recursosHumanos.cambiarMailPersonalEmpleadoPorLegajo 2392,'Emilce_MAIDANA@gmail.com'



--ahora vamos con un caso valido (ejecutar bloque completo)
declare @legajo int
declare @correoPerOri varchar(60)
set @legajo=(select top 1 legajo from recursosHumanos.empleado)
set @correoPerOri=(select emailPer from recursosHumanos.Empleado where legajo=@legajo)
select * from recursosHumanos.Empleado where legajo=@legajo
exec recursosHumanos.cambiarMailPersonalEmpleadoPorLegajo @legajo,'losBroncosaurios@gmail.com'
select * from recursosHumanos.Empleado where legajo=@legajo
exec recursosHumanos.cambiarMailPersonalEmpleadoPorLegajo @legajo,@correoPerOri
select * from recursosHumanos.Empleado where legajo=@legajo
go

--usando dni
--intentamos insertar un correo vacio con un dni inexistente
exec recursosHumanos.cambiarMailPersonalEmpleadoPorDni 2392,''
--ahora intentamos ingresar un correo que ya existe
exec recursosHumanos.cambiarMailPersonalEmpleadoPorDni 2392,'Romina Alejandra_ALIAS@gmail.com'


--ahora un caso valido (ejecutar bloque completo)
declare @dni int
declare @correoPerOri varchar(60)
set @dni=(select top 1 dni from recursosHumanos.empleado)
set @correoPerOri=(select emailPer from recursosHumanos.Empleado where dni=@dni)
select * from recursosHumanos.Empleado where dni=@dni
exec recursosHumanos.cambiarMailPersonalEmpleadoPorDni @dni,'losBroncosaurios@gmail.com'
select * from recursosHumanos.Empleado where dni=@dni
exec recursosHumanos.cambiarMailPersonalEmpleadoPorDni @dni,@correoPerOri
select * from recursosHumanos.Empleado where dni=@dni
go

--CAMBIAR CORREO EMPRESARIAL DE UN EMPLEADO
--usando legajo
--intentamos insertar un correo vacio con un legajo inexistente
exec recursosHumanos.cambiarMailEmpresarialEmpleadoPorLegajo 2392,''
--ahora intentamos ingresar un correo que ya existe
exec recursosHumanos.cambiarMailEmpresarialEmpleadoPorLegajo 2392,'Romina Alejandra.ALIAS@superA.com'

--ahora un caso valido (ejecutar bloque completo)
declare @legajo int
declare @correoEmpOri varchar(60)
set @legajo=(select legajo from recursosHumanos.Empleado where REPLACE(emailEmp, CHAR(9), ' ')='Romina Alejandra.ALIAS@superA.com')
set @correoEmpOri=(select emailEmp from recursosHumanos.Empleado where legajo=@legajo)
select * from recursosHumanos.Empleado where legajo=@legajo
exec recursosHumanos.cambiarMailEmpresarialEmpleadoPorLegajo @legajo,'Romina Alejandra.ALIAS@losPollosHermanos.com'
select * from recursosHumanos.Empleado where legajo=@legajo
exec recursosHumanos.cambiarMailEmpresarialEmpleadoPorLegajo @legajo,'Romina Alejandra.ALIAS@superA.com'
select * from recursosHumanos.Empleado where legajo=@legajo
go

--usando dni
--intentamos insertar un correo vacio con un legajo inexistente
exec recursosHumanos.cambiarMailEmpresarialEmpleadoPorDni 2392,''
--ahora intentamos ingresar un correo que ya existe
exec recursosHumanos.cambiarMailEmpresarialEmpleadoPorDni 2392,'Romina Alejandra.ALIAS@superA.com'

--ahora un caso valido (ejecutar bloque completo)
declare @dni int
declare @correoEmpOri varchar(60)
set @dni = (select dni from recursosHumanos.Empleado where REPLACE(emailEmp, CHAR(9), ' ') = 'Romina Alejandra.ALIAS@superA.com')
set @correoEmpOri = (select emailEmp from recursosHumanos.Empleado where dni = @dni)
select * from recursosHumanos.Empleado where dni = @dni
exec recursosHumanos.cambiarMailEmpresarialEmpleadoPorDni @dni, 'Romina Alejandra.ALIAS@losPollosHermanos.com'
select * from recursosHumanos.Empleado where dni = @dni
exec recursosHumanos.cambiarMailEmpresarialEmpleadoPorDni @dni, @correoEmpOri
select * from recursosHumanos.Empleado where dni = @dni
go


--CAMBIAR CARGO DE UN EMPLEADO
--usando legajo
--intentamos meter datos nulos
exec recursosHumanos.cambiarCargoEmpleadoPorLegajo null,null
--intentamos meter un cargo que no existe
exec recursosHumanos.cambiarCargoEmpleadoPorLegajo null,'Barrendero'

--ahora un caso valido (ejecutar bloque completo)
declare @legajo int
declare @cargoOriCod int
declare @cargoOri varchar(20)
set @legajo=(select top 1 legajo from recursosHumanos.Empleado where cargo<>2)
set @cargoOriCod=(select cargo from recursosHumanos.Empleado where legajo=@legajo)
set @cargoOri=(select cargo from recursosHumanos.cargo where id=@cargoOriCod)
select e.legajo,e.nombre,c.cargo from recursosHumanos.Empleado e inner join recursosHumanos.cargo c on e.cargo=c.id where legajo=@legajo
exec recursosHumanos.cambiarCargoEmpleadoPorLegajo @legajo,'Gerente de sucursal'
select e.legajo,e.nombre,c.cargo from recursosHumanos.Empleado e inner join recursosHumanos.cargo c on e.cargo=c.id where legajo=@legajo
exec recursosHumanos.cambiarCargoEmpleadoPorLegajo @legajo,@cargoOri
select e.legajo,e.nombre,c.cargo from recursosHumanos.Empleado e inner join recursosHumanos.cargo c on e.cargo=c.id where legajo=@legajo
go

--usando dni
--intentamos meter datos nulos
exec recursosHumanos.cambiarCargoEmpleadoPorDni null,null
--intentamos meter un cargo que no existe
exec recursosHumanos.cambiarCargoEmpleadoPorDni 2832,'Barrendero'

--ahora un caso valido (ejecutar bloque completo)
declare @dni int
declare @cargoOriCod int
declare @cargoOri varchar(20)
set @dni = (select top 1 dni from recursosHumanos.Empleado where cargo <> 2)
set @cargoOriCod = (select cargo from recursosHumanos.Empleado where dni = @dni)
set @cargoOri = (select cargo from recursosHumanos.cargo where id = @cargoOriCod)
select e.dni, e.nombre, c.cargo from recursosHumanos.Empleado e inner join recursosHumanos.cargo c on e.cargo = c.id where dni = @dni
exec recursosHumanos.cambiarCargoEmpleadoPorDni @dni, 'Gerente de sucursal' 
select e.dni, e.nombre, c.cargo from recursosHumanos.Empleado e inner join recursosHumanos.cargo c on e.cargo = c.id where dni = @dni
exec recursosHumanos.cambiarCargoEmpleadoPorDni @dni, @cargoOri
select e.dni, e.nombre, c.cargo from recursosHumanos.Empleado e inner join recursosHumanos.cargo c on e.cargo = c.id where dni = @dni
go

--CAMBIAR SUCURSAL DE UN EMPLEADO
--por legajo
--intentamos ingresar datos nulos
exec recursosHumanos.cambiarSucursalEmpleadoPorLegajo null,null

--intentamos ingresar un legajo que no existe y una sucursal que tampoco existe
exec recursosHumanos.cambiarSucursalEmpleadoPorLegajo 1,29392

--ahora un caso valido donde cambiamos la sucursal en la que trabaja el empleado y luego lo restauramos (ejecutar bloque completo)
declare @idSucursalNuevo int
declare @idSucursalOri int
declare @legajo int
set @legajo=(select top 1 legajo from recursosHumanos.empleado)
set @idSucursalNuevo=(select top 1 id from sucursales.sucursal)
set @idSucursalOri=(select idSucursal from recursosHumanos.empleado where legajo=@legajo and idSucursal<>@idSucursalNuevo)
select e.legajo,e.nombre,e.idSucursal,s.ciudad,s.direccion from recursosHumanos.empleado e inner join sucursales.sucursal s
on e.idSucursal=s.id where legajo=@legajo
exec recursosHumanos.cambiarSucursalEmpleadoPorLegajo @legajo,@idSucursalNuevo
select e.legajo,e.nombre,e.idSucursal,s.ciudad,s.direccion from recursosHumanos.empleado e inner join sucursales.sucursal s
on e.idSucursal=s.id where legajo=@legajo
exec recursosHumanos.cambiarSucursalEmpleadoPorLegajo @legajo,@idSucursalOri
select e.legajo,e.nombre,e.idSucursal,s.ciudad,s.direccion from recursosHumanos.empleado e inner join sucursales.sucursal s
on e.idSucursal=s.id where legajo=@legajo
go

--usando dni
--intentamos ingresar datos nulos
exec recursosHumanos.cambiarSucursalEmpleadoPorDni null,null

--intentamos ingresar un legajo que no existe y una sucursal que tampoco existe
exec recursosHumanos.cambiarSucursalEmpleadoPorDni 1,29392

--ahora un caso valido (ejecutar bloque completo)
declare @idSucursalNuevo int
declare @idSucursalOri int
declare @dni int
set @dni=(select top 1 dni from recursosHumanos.empleado)
set @idSucursalNuevo=(select top 1 id from sucursales.sucursal)
set @idSucursalOri=(select idSucursal from recursosHumanos.empleado where dni=@dni and idSucursal<>@idSucursalNuevo)
select e.dni,e.nombre,e.idSucursal,s.ciudad,s.direccion from recursosHumanos.empleado e inner join sucursales.sucursal s
on e.idSucursal=s.id where dni=@dni
exec recursosHumanos.cambiarSucursalEmpleadoPorDni @dni,@idSucursalNuevo
select e.dni,e.nombre,e.idSucursal,s.ciudad,s.direccion from recursosHumanos.empleado e inner join sucursales.sucursal s
on e.idSucursal=s.id where dni=@dni
exec recursosHumanos.cambiarSucursalEmpleadoPorDni @dni,@idSucursalOri
select e.dni,e.nombre,e.idSucursal,s.ciudad,s.direccion from recursosHumanos.empleado e inner join sucursales.sucursal s
on e.idSucursal=s.id where dni=@dni
go


--CAMBIAR TURNO DE UN EMPLEADO
--usando legajo
--intentamos ingresar datos nulos
exec recursosHumanos.cambiarTurnoEmpleadoPorLegajo null,null
--intentamos ingresar un turno que no existe con un legajo que no existe
exec recursosHumanos.cambiarTurnoEmpleadoPorLegajo 29,'Jornada nocturna'

--ahora un caso valido donde cambiamos el turno a turno mañana y luego lo restauramos (ejecutar bloque completo)
declare @legajo int
declare @turnoViejo varchar(20)
set @legajo=(select top 1 legajo from recursosHumanos.empleado)
set @turnoViejo=(select top 1 turno from recursosHumanos.empleado where turno<>'TM' and legajo=@legajo)
select * from recursosHumanos.empleado where legajo=@legajo
exec recursosHumanos.cambiarTurnoEmpleadoPorLegajo @legajo,'TM'
select * from recursosHumanos.empleado where legajo=@legajo
exec recursosHumanos.cambiarTurnoEmpleadoPorLegajo @legajo,@turnoViejo
select * from recursosHumanos.empleado where legajo=@legajo
go

--intentamos ingresar datos nulos
exec recursosHumanos.cambiarTurnoEmpleadoPorDni null,null
--intentamos ingresar un turno que no existe con un legajo que no existe
exec recursosHumanos.cambiarTurnoEmpleadoPorDni 29,'Jornada nocturna'

--ahora un caso valido (ejecutar bloque completo)
declare @dni int
declare @turnoViejo varchar(20)
set @dni=(select top 1 dni from recursosHumanos.empleado)
set @turnoViejo=(select top 1 turno from recursosHumanos.empleado where turno<>'TM' and dni=@dni)
select * from recursosHumanos.empleado where dni=@dni
exec recursosHumanos.cambiarTurnoEmpleadoPorDni @dni,'TM'
select * from recursosHumanos.empleado where dni=@dni
exec recursosHumanos.cambiarTurnoEmpleadoPorDni @dni,@turnoViejo
select * from recursosHumanos.empleado where dni=@dni
go

--DAR DE ALTA UN EMPLEADO
--con legajo
--pasamos un legajo nulo
exec recursosHumanos.darDeAltaEmpleadoPorLegajo null
--ahora uno que no existe
exec recursosHumanos.darDeAltaEmpleadoPorLegajo 2

--Ahora un caso valido (ejecutar bloque completo)
select legajo,nombre,activo from recursosHumanos.empleado where legajo=257020
--la damos de baja
update recursosHumanos.Empleado
set activo=0
where legajo=257020

select legajo,nombre,activo from recursosHumanos.empleado where legajo=257020
--la damos de alta usando el sp
exec recursosHumanos.darDeAltaEmpleadoPorLegajo 257020
select legajo,nombre,activo from recursosHumanos.empleado where legajo=257020


--con dni
--pasamos un dni nulo
exec recursosHumanos.darDeAltaEmpleadoPorDni null
--ahora uno que no existe
exec recursosHumanos.darDeAltaEmpleadoPorDni 2
select * from recursosHumanos.Empleado
--Ahora un caso valido (ejecutar bloque completo)
select legajo,nombre,activo from recursosHumanos.empleado where dni=36383025
--la damos de baja
update recursosHumanos.Empleado
set activo=0
where dni=36383025

select legajo,nombre,activo from recursosHumanos.empleado where dni=36383025
--la damos de alta usando el sp
exec recursosHumanos.darDeAltaEmpleadoPorDni 36383025
select legajo,nombre,activo from recursosHumanos.empleado where dni=36383025

---***CARGO***
--Intentamos modificar el nombre de un cargo que no existe y un nombre invalido
exec recursosHumanos.modificarNombreCargo @idCargo = null, @nvoNombre = '   '
--Intentamos modificar el nombre a otro nombre que ya existe
exec recursosHumanos.modificarNombreCargo @idCargo = 1, @nvoNombre = 'Supervisor'
--Modficamos el nombre de un cargo
select * from recursosHumanos.Cargo where id = 1
exec recursosHumanos.modificarNombreCargo @idCargo = 1, @nvoNombre = 'Manager'

update recursosHumanos.Cargo set cargo = 'Cajero' where id = 1

---***LINEAPRODUCTO***
--Intentamos modificar el nombre de una linea que no existe y un nombre invalido
exec catalogo.modificarNombreLineaProducto @idLn = -1, @nvoNombre = null
--Intentamos modificar el nombre a otro nombre que ya existe
exec catalogo.modificarNombreLineaProducto @idLn = 1, @nvoNombre = 'Almacen'
--Modificamos el nombre de una linea
select * from catalogo.LineaProducto where id = 1
exec catalogo.modificarNombreLineaProducto @idLn = 1, @nvoNombre = 'Mascotas'

update catalogo.LineaProducto set lineaProd = 'Almacen' where id = 1

---***TIPOCLIENTE***
--Intentamos modificar el nombre de un tipo que no existe y un nombre invalido
exec clientes.modificarNombreTipoCliente @idTipo = -1, @nvoNombre = null
--Intentamos modificar el nombre a otro nombre que ya existe
exec clientes.modificarNombreTipoCliente @idTipo = 1, @nvoNombre = 'Member'
--Modificamos el nombre de una linea
select * from clientes.TipoCliente where id = 1
exec clientes.modificarNombreTipoCliente @idTipo = 1, @nvoNombre = 'VIP'

update clientes.TipoCliente set tipo = 'Member' where id = 1

--***CATEGORIA***
--MODIFICAR NOMBRE
--Intentamos modificar el nombre de una categoria que no existe y un nombre invalido
exec catalogo.modificarNombreCategoria @idCat = -1, @nvoNombre = null
--Intentamos modificar el nombre a otro nombre que ya existe
exec catalogo.modificarNombreCategoria @idCat = 1, @nvoNombre = 'aceite_vinagre_y_sal'
--Modificamos el nombre de una linea
select * from catalogo.Categoria where id = 1
exec catalogo.modificarNombreCategoria @idCat = 1, @nvoNombre = 'comida_mascota'

update catalogo.Categoria set categoria = 'comida_mascota' where id = 1

--MODIFICAR LINEA DE PRODUCTO
--Intentamos modificar la linea de producto a la que pertenece una categoria inexistente
-- a una linea inexistente
exec catalogo.modificarLineaDeCategoria @idCat = -1 , @idLin = null 
--Modificamos la linea de producto a la que pertenece una categoria
select * from catalogo.Categoria where id = 1
exec catalogo.modificarLineaDeCategoria @idCat = 1 , @idLin = 5

update catalogo.Categoria set idLineaProd = 1 where id = 1

--***MEDIODEPAGO***
--Intentamos modificar los nombres de un medio de pago inexistente por nombres invalidos
exec comprobantes.modificarNombresMedioPago @idMp = null , @nvoNomIng = null, @nvoNomEsp = '   '
--Intentamos modificar los nombres por otros existentes
exec comprobantes.modificarNombresMedioPago @idMp = 1 , @nvoNomIng = 'Credit card', @nvoNomEsp = 'Tarjeta de credito'
--Modificamos los nombres de un medio de pago
select * from comprobantes.MedioDePago where id = 1
exec comprobantes.modificarNombresMedioPago @idMp = 1 , @nvoNomIng = 'Transfer', @nvoNomEsp = 'Transerencia'

update comprobantes.MedioDePago
set nombreEsp = 'Tarjeta de credito',
	nombreIng = 'Credit card'
where id = 1

--***PRODUCTO***
--MODIFICAR PRECIO
--Intentamos modifcar el precio de un producto inexistente por un precio invalido
exec catalogo.modificarPrecioProducto @idProd = -1, @nvoPrecio = 0
--Modificamos el precio de un producto
select * from catalogo.Producto where id = 1
exec catalogo.modificarPrecioProducto @idProd = 1, @nvoPrecio = 1.23

update catalogo.Producto set precio = 0.26 where id = 1

--MODIFICAR PRECIO USD
--Intentamos modifcar el precio de un producto inexistente por un precio invalido
exec catalogo.modificarPrecioUSDProducto @idProd = -1, @nvoPrecio = null
--Modificamos el precio en dolares de un producto
select * from catalogo.Producto where id = 1
exec catalogo.modificarPrecioUSDProducto @idProd = 1, @nvoPrecio = 1.23

update catalogo.Producto set precioUSD = NULL where id = 1

--MODIFICAR PRECIO REFERENCIA
--Intentamos modifcar el precio de un producto inexistente por un precio invalido
exec catalogo.modificarPrecioReferenciaProducto @idProd = -1, @nvoPrecio = null
--Modificamos el precio en dolares de un producto
select * from catalogo.Producto where id = 1
exec catalogo.modificarPrecioReferenciaProducto @idProd = 1, @nvoPrecio = 3.08

update catalogo.Producto set precioRef = 1.29 where id = 1

--MODIFICAR FECHA
--Intentamos modificar la fecha de un producto inexistente
declare @fecha smalldatetime
set @fecha = getdate()
exec catalogo.modificarFechaProducto @idProd = null, @fechaYHora = @fecha
--Intentamos modificar a una fecha mas antigua
select * from catalogo.Producto where id = 1
declare @fecha smalldatetime
set @fecha = cast('20190721 12:06' as smalldatetime)
exec catalogo.modificarFechaProducto @idProd = 1, @fechaYHora = @fecha
--Modificamos la fecha de un producto
select * from catalogo.Producto where id = 1
declare @fecha smalldatetime
set @fecha = getdate()
exec catalogo.modificarFechaProducto @idProd = 1, @fechaYHora = @fecha

update catalogo.Producto set fecha = cast('20200721 12:06' as smalldatetime) where id = 1

--MODIFICAR A PRODUCTO ACTIVO
--Intentamos dar de alta un producto que no existe
exec catalogo.darAltaProductoEnBaja null
--Damos de un alta un producto que no esta activo
update catalogo.Producto set activo = 0 where id = 1
select * from catalogo.Producto where id = 1
exec catalogo.darAltaProductoEnBaja 1

--AUMENTAR PRECIO DE PRODUCTO CON PORCENTAJE POR CATEGORIA
--intentamos ingresar un porcentaje y id de categoria nulos
exec catalogo.aumentarPrecioProductoPorCategoria null,null
--ahora una categoria que existe pero porcentaje 0
exec catalogo.aumentarPrecioProductoPorCategoria 1,0

--ahora intentemos un caso valido, para esto ejecutamos la transaccion completa
begin transaction
	select top 5 p.id,p.nombre,p.precio,c.categoria from catalogo.Producto p
	inner join catalogo.PerteneceA pa
	on p.id=pa.idProd
	inner join catalogo.categoria c
	on c.id=pa.idCategoria
	where c.id=1
	--ejecutamos el sp
	exec catalogo.aumentarPrecioProductoPorCategoria 1,100 --aumentamos el precio un 100% (duplicamos)
	--vemos el aumento
	select top 5 p.id,p.nombre,p.precio,c.categoria from catalogo.Producto p
	inner join catalogo.PerteneceA pa
	on p.id=pa.idProd
	inner join catalogo.categoria c
	on c.id=pa.idCategoria
	where c.id=1
--deshacemos el update con rollback
rollback

--AUMENTAR PRECIO USD DE PRODUCTO CON PORCENTAJE POR CATEGORIA (siempre que el producto tenga el precio en USD, si no lo tiene lo ignora)
--intentamos ingresar un porcentaje y id de categoria nulos
exec catalogo.aumentarPrecioUSDProductoPorCategoria null,null
--ahora una categoria que existe pero porcentaje 0
exec catalogo.aumentarPrecioUSDProductoPorCategoria 1,0

--ahora intentemos un caso valido, para esto ejecutamos la transaccion completa
begin transaction
	select top 5 p.id,p.nombre,p.precioUSD,c.categoria from catalogo.Producto p
	inner join catalogo.PerteneceA pa
	on p.id=pa.idProd
	inner join catalogo.categoria c
	on c.id=pa.idCategoria
	where precioUSD is not null
	--ejecutamos el sp
	exec catalogo.aumentarPrecioUSDProductoPorCategoria 149,100 --aumentamos el precio un 100% (duplicamos), 149 es la categoria electronica

	--vemos el aumento
	select top 5 p.id,p.nombre,p.precioUSD,c.categoria from catalogo.Producto p
	inner join catalogo.PerteneceA pa
	on p.id=pa.idProd
	inner join catalogo.categoria c
	on c.id=pa.idCategoria
	where precioUSD is not null
	--deshacemos el update con rollback
rollback

--REDUCIR PRECIO DE PRODUCTO CON PORCENTAJE POR CATEGORIA
--intentamos ingresar un porcentaje y categoria nulos
exec catalogo.reducirPrecioProductoPorCategoria null,null
--ahora una categoria que existe pero porcentaje 0
exec catalogo.reducirPrecioProductoPorCategoria 1,0
--ahora lo mismo pero con un porcentaje mayor a 100
exec catalogo.reducirPrecioProductoPorCategoria 1,100

--ahora un caso valido, para esto ejecutamos la transaccion completa
begin transaction
	select top 5 p.id,p.nombre,p.precio,c.categoria from catalogo.Producto p
	inner join catalogo.PerteneceA pa
	on p.id=pa.idProd
	inner join catalogo.categoria c
	on c.id=pa.idCategoria
	where c.id=1
	--ejecutamos el sp
	exec catalogo.reducirPrecioProductoPorCategoria 1,50 --reducimos el precio a la mitad (50% de descuento)
	--vemos el aumento
	select top 5 p.id,p.nombre,p.precio,c.categoria from catalogo.Producto p
	inner join catalogo.PerteneceA pa
	on p.id=pa.idProd
	inner join catalogo.categoria c
	on c.id=pa.idCategoria
	where c.id=1
	--deshacemos el update con rollback
rollback

--REDUCIR PRECIO USD DE PRODUCTO CON PORCENTAJE POR CATEGORIA
--intentamos ingresar un porcentaje y categoria nulos
exec catalogo.reducirPrecioUSDProductoPorCategoria null,null
--ahora una categoria que existe pero porcentaje 0
exec catalogo.reducirPrecioUSDProductoPorCategoria 1,0
--ahora lo mismo pero con un porcentaje mayor a 100
exec catalogo.reducirPrecioUSDProductoPorCategoria 1,100

--ahora un caso valido, para esto ejecutamos la transaccion completa
begin transaction
	select top 5 p.id,p.nombre,p.precioUSD,c.categoria from catalogo.Producto p
	inner join catalogo.PerteneceA pa
	on p.id=pa.idProd
	inner join catalogo.categoria c
	on c.id=pa.idCategoria
	where precioUSD is not null
	--ejecutamos el sp
	exec catalogo.reducirPrecioUSDProductoPorCategoria 149,50 --reducimos el precio a la mitad (50% de descuento) (149 es el id de la categoria tecnologia)
	--vemos el aumento
	select top 5 p.id,p.nombre,p.precioUSD,c.categoria from catalogo.Producto p
	inner join catalogo.PerteneceA pa
	on p.id=pa.idProd
	inner join catalogo.categoria c
	on c.id=pa.idCategoria
	where precioUSD is not null
	--deshacemos el update con rollback
rollback

--CAMBIAR NOMBRE DE UN PRODUCTO
--intentamos usar datos nulos
exec catalogo.modificarNombreProducto null,null
--ahora un idProd inexistente junto con un nombre de espacios solos
exec catalogo.modificarNombreProducto 1,'    '
--ahora un caso valido (ejecutar transaccion completa)
begin transaction
	select id,nombre,precio from catalogo.producto where id=1
	exec catalogo.modificarNombreProducto 1,'Bujia hescher'
	--vemos el cambio
	select id,nombre,precio from catalogo.producto where id=1
	--deshacemos el cambio
rollback

--CAMBIAR PROVEEDOR DE UN PRODUCTO
--intentamos usar datos nulos
exec catalogo.modificarProveedorProducto null,null
--ahora un idProducto inexistente junto con un proveedor de espacios solos
exec catalogo.modificarProveedorProducto 293202,'        '

--ahora un caso valido
begin transaction
	select id,nombre,precio,proveedor from catalogo.producto where id=1
	exec catalogo.modificarProveedorProducto 1,'Kwik-E-Mart'
	--vemos los cambios
	select id,nombre,precio,proveedor from catalogo.producto where id=1
	--deshacemos los cambios
rollback

--CAMBIAR LA CANTIDAD POR UNIDAD DEL PRODUCTO
--Probamos un producto que no existe y una cantidad por unidad vacia
exec catalogo.modificarCantXUnProducto 123456789, '    ' 
--Cambiamos la cantidad por unidad de un producto
begin transaction
	select * from catalogo.Producto where id = 1
	exec catalogo.modificarCantXUnProducto 1, '1bolsa - 1kg'
	select * from catalogo.Producto where id = 1
rollback


--**PERTENECEA**
--CAMBIAR CATEGORIA DE PRODUCTO
select * from catalogo.PerteneceA where idProd = 1
--intentamos cambiar la categoria de un producto a uno que no existe
exec catalogo.modificarCategoriaDeProducto @idProd = 1, @idCatAnt = 90, @idCatNvo = 19000
--ahora intentamos con datos nulos
exec catalogo.modificarCategoriaDeProducto null, null, null
--ahora con un producto que no existe
exec catalogo.modificarCategoriaDeProducto @idProd = 190291, @idCatAnt = 1, @idCatNvo = 3

--ahora un caso valido donde cambiamos la categoria del producto y luego lo restauramos usando el mismo sp (ejecutar bloque completo)
declare @idProd int
declare @nuevaCat int
declare @oriCat int
set @idProd=(select top 1 id from catalogo.producto)
set @oriCat=(select c.id from catalogo.Categoria c 
			inner join catalogo.PerteneceA a on c.id=a.idCategoria where a.idProd=@idProd)
set @nuevaCat=(select top 1 id from catalogo.Categoria where id<>@oriCat)

exec catalogo.modificarCategoriaDeProducto @idProd = @idProd,@idCatAnt = @oriCat, @idCatNvo = @nuevaCat --cambiamos la categoria usando el sp
select p.id, p.nombre, c.categoria,lp.lineaProd 
from catalogo.Producto p 
	inner join catalogo.PerteneceA pa on p.id=pa.idProd 
	inner join catalogo.categoria c on c.id=pa.idCategoria 
	inner join catalogo.LineaProducto lp on lp.id=c.idLineaProd where p.id=@idProd
--restauramos la categoria tambien usando el sp
declare @idProd int
declare @nuevaCat int
declare @oriCat int
set @idProd=(select top 1 id from catalogo.producto)
set @oriCat=(select c.id from catalogo.Categoria c 
			inner join catalogo.PerteneceA a on c.id=a.idCategoria where a.idProd=@idProd)
set @nuevaCat=(select top 1 id from catalogo.Categoria where categoria = 'fruta')

exec catalogo.modificarCategoriaDeProducto @idProd = @idProd, @idCatAnt = @oriCat, @idCatNvo = @nuevaCat 
select p.id, p.nombre, c.categoria,lp.lineaProd 
from catalogo.Producto p 
	inner join catalogo.PerteneceA pa on p.id=pa.idProd 
	inner join catalogo.categoria c on c.id=pa.idCategoria 
	inner join catalogo.LineaProducto lp on lp.id=c.idLineaProd where p.id=@idProd

declare @idProd int
set @idProd=(select top 1 id from catalogo.producto)
select p.id, p.nombre, c.categoria,lp.lineaProd from catalogo.Producto p inner join catalogo.PerteneceA pa on p.id=pa.idProd inner join
catalogo.categoria c on c.id=pa.idCategoria inner join catalogo.LineaProducto lp on lp.id=c.idLineaProd where p.id=@idProd
--nota que si modificas la categoria de un producto, su linea de producto tambien cambia (ya que la categoria se asocia a una lp especifica)


--**CLIENTE**
--CAMBIAR TIPO DE CLIENTE DE UN CLIENTE
--probamos con datos nulos
exec clientes.cambiarTipoCliente null,null
--ahora probamos con un cliente que no existe y un tipo de cliente que no existe
exec clientes.cambiarTipoCliente 293902,39293
--ahora con un caso valido (ejecutar transaccion completa)
begin transaction
	declare @idCli int
	set @idCli=(select top 1 id from clientes.cliente where idTipo<>2)
	--vemos que el cliente es del tipo 1
	select c.id,c.ciudad,c.genero,tc.id,tc.tipo from clientes.cliente c inner join clientes.TipoCliente tc on c.idTipo=tc.id where c.id=@idCli
	exec clientes.cambiarTipoCliente @idCli,2
	--vemos que se modifico
	select c.id,c.ciudad,c.genero,tc.id,tc.tipo from clientes.cliente c inner join clientes.TipoCliente tc on c.idTipo=tc.id where c.id=@idCli
	--restauramos el  estado original
rollback


--Cambiar un grupo de clientes pertenecientes a un tipo a otro tipo nuevo (pensado para ser usado en conjunto con clientes.clientes.borrarTipoDeCliente)
--probamos con datos nulos para ver que no se puede
exec clientes.cambiarClientesDeUnTipoAOtro null,null
--ahora con tipos de cliente que no existen
exec clientes.cambiarClientesDeUnTipoAOtro 1932902,29392
--ahora un caso valido donde vamos a pasar todos los clientes de un tipo a otro
begin transaction
	declare @idTipoNvo int
	declare @idTipoViejo int
	set @idTipoViejo=(select top 1 id from clientes.TipoCliente)
	set @idTipoNvo=(select top 1 id from clientes.TipoCliente where id<>@idTipoViejo)
	--vemos cuantos clientes del tipo actual hay
	select count(1) as cantClientesTipoViejo from clientes.cliente where idTipo=@idTipoViejo
	--los cambiamos a la clase nueva
	exec clientes.cambiarClientesDeUnTipoAOtro @idTipoViejo,@idTipoNvo
	--vemos que se cambiaron contando cuantos clientes del tipo viejo hay
	select count(1) as cantClientesTipoViejo from clientes.cliente where idTipo=@idTipoViejo
	--restauramos los clientes a su tipo anterior
rollback


--CAMBIAR NOMBRE DE CLIENTE
--probamos con datos nulos
exec clientes.cambiarNombreCliente null,null 
--ahora con un cliente que no existe
exec clientes.cambiarNombreCliente 282382,'Pollito'
--ahora con un nombre de solo espacios
exec clientes.cambiarNombreCliente 1,'    '

--ahora un caso valido donde al cliente con id 1 le cambiamos el nombre a Pollito (ejecutar transaccion completa)
begin transaction
	--vemos el nombre que tiene ahora mismo (podria no tenerlo si corresponde a alguno de los cargados por archivo)
	select * from clientes.cliente
	where id=1
	--le ponemos el nombre nuevo
	exec clientes.cambiarNombreCliente 1,'Pollito'
	--vemos que se efecutaron los cambios
	select * from clientes.cliente
	where id=1
	--restauramos los datos
rollback

--CAMBIAR APELLIDO DE CLIENTE
--probamos con datos nulos
exec clientes.cambiarApellidoCliente null,null 
--ahora con un cliente que no existe
exec clientes.cambiarApellidoCliente 282382,'Perez'
--ahora con un nombre de solo espacios
exec clientes.cambiarApellidoCliente 1,'    '

--ahora un caso valido donde al cliente con id 1 le cambiamos el apellido a Perez (ejecutar transaccion completa)
begin transaction
	--vemos el apellido que tiene ahora mismo (podria no tenerlo si corresponde a alguno de los cargados por archivo)
	select * from clientes.cliente
	where id=1
	--le ponemos el apellido nuevo
	exec clientes.cambiarApellidoCliente 1,'Perez'
	--vemos que se efecutaron los cambios
	select * from clientes.cliente
	where id=1
	--restauramos los datos
rollback

--CAMBIAR CIUDAD DE CLIENTE
--probamos con datos nulos
exec clientes.cambiarCiudadCliente null,null 
--ahora con un cliente que no existe
exec clientes.cambiarCiudadCliente 282382,'Springfield'
--ahora con un nombre de solo espacios
exec clientes.cambiarCiudadCliente 1,'    '

--ahora un caso valido donde al cliente con id 1 le cambiamos la ciudad a Springfield (ejecutar transaccion completa)
begin transaction
	--vemos la ciudad que tiene ahora mismo
	select * from clientes.cliente
	where id=1
	--le ponemos la ciudad nueva
	exec clientes.cambiarCiudadCliente 1,'Springfield'
	--vemos que se efecutaron los cambios
	select * from clientes.cliente
	where id=1
	--restauramos los datos
rollback

--CAMBIAR GENERO DE CLIENTE
--probamos con datos nulos
exec clientes.cambiarGeneroCliente null,null 
--ahora con un cliente que no existe
exec clientes.cambiarGeneroCliente 282382,'Male'
--ahora con un nombre de solo espacios
exec clientes.cambiarGeneroCliente 1,'    '

--ahora un caso valido donde al cliente le cambiamos el genero a male(ejecutar transaccion completa)
begin transaction
	declare @idCli int
	set @idCli=(select top 1 id from clientes.cliente where genero<>'Male')
	--vemos el genero que tiene ahora mismo
	select * from clientes.cliente
	where id=@idCli
	--le ponemos el nombre nuevo
	exec clientes.cambiarGeneroCliente 1,'Male'
	--vemos que se efecutaron los cambios
	select * from clientes.cliente
	where id=@idCli
	--restauramos los datos
rollback

--DAR DE ALTA CLIENTE EN BAJA
--intentamos con parametros nulos
exec clientes.darAltaClienteEnBaja null
--intentamos con un cliente que no existe
exec clientes.darAltaClienteEnBaja -1
--damos de alta un cliente que esta en baja
begin transaction
	update clientes.Cliente set activo = 0 where id = 1
	select * from clientes.Cliente where id = 1
	exec clientes.darAltaClienteEnBaja 1
	select * from clientes.Cliente where id = 1
rollback


--***FACTURA***
--MODIFICAR EL IDFACTURA
--intentamos con parametros nulos
exec ventas.modificarIdFactura @id = null, @idFactura = null
--intentamos un id que no existe y un idfactura invalido
exec ventas.modificarIdFactura @id = -1, @idFactura = '1-11-111'
--intentamos modificar una factura pagada y un idfactura en uso
select * from ventas.Factura where id = 1
exec ventas.modificarIdFactura @id = -1, @idFactura = '750-67-8428'
--modificamos el idfactura de una factura impaga
begin transaction
	insert into ventas.Factura(idFactura, estado) values('111-11-1111', 'Impaga')
	declare @id char(11) = (select id from ventas.Factura where idFactura = '111-11-1111')
	select * from ventas.Factura where id = @id
	exec ventas.modificarIdFactura @id = @id, @idFactura = '222-22-2222'

	declare @id char(11) = (select id from ventas.Factura where idFactura = '222-22-2222')
	select * from ventas.Factura where id = @id
rollback

--MODIFICAR TIPO DE FACTURA
--intentamos con parametros nulos
exec ventas.modificarTipoFactura @id = null, @tipoFactura = null
--intentamos un id que no existe y un tipo de factura invalido
exec ventas.modificarTipoFactura @id = -1, @tipoFactura = 'z'
--intentamos con una factura pagada
exec ventas.modificarTipoFactura @id = 1, @tipoFactura = 'A'
--modificamos el tipo de una factura
begin transaction
	insert into ventas.Factura(idFactura, estado) values('111-11-1111', 'Impaga')
	declare @id char(11) = (select id from ventas.Factura where idFactura = '111-11-1111')
	select * from ventas.Factura where id = @id
	exec ventas.modificarTipoFactura @id = @id, @tipoFactura = 'A'
	select * from ventas.Factura where id = @id
rollback

--MODIFICAR FECHA FACTURA
--intentamos con parametros nulos
exec ventas.modificarFechaFactura @id = null, @fecha = null
--intentamos con un id que no existe
exec ventas.modificarFechaFactura @id = -1, @fecha = '2020-01-01'
--intentamos con una factura pagada
exec ventas.modificarFechaFactura @id = 1, @fecha = '2020-01-01'
--modificamos la fecha de una factura
begin transaction
	insert into ventas.Factura(idFactura, estado) values('111-11-1111', 'Impaga')
	declare @id char(11) = (select id from ventas.Factura where idFactura = '111-11-1111')
	select * from ventas.Factura where id = @id
	exec ventas.modificarFechaFactura @id = @id, @fecha = '2020-01-01'
	select * from ventas.Factura where id = @id
rollback

--MODIFICAR LA HORA DE LA FACTURA
--intentamos com parametros nulos
exec ventas.modificarFechaFactura @id = null, @hora = null
--intentamos con un id que no existe
exec ventas.modificarFechaFactura @id = -1, @hora = '12:03'
--intentamos con una facutura pagada
exec ventas.modificarFechaFactura @id = 1, @hora = '12:03'
--modificamos la hora de una factura
begin transaction
	insert into ventas.Factura(idFactura, estado) values('111-11-1111', 'Impaga')
	declare @id char(11) = (select id from ventas.Factura where idFactura = '111-11-1111')
	select * from ventas.Factura where id = @id
	exec ventas.modificarFechaFactura @id = @id, @hora = '12:03'
	select * from ventas.Factura where id = @id
rollback

--MODIFICAR EMPLEADO DE UNA FACTURA
--intentamos con parametros nulos
exec ventas.modificarEmpleadoDeFactura @id = null, @legajoEmp = null
--intentamos con un id que no existe y empleado que no existe
exec ventas.modificarEmpleadoDeFactura @id = -1, @legajoEmp = 2
--intentamos con una factura pagada
declare @legajo int = (select top 1 legajo from recursosHumanos.Empleado)
exec ventas.modificarEmpleadoDeFactura @id = 1, @legajoEmp = @legajo
--modificamos el empleado que genera la factura
begin transaction
	insert into ventas.Factura(idFactura, estado) values('111-11-1111', 'Impaga')
	declare @id char(11) = (select id from ventas.Factura where idFactura = '111-11-1111')
	declare @legajo int = (select top 1 legajo from recursosHumanos.Empleado)
	select * from ventas.Factura where id = @id
	exec ventas.modificarEmpleadoDeFactura @id = @id, @legajoEmp = @legajo
	select * from ventas.Factura where id = @id
rollback

--MODIFICAR CLIENTE FACTURA
--intentamos con parametros nulos
exec ventas.modificarClienteDeFactura @id = null, @idCliente = null
--intentamos con un id que no existe y empleado que no existe
exec ventas.modificarClienteDeFactura @id = -1, @idCliente = -1
--intentamos con una factura pagada
exec ventas.modificarClienteDeFactura @id = 1, @idCliente = 1
--modificamos el empleado que genera la factura
begin transaction
	insert into ventas.Factura(idFactura, estado) values('111-11-1111', 'Impaga')
	declare @id char(11) = (select id from ventas.Factura where idFactura = '111-11-1111')
	select * from ventas.Factura where id = @id
	exec ventas.modificarClienteDeFactura @id = @id, @idCliente = 1
	select * from ventas.Factura where id = @id
rollback

---***LINEA DE FACTURA***
--MODIFICAR PRODUCTO DE LINEA DE FACTURA
-- intentamos con parametros nulos
exec ventas.modificarProductoLineaDeFactura @idLn = null, @idFactura = null, @idProd = null
--intentamos con una linea, factura y producto inexistentes
exec ventas.modificarProductoLineaDeFactura @idLn = -1, @idFactura = -1, @idProd = -1
--intentamos con una factura pagada y una linea que no pertenece a esa factura
exec ventas.modificarProductoLineaDeFactura @idLn = 1, @idFactura = 1, @idProd = 1
--intentamos con un producto inexistente
begin transaction
	insert into ventas.Factura(idFactura) values('111-11-1111')
	declare @idFactura int = (select id from ventas.Factura where idFactura = '111-11-1111')
	insert into ventas.LineaDeFactura(idFactura)
		values(@idFactura)
	declare @idLn int = (select top 1 id from ventas.LineaDeFactura where idFactura = @idFactura)
	exec ventas.modificarProductoLineaDeFactura @idLn = @idLn, @idFactura = @idFactura, @idProd = -1
rollback
--intentamos modificar el producto de una linea a un producto que tiene otra linea de la misma factura
begin transaction
	insert into ventas.Factura(idFactura) values('111-11-1111')
	declare @idFactura int = (select id from ventas.Factura where idFactura = '111-11-1111')
	insert into ventas.LineaDeFactura(idFactura, idProd)
		values(@idFactura, 1)
	insert into ventas.LineaDeFactura(idFactura, idProd)
		values(@idFactura, 2)
	declare @idLn int = (select top 1 id from ventas.LineaDeFactura where idFactura = @idFactura)
	exec ventas.modificarProductoLineaDeFactura @idLn = @idLn, @idFactura = @idFactura, @idProd = 2
rollback
--modificamos el producto de una linea de una factura
begin transaction
	insert into ventas.Factura(idFactura) values('111-11-1111')
	declare @idFactura int = (select id from ventas.Factura where idFactura = '111-11-1111')
	insert into ventas.LineaDeFactura(idFactura, idProd, cantidad, precioUn)
		values(@idFactura, 1, 3, 2)
	declare @idLn int = (select top 1 id from ventas.LineaDeFactura where idFactura = @idFactura)
	select * from ventas.LineaDeFactura where id = @idLn
	exec ventas.modificarProductoLineaDeFactura @idLn = @idLn, @idFactura = @idFactura, @idProd = 2
	select * from ventas.LineaDeFactura where id = @idLn
rollback

--MODIFICAR IDFACTURA DE LA LINEA DE FACTURA
--intentamos con parametros nulos
exec ventas.modificarIdFacturaLineaDeFactura @idLn = null, @idFactura = null
--intentamos con parametros que no existen
exec ventas.modificarIdFacturaLineaDeFactura @idLn = -1, @idFactura = -1
--intentamos con una linea asociada con una factura pagada y una factura pagada
exec ventas.modificarIdFacturaLineaDeFactura @idLn = 1, @idFactura = 1
--intentamos con una linea que tiene un producto que ya se encuentra en una de las lineas
--de la nueva factura
begin transaction
	insert into ventas.Factura(idFactura) values ('111-11-1111'), ('222-22-2222')
	insert into ventas.LineaDeFactura(idFactura, idProd)
		select id, 1 from ventas.Factura where idFactura in ('111-11-1111', '222-22-2222')
	declare @idFactura1 int = (select id from ventas.Factura where idFactura = '111-11-1111')
	declare @idLn int = (select id from ventas.LineaDeFactura where idFactura = @idFactura1 )
	declare @idFactura2 int = (select id from ventas.Factura where idFactura = '222-22-2222')
	exec ventas.modificarIdFacturaLineaDeFactura @idLn = @idLn, @idFactura = @idFactura2
rollback
--modificamos el idFactura de una linea
begin transaction
	insert into ventas.Factura(idFactura) values ('111-11-1111'), ('222-22-2222')
	insert into ventas.LineaDeFactura(idFactura, idProd)
		select id, 1 from ventas.Factura where idFactura in ('111-11-1111')
	insert into ventas.LineaDeFactura(idFactura, idProd)
		select id, 2 from ventas.Factura where idFactura in ('222-22-2222')
	
	declare @idFactura1 int = (select id from ventas.Factura where idFactura = '111-11-1111')
	declare @idLn int = (select id from ventas.LineaDeFactura where idFactura = @idFactura1 )
	declare @idFactura2 int = (select id from ventas.Factura where idFactura = '222-22-2222')

	select * from ventas.LineaDeFactura where idFactura in (@idFactura1, @idFactura2)
	exec ventas.modificarIdFacturaLineaDeFactura @idLn = @idLn, @idFactura = @idFactura2
	select * from ventas.LineaDeFactura where idFactura in (@idFactura1, @idFactura2)
rollback

--MODIFICAR CANTIDAD DE UNA LINEA DE FACTURA
--intentamos con parametros nulos
exec ventas.modificarCantidadLineaDeFactura @idLn = null, @cantidad = null
--intentamos con una linea inexistente y cantidad invalida
exec ventas.modificarCantidadLineaDeFactura @idLn = -1, @cantidad = 0
--intentamos con una linea asociada a una factura pagada	
exec ventas.modificarCantidadLineaDeFactura @idLn = 1, @cantidad = 3
--modificamos la cantidad de una linea de factura
begin transaction
	insert into ventas.Factura(idFactura) values ('111-11-1111')
	declare @idFactura int = (select id from ventas.Factura where idFactura = '111-11-1111')
	insert into ventas.LineaDeFactura(idFactura, idProd, precioUn, cantidad, subtotal) 
		values (@idFactura, 1, 2.0, 2, 4)
	declare @idLn int = (select id from ventas.LineaDeFactura where idFactura = @idFactura )
	select * from ventas.LineaDeFactura where id = @idLn
	exec ventas.modificarCantidadLineaDeFactura @idLn = @idLn, @cantidad = 3
	select * from ventas.LineaDeFactura where id = @idLn
rollback