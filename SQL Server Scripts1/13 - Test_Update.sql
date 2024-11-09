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

--CAMBIAR CATEGORIA DE PRODUCTO
--intentamos cambiar la categoria de un producto a uno que no existe
exec catalogo.modificarCategoriaDeProducto 1,19000
--ahora intentamos con datos nulos
exec catalogo.modificarCategoriaDeProducto null,null
--ahora con un producto que no existe
exec catalogo.modificarCategoriaDeProducto 190291,3

--ahora un caso valido donde cambiamos la categoria del producto y luego lo restauramos usando el mismo sp (ejecutar bloque completo)
declare @idProd int
declare @nuevaCat int
declare @oriCat int
set @idProd=(select top 1 id from catalogo.producto)
set @oriCat=(select c.id from catalogo.Categoria c 
			inner join catalogo.PerteneceA a on c.id=a.idCategoria where a.idProd=@idProd)
set @nuevaCat=(select top 1 id from catalogo.Categoria where id<>@oriCat)

select p.id, p.nombre, c.categoria,lp.lineaProd 
from catalogo.Producto p 
	inner join catalogo.PerteneceA pa on p.id=pa.idProd 
	inner join catalogo.categoria c on c.id=pa.idCategoria 
	inner join catalogo.LineaProducto lp on lp.id=c.idLineaProd where p.id=@idProd
exec catalogo.modificarCategoriaDeProducto @idProd,@nuevaCat --cambiamos la categoria usando el sp

select p.id, p.nombre, c.categoria,lp.lineaProd 
from catalogo.Producto p 
	inner join catalogo.PerteneceA pa on p.id=pa.idProd 
	inner join catalogo.categoria c on c.id=pa.idCategoria 
	inner join catalogo.LineaProducto lp on lp.id=c.idLineaProd where p.id=@idProd
exec catalogo.modificarCategoriaDeProducto @idProd,@oriCat --restauramos la categoria tambien usando el sp

select p.id, p.nombre, c.categoria,lp.lineaProd from catalogo.Producto p inner join catalogo.PerteneceA pa on p.id=pa.idProd inner join
catalogo.categoria c on c.id=pa.idCategoria inner join catalogo.LineaProducto lp on lp.id=c.idLineaProd where p.id=@idProd
--nota que si modificas la categoria de un producto, su linea de producto tambien cambia (ya que la categoria se asocia a una lp especifica)

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