use [Com5600G13]
go
--CARGA INICIAL DE DATOS (ejecutar el SP, solo hace falta hacerlo una vez, si ya lo ejecuto previamente en otro script ignore este paso)
exec testing.crearDatosDePrueba
select * from sucursales.sucursal
--***SUCURSAL***
--DAR DE ALTA SUCURSAL DE BAJA
--Probamos con una sucursal que no existe
exec sucursales.darAltaSucursalEnBaja -1
--Damos de alta una sucursal de baja (para esto primero damos de baja la sucursal con id 1)
select * from sucursales.sucursal where id=1 --vemos que esta activo
exec sucursales.bajaSucursalId 1 --lo damos de baja
select * from sucursales.Sucursal where id = 1 --vemos que ya no esta activo
exec sucursales.darAltaSucursalEnBaja 1 --lo damos de alta 
select * from sucursales.Sucursal where id = 1 --vemos que vuelve a estar activo

--MODIFICAR DIRECCION
--Probamos con una sucursal que no existe (caso no valido)
exec sucursales.modificarDireccionSucursal -1, 'AV. Don Bosco 123', 'Moron'
--Probamos cambiar la direccion a una que tiene otra sucursal (caso no valido)
exec sucursales.modificarDireccionSucursal 1, 'Lavalle 9283, B9231, prov bs as, arg', 'Retiro'
--Modificamos la direccion (caso valido)
select * from sucursales.Sucursal where id=1 --vemos la ciudad y direccion actual
exec sucursales.modificarDireccionSucursal 1, 'AV. Don Bosco 123', 'Moron' --lo modificamos
select * from sucursales.Sucursal where id=1 --vemos que se modificaron la ciudad y direccion
exec sucursales.modificarDireccionSucursal 1, 'Torquinst 829, B1765 Lomas, prov bs as, arg', 'Lomas de Zamora' --lo restauramos usando el mismo sp
select * from sucursales.Sucursal where id=1 --vemos que se restauro


--MODIFICAR HORARIO
--Probamos con una sucursal que no existe
exec sucursales.modificarHorarioSucursal -1, 'L a V 8-10; S y D 10-12'
--Modificamos el horario
select * from sucursales.Sucursal where id = 1 --vemos el horario original
exec sucursales.modificarHorarioSucursal 1, 'L a V 8-10; S y D 10-12' --modificamos el horario
select * from sucursales.Sucursal where id = 1 --vemos que se modifico
exec sucursales.modificarHorarioSucursal 1, 'L a V 8 a. m.–9 p. m. S y D 9 a. m.-8 p. m.' --lo restauramos usando el mismo sp
select * from sucursales.Sucursal where id = 1 --vemos que se restauro


--MODIFICAR TELEFONO
--Probamos con una sucursal que no existe y un telefono invalido
exec sucursales.modificarTelefonoSucursal -1, '12'
--Modificamos el telefono
select * from sucursales.Sucursal where id=1 --vemos el telefono original de la sucursal con id 1
exec sucursales.modificarTelefonoSucursal 1, '2222-2222' --modificamos el telefono
select * from sucursales.Sucursal where id=1 --vemos que se modifico
exec sucursales.modificarTelefonoSucursal 1, '5555-5556' --restauramos el telefono
select * from sucursales.Sucursal where id=1 --vemos que se modifico

--***EMPLEADO***

--CAMBIAR NOMBRE DE EMPLEADO USANDO SU LEGAJO
--intentamos insertar un legajo y nombre nulo
exec recursosHumanos.cambiarNombreEmpleadoPorLegajo null,null
--ahora un legajo inexistente
exec recursosHumanos.cambiarNombreEmpleadoPorLegajo 9392932,'Roberto'
--ahora un caso valido
select nombre from recursosHumanos.Empleado where legajo=1
--Vemos que originalmente se llama Juan, lo cambiamos por Martin
exec recursosHumanos.cambiarNombreEmpleadoPorLegajo 1,'Martin'
--Vemos que los cambios se efectuaron
select nombre from recursosHumanos.Empleado where legajo=1
--deshacemos los cambios
exec recursosHumanos.cambiarNombreEmpleadoPorLegajo 1,'Juan'
select * from recursosHumanos.Empleado

--Existe otra version de este SP, funciona exactamente igual pero identifica al
--empleado usando su dni en vez de legajo:
select nombre from recursosHumanos.Empleado where dni=14068092
--Vemos que originalmente se llama Emilio, lo cambiamos por Agustin
exec recursosHumanos.cambiarNombreEmpleadoPorDni 14068092,'Agustin'
--Vemos que los cambios se efectuaron
select nombre from recursosHumanos.Empleado where dni=14068092
--deshacemos los cambios
exec recursosHumanos.cambiarNombreEmpleadoPorDni 14068092,'Emilio'

--CAMBIAR APELLIDO DE UN EMPLEADO
--usando legajo
--intentamos insertar parametros nulos
exec recursosHumanos.cambiarApellidoEmpleadoPorLegajo null,null
--ahora un caso valido donde cambiamos el apellido de lo que sea que tenga a Ramirez y luego denuevo al original (ejecuta todo el bloque)
--nota: este SP tambien formatea el apellido para que quede todo en mayuscula.
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
EXEC recursosHumanos.cambiarApellidoEmpleadoPorDni @dni, 'Carpenter'
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
EXEC recursosHumanos.cambiarDireccionEmpleadoPorDni @dni, 'Avenida SiempreViva 9893, Springfield, USA'
SELECT * FROM recursosHumanos.Empleado WHERE dni = @dni
EXEC recursosHumanos.cambiarDireccionEmpleadoPorDni @dni, @direccionOri
SELECT * FROM recursosHumanos.Empleado WHERE dni = @dni
GO

--CAMBIAR EMAIL PERSONAL DE UN EMPLEADO
--usando legajo
--intentamos insertar un correo vacio con un legajo inexistente
exec recursosHumanos.cambiarMailPersonalEmpleadoPorLegajo 2392,''
--ahora intentamos ingresar un correo que ya existe
exec recursosHumanos.cambiarMailPersonalEmpleadoPorLegajo 1,'juanvaldez@gmail.com'

--ahora vamos con un caso valido (ejecutar bloque completo) (ver la diferencia entre selects donde varia el email personal)
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
exec recursosHumanos.cambiarMailPersonalEmpleadoPorDni 14068092,'juanvaldez@gmail.com'


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
exec recursosHumanos.cambiarMailEmpresarialEmpleadoPorLegajo 1,'juanvaldez@empresa.com'
--ahora un caso valido (ejecutar bloque completo)
declare @legajo int
declare @correoEmpOri varchar(60)
set @legajo=(select legajo from recursosHumanos.Empleado where REPLACE(emailEmp, CHAR(9), ' ')='juanvaldez@empresa.com')
set @correoEmpOri=(select emailEmp from recursosHumanos.Empleado where legajo=@legajo)
select * from recursosHumanos.Empleado where legajo=@legajo
exec recursosHumanos.cambiarMailEmpresarialEmpleadoPorLegajo @legajo,'juanvaldez@losPollosHermanos.com'
select * from recursosHumanos.Empleado where legajo=@legajo
exec recursosHumanos.cambiarMailEmpresarialEmpleadoPorLegajo @legajo,'juanvaldez@empresa.com'
select * from recursosHumanos.Empleado where legajo=@legajo
go

--usando dni
--intentamos insertar un correo vacio con un legajo inexistente
exec recursosHumanos.cambiarMailEmpresarialEmpleadoPorDni 2392,''
--ahora intentamos ingresar un correo que ya existe
exec recursosHumanos.cambiarMailEmpresarialEmpleadoPorDni 14068092,'juanvaldez@empresa.com'

--ahora un caso valido (ejecutar bloque completo)
declare @dni int
declare @correoEmpOri varchar(60)
set @dni = (select dni from recursosHumanos.Empleado where REPLACE(emailEmp, CHAR(9), ' ') = 'juanvaldez@empresa.com')
set @correoEmpOri = (select emailEmp from recursosHumanos.Empleado where dni = @dni)
select * from recursosHumanos.Empleado where dni = @dni
exec recursosHumanos.cambiarMailEmpresarialEmpleadoPorDni @dni, 'juanvaldez@losPollosHermanos.com'
select * from recursosHumanos.Empleado where dni = @dni
exec recursosHumanos.cambiarMailEmpresarialEmpleadoPorDni @dni, @correoEmpOri
select * from recursosHumanos.Empleado where dni = @dni
go


--CAMBIAR CARGO DE UN EMPLEADO
--usando legajo
--intentamos meter datos nulos
exec recursosHumanos.cambiarCargoEmpleadoPorLegajo null,null
--intentamos meter un cargo que no existe
exec recursosHumanos.cambiarCargoEmpleadoPorLegajo 1,'Mago'

--ahora un caso valido (ejecutar bloque completo)
declare @legajo int
declare @cargoOriCod int
declare @cargoOri varchar(20)
set @legajo=(select top 1 legajo from recursosHumanos.Empleado where cargo<>2)
set @cargoOriCod=(select cargo from recursosHumanos.Empleado where legajo=@legajo)
set @cargoOri=(select cargo from recursosHumanos.cargo where id=@cargoOriCod)
select e.legajo,e.nombre,c.cargo from recursosHumanos.Empleado e inner join recursosHumanos.cargo c on e.cargo=c.id where legajo=@legajo
exec recursosHumanos.cambiarCargoEmpleadoPorLegajo @legajo,'Conserje'
select e.legajo,e.nombre,c.cargo from recursosHumanos.Empleado e inner join recursosHumanos.cargo c on e.cargo=c.id where legajo=@legajo
exec recursosHumanos.cambiarCargoEmpleadoPorLegajo @legajo,@cargoOri
select e.legajo,e.nombre,c.cargo from recursosHumanos.Empleado e inner join recursosHumanos.cargo c on e.cargo=c.id where legajo=@legajo
go


--usando dni
--intentamos meter datos nulos
exec recursosHumanos.cambiarCargoEmpleadoPorDni null,null
--intentamos meter un cargo que no existe
exec recursosHumanos.cambiarCargoEmpleadoPorDni 14068092,'Mago'

--ahora un caso valido (ejecutar bloque completo)
declare @dni int
declare @cargoOriCod int
declare @cargoOri varchar(20)
set @dni = (select top 1 dni from recursosHumanos.Empleado where cargo <> 2)
set @cargoOriCod = (select cargo from recursosHumanos.Empleado where dni = @dni)
set @cargoOri = (select cargo from recursosHumanos.cargo where id = @cargoOriCod)
select e.dni, e.nombre, c.cargo from recursosHumanos.Empleado e inner join recursosHumanos.cargo c on e.cargo = c.id where dni = @dni
exec recursosHumanos.cambiarCargoEmpleadoPorDni @dni, 'Conserje' 
select e.dni, e.nombre, c.cargo from recursosHumanos.Empleado e inner join recursosHumanos.cargo c on e.cargo = c.id where dni = @dni
exec recursosHumanos.cambiarCargoEmpleadoPorDni @dni, @cargoOri
select e.dni, e.nombre, c.cargo from recursosHumanos.Empleado e inner join recursosHumanos.cargo c on e.cargo = c.id where dni = @dni
go

--CAMBIAR SUCURSAL DE UN EMPLEADO
--por legajo
--intentamos ingresar datos nulos
exec recursosHumanos.cambiarSucursalEmpleadoPorLegajo null,null

--intentamos ingresar una sucursal que no existe
exec recursosHumanos.cambiarSucursalEmpleadoPorLegajo 1,9209293

--ahora un caso valido donde cambiamos la sucursal en la que trabaja el empleado y luego lo restauramos (ejecutar bloque completo)
declare @idSucursalNuevo int
declare @idSucursalOri int
declare @legajo int
set @legajo=(select top 1 legajo from recursosHumanos.empleado)
set @idSucursalOri=(select idSucursal from recursosHumanos.empleado where legajo=@legajo)
set @idSucursalNuevo=(select top 1 id from sucursales.sucursal where id<>@idSucursalOri)
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

--intentamos ingresar una sucursal que no existe
exec recursosHumanos.cambiarSucursalEmpleadoPorDni 14068092,29392

--ahora un caso valido (ejecutar bloque completo)
declare @idSucursalNuevo int
declare @idSucursalOri int
declare @dni int
set @dni=(select top 1 dni from recursosHumanos.empleado)
set @idSucursalOri=(select idSucursal from recursosHumanos.empleado where dni=@dni)
set @idSucursalNuevo=(select top 1 id from sucursales.sucursal where id<>@idSucursalOri)
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
set @legajo=(select top 1 legajo from recursosHumanos.empleado where turno<>'TM')
set @turnoViejo=(select turno from recursosHumanos.empleado where legajo=@legajo)
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
set @dni=(select top 1 dni from recursosHumanos.empleado where turno<>'TM')
set @turnoViejo=(select turno from recursosHumanos.empleado where dni=@dni)
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
exec recursosHumanos.darDeAltaEmpleadoPorLegajo 92030929

--Ahora un caso valido (ejecutar bloque completo)
select legajo,nombre,activo from recursosHumanos.empleado where legajo=1
--la damos de baja
exec recursosHumanos.bajaEmpleado 1
select legajo,nombre,activo from recursosHumanos.empleado where legajo=1
--la damos de alta usando el sp
exec recursosHumanos.darDeAltaEmpleadoPorLegajo 1
select legajo,nombre,activo from recursosHumanos.empleado where legajo=1


--con dni
--pasamos un dni nulo
exec recursosHumanos.darDeAltaEmpleadoPorDni null
--ahora uno que no existe
exec recursosHumanos.darDeAltaEmpleadoPorDni 1
--Ahora un caso valido (ejecutar bloque completo)
select legajo,nombre,activo from recursosHumanos.empleado where dni=14068092 --vemos el empleado
exec recursosHumanos.bajaEmpleadoDni 14068092 --la damos de baja
select legajo,nombre,activo from recursosHumanos.empleado where dni=14068092 --vemos que se dio de baja
exec recursosHumanos.darDeAltaEmpleadoPorDni 14068092 --lo damos de alta usando el sp
select legajo,nombre,activo from recursosHumanos.empleado where dni=14068092 --vemos que se dio de alta


---***CARGO***
--Intentamos modificar el nombre de un cargo que no existe y un nombre invalido
exec recursosHumanos.modificarNombreCargo @idCargo = null, @nvoNombre = '   '
--Intentamos modificar el nombre a otro nombre que ya existe
exec recursosHumanos.modificarNombreCargo @idCargo = 1, @nvoNombre = 'Barrendero'
--Modficamos el nombre de un cargo
select * from recursosHumanos.Cargo where id = 1 --vemos el nombre original
exec recursosHumanos.modificarNombreCargo @idCargo = 1, @nvoNombre = 'Manager' --lo modificamos a manager
select * from recursosHumanos.Cargo where id = 1 --vemos que se cambio el nombre
exec recursosHumanos.modificarNombreCargo @idCargo = 1, @nvoNombre = 'Barrendero' --lo restauramos a como estaba antes
select * from recursosHumanos.Cargo where id = 1 --vemos que se restauro

---***LINEAPRODUCTO***
--Intentamos modificar el nombre de una linea que no existe y un nombre invalido
exec catalogo.modificarNombreLineaProducto @idLn = -1, @nvoNombre = null
--Intentamos modificar el nombre a otro nombre que ya existe
exec catalogo.modificarNombreLineaProducto @idLn = 1, @nvoNombre = 'Bazar'
--Modificamos el nombre de una linea
select * from catalogo.LineaProducto where id = 1 --vemos el nombre original
exec catalogo.modificarNombreLineaProducto @idLn = 1, @nvoNombre = 'Mascotas' --cambiamos el nombre
select * from catalogo.LineaProducto where id = 1 --vemos que se cambio
exec catalogo.modificarNombreLineaProducto @idLn = 1, @nvoNombre = 'Bazar' --lo restauramos
select * from catalogo.LineaProducto where id = 1 --vemos que se restauro

---***TIPOCLIENTE***
--Intentamos modificar el nombre de un tipo que no existe y un nombre invalido
exec clientes.modificarNombreTipoCliente @idTipo = -1, @nvoNombre = null
--Intentamos modificar el nombre a otro nombre que ya existe
exec clientes.modificarNombreTipoCliente @idTipo = 1, @nvoNombre = 'Silver'
--Modificamos el nombre (caso valido)
select * from clientes.TipoCliente where id = 1 --vemos el original
exec clientes.modificarNombreTipoCliente @idTipo = 1, @nvoNombre = 'VIP' --lo cambiamos a vip
select * from clientes.TipoCliente where id = 1 --vemos que se cambio
exec clientes.modificarNombreTipoCliente @idTipo = 1, @nvoNombre = 'Bronze' --lo restauramos
select * from clientes.TipoCliente where id = 1 --vemos que se restauro


--***CATEGORIA***
--MODIFICAR NOMBRE
--Intentamos modificar el nombre de una categoria que no existe y un nombre invalido
exec catalogo.modificarNombreCategoria @idCat = -1, @nvoNombre = null
--Intentamos modificar el nombre a otro nombre que ya existe
exec catalogo.modificarNombreCategoria @idCat = 1, @nvoNombre = 'Platos_chinos'
--Modificamos el nombre de una categoria (caso valido)
select * from catalogo.Categoria where id = 1 --vemos el nombre original
exec catalogo.modificarNombreCategoria @idCat = 1, @nvoNombre = 'comida_mascota' --lo cambiamos a comida_mascota
select * from catalogo.Categoria where id = 1 --vemos que se cambio
exec catalogo.modificarNombreCategoria @idCat = 1, @nvoNombre = 'Platos_chinos' --lo restauramos
select * from catalogo.Categoria where id = 1 --vemos que se restauro

--MODIFICAR LINEA DE PRODUCTO
--Intentamos modificar la linea de producto a la que pertenece una categoria inexistente
-- a una linea inexistente
exec catalogo.modificarLineaDeCategoria @idCat = -1 , @idLin = null 
--Modificamos la linea de producto a la que pertenece una categoria (caso valido) (ejecutar transaccion completa)
begin transaction
select * from catalogo.Categoria c 
inner join catalogo.LineaProducto lp 
on c.idLineaProd=lp.id where c.id = 1 --vemos que Platos_chinos pertenece a bazar
exec catalogo.modificarLineaDeCategoria @idCat = 1 , @idLin = 2 --lo cambiamos a automotriz
select * from catalogo.Categoria c 
inner join catalogo.LineaProducto lp 
on c.idLineaProd=lp.id where c.id = 1 --vemos que Platos_chinos ahora pertenece a automotriz
rollback


--***MEDIODEPAGO***
--Intentamos modificar los nombres de un medio de pago inexistente por nombres invalidos
exec comprobantes.modificarNombresMedioPago @idMp = null , @nvoNomIng = null, @nvoNomEsp = '   '
--Intentamos modificar los nombres por otros existentes
exec comprobantes.modificarNombresMedioPago @idMp = 1 , @nvoNomIng = 'Chachos', @nvoNomEsp = 'Chachos'
--Modificamos los nombres de un medio de pago (ejecutar transaccion completa)
begin transaction
select * from comprobantes.MedioDePago where id = 1 --vemos los nombres originales
exec comprobantes.modificarNombresMedioPago @idMp = 1 , @nvoNomIng = 'Transfer', @nvoNomEsp = 'Transferencia' --modificamos
select * from comprobantes.MedioDePago where id = 1 --vemos que se modifico
rollback

--***PRODUCTO***
--MODIFICAR PRECIO
--Intentamos modifcar el precio de un producto inexistente por un precio invalido
exec catalogo.modificarPrecioProducto @idProd = -1, @nvoPrecio = 0
--Modificamos el precio de un producto (ejecutar transaccion completa)
begin transaction
select * from catalogo.Producto where id = 2 --vemos el precio original
exec catalogo.modificarPrecioProducto @idProd = 2, @nvoPrecio = 1000 --modificamos
select * from catalogo.Producto where id = 2 --vemos que se cambio a 1000
rollback

--MODIFICAR PRECIO USD
--Intentamos modifcar el precio de un producto inexistente por un precio invalido
exec catalogo.modificarPrecioUSDProducto @idProd = -1, @nvoPrecio = null
--Modificamos el precio en dolares de un producto (ejecutar transaccion completa)
begin transaction
select * from catalogo.Producto where id = 1 --vemos el precio original
exec catalogo.modificarPrecioUSDProducto @idProd = 1, @nvoPrecio = 50.50 --lo modificamos
select * from catalogo.Producto where id = 1 --vemos el precio en USD modificado
rollback

--MODIFICAR PRECIO REFERENCIA
--Intentamos modifcar el precio de un producto inexistente por un precio invalido
exec catalogo.modificarPrecioReferenciaProducto @idProd = -1, @nvoPrecio = null
--Modificamos el precio de referencia de un producto (ejecutar transacccion completa)
begin transaction
select * from catalogo.Producto where id = 1 --vemos el precio ref antiguo
exec catalogo.modificarPrecioReferenciaProducto @idProd = 1, @nvoPrecio = 40.32 --lo modificamos
select * from catalogo.Producto where id = 1 --vemos el precio ref nuevo
rollback


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
--Modificamos la fecha de un producto (ejecutar transaccion completa)
begin transaction
select * from catalogo.Producto where id = 1 --vemos la fecha que tiene
declare @fecha smalldatetime
set @fecha = getdate()
exec catalogo.modificarFechaProducto @idProd = 1, @fechaYHora = @fecha --le asignamos la fecha actual del sistema
select * from catalogo.Producto where id = 1 --vemos que se aplico
rollback


--MODIFICAR A PRODUCTO ACTIVO
--Intentamos dar de alta un producto que no existe
exec catalogo.darAltaProductoEnBaja null
--Damos de un alta un producto que no esta activo (ejecutar transaccion completa)
begin transaction
exec catalogo.bajaProductoId 1 --damos de baja el producto con id 1
select * from catalogo.Producto where id = 1 --vemos que se dio de baja
exec catalogo.darAltaProductoEnBaja 1 --lo damos de alta 
select * from catalogo.Producto where id = 1 --vemos que se dio de alta
rollback


--AUMENTAR PRECIO DE PRODUCTO CON PORCENTAJE POR CATEGORIA (siempre que tenga precio, si tiene precioUSD solamente lo ignora)
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
	where c.id=2 --vemos los productos pertenecientes a la categoria 2
	--ejecutamos el sp
	exec catalogo.aumentarPrecioProductoPorCategoria 2,100 --aumentamos el precio un 100% (duplicamos)
	--vemos el aumento
	select top 5 p.id,p.nombre,p.precio,c.categoria from catalogo.Producto p
	inner join catalogo.PerteneceA pa
	on p.id=pa.idProd
	inner join catalogo.categoria c
	on c.id=pa.idCategoria
	where c.id=2
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
	where c.id=1
	--ejecutamos el sp
	exec catalogo.aumentarPrecioUSDProductoPorCategoria 1,100 --aumentamos el precio un 100% (duplicamos), 149 es la categoria electronica
	--vemos el aumento
	select top 5 p.id,p.nombre,p.precioUSD,c.categoria from catalogo.Producto p
	inner join catalogo.PerteneceA pa
	on p.id=pa.idProd
	inner join catalogo.categoria c
	on c.id=pa.idCategoria
	where c.id=1
	--deshacemos el update con rollback
rollback

--REDUCIR PRECIO DE PRODUCTO CON PORCENTAJE POR CATEGORIA
--intentamos ingresar un porcentaje y categoria nulos
exec catalogo.reducirPrecioProductoPorCategoria null,null
--ahora una categoria que existe pero porcentaje 0
exec catalogo.reducirPrecioProductoPorCategoria 1,0
--ahora lo mismo pero con un porcentaje mayor o igual a 100
exec catalogo.reducirPrecioProductoPorCategoria 1,100

--ahora un caso valido, para esto ejecutamos la transaccion completa
begin transaction
	select top 5 p.id,p.nombre,p.precio,c.categoria from catalogo.Producto p
	inner join catalogo.PerteneceA pa
	on p.id=pa.idProd
	inner join catalogo.categoria c
	on c.id=pa.idCategoria
	where c.id=2
	--ejecutamos el sp
	exec catalogo.reducirPrecioProductoPorCategoria 2,50 --reducimos el precio a la mitad (50% de descuento)
	--vemos el aumento
	select top 5 p.id,p.nombre,p.precio,c.categoria from catalogo.Producto p
	inner join catalogo.PerteneceA pa
	on p.id=pa.idProd
	inner join catalogo.categoria c
	on c.id=pa.idCategoria
	where c.id=2
	--deshacemos el update con rollback
rollback

--REDUCIR PRECIO USD DE PRODUCTO CON PORCENTAJE POR CATEGORIA
--intentamos ingresar un porcentaje y categoria nulos
exec catalogo.reducirPrecioUSDProductoPorCategoria null,null
--ahora una categoria que existe pero porcentaje 0
exec catalogo.reducirPrecioUSDProductoPorCategoria 1,0
--ahora lo mismo pero con un porcentaje mayor o igual que 100
exec catalogo.reducirPrecioUSDProductoPorCategoria 1,100

--ahora un caso valido, para esto ejecutamos la transaccion completa
begin transaction
	select top 5 p.id,p.nombre,p.precioUSD,c.categoria from catalogo.Producto p
	inner join catalogo.PerteneceA pa
	on p.id=pa.idProd
	inner join catalogo.categoria c
	on c.id=pa.idCategoria
	where c.id=1
	--ejecutamos el sp
	exec catalogo.reducirPrecioUSDProductoPorCategoria 1,50 --reducimos el precio a la mitad (50% de descuento) (149 es el id de la categoria tecnologia)
	--vemos el aumento
	select top 5 p.id,p.nombre,p.precioUSD,c.categoria from catalogo.Producto p
	inner join catalogo.PerteneceA pa
	on p.id=pa.idProd
	inner join catalogo.categoria c
	on c.id=pa.idCategoria
	where c.id=1
	--deshacemos el update con rollback
rollback

--CAMBIAR NOMBRE DE UN PRODUCTO
--intentamos usar datos nulos
exec catalogo.modificarNombreProducto null,null
--ahora un idProd inexistente junto con un nombre de espacios solos
exec catalogo.modificarNombreProducto 1,'    '
--ahora un caso valido (ejecutar transaccion completa)
begin transaction
	select id,nombre,precio,precioUSD from catalogo.producto where id=1 --vemos el nombre original del producto id 1
	exec catalogo.modificarNombreProducto 1,'Smirnoff'
	--vemos el cambio
	select id,nombre,precio,precioUSD from catalogo.producto where id=1
	--deshacemos el cambio
rollback

--CAMBIAR PROVEEDOR DE UN PRODUCTO
--intentamos usar datos nulos
exec catalogo.modificarProveedorProducto null,null
--ahora un idProducto inexistente junto con un proveedor de espacios solos
exec catalogo.modificarProveedorProducto 293202,'        '

--ahora un caso valido
begin transaction
	select id,nombre,precio,precioUSD,proveedor from catalogo.producto where id=1 --vemos el proveedor original
	exec catalogo.modificarProveedorProducto 1,'Kwik-E-Mart'
	--vemos los cambios
	select id,nombre,precio,precioUSD,proveedor from catalogo.producto where id=1
	--deshacemos los cambios
rollback

--CAMBIAR LA CANTIDAD POR UNIDAD DEL PRODUCTO
--Probamos un producto que no existe y una cantidad por unidad vacia
exec catalogo.modificarCantXUnProducto 123456789, '    ' 
--Cambiamos la cantidad por unidad de un producto
begin transaction
	select * from catalogo.Producto where id = 1 --vemos la cant x unidad original
	exec catalogo.modificarCantXUnProducto 1, '1bolsa - 1kg'
	select * from catalogo.Producto where id = 1 --vemos que se efectuaron los cambios
rollback


--**PERTENECEA**
--CAMBIAR CATEGORIA DE PRODUCTO
select * from catalogo.PerteneceA where idProd = 1
--intentamos cambiar la categoria de un producto a uno que no existe
exec catalogo.modificarCategoriaDeProducto @idProd = 1, @idCatAnt = 1, @idCatNvo = 19000
--ahora intentamos con datos nulos
exec catalogo.modificarCategoriaDeProducto null, null, null
--ahora con un producto que no existe
exec catalogo.modificarCategoriaDeProducto @idProd = 190291, @idCatAnt = 1, @idCatNvo = 3

--ahora un caso valido donde cambiamos la categoria del producto (ejecutar transaccion completa)
begin transaction
select p.id, p.nombre, c.categoria,lp.lineaProd 
from catalogo.Producto p 
	inner join catalogo.PerteneceA pa on p.id=pa.idProd 
	inner join catalogo.categoria c on c.id=pa.idCategoria 
	inner join catalogo.LineaProducto lp on lp.id=c.idLineaProd where p.id=1
exec catalogo.modificarCategoriaDeProducto @idProd = 1,@idCatAnt = 1, @idCatNvo = 2 --cambiamos la categoria usando el sp
select p.id, p.nombre, c.categoria,lp.lineaProd 
from catalogo.Producto p 
	inner join catalogo.PerteneceA pa on p.id=pa.idProd 
	inner join catalogo.categoria c on c.id=pa.idCategoria 
	inner join catalogo.LineaProducto lp on lp.id=c.idLineaProd where p.id=1
rollback
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
	set @idCli=(select top 1 id from clientes.cliente where idTipo=1)
	--vemos que el cliente es del tipo 1
	select c.id,c.ciudad,c.genero,tc.id,tc.tipo from clientes.cliente c inner join clientes.TipoCliente tc on c.idTipo=tc.id where c.id=@idCli
	exec clientes.cambiarTipoCliente @idCli,2 --lo cambiamos a tipo 2
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
	exec clientes.cambiarNombreCliente 1,'Adilio'
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
	exec clientes.cambiarApellidoCliente 1,'Oxance'
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
--probamos con un genero que no existe
exec clientes.cambiarGeneroCliente 282382,'Other'
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
	exec clientes.cambiarGeneroCliente @idCli,'Male'
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
	exec clientes.bajaCliente 1 --damos de baja el cliente 1 
	select * from clientes.Cliente where id = 1 --vemos que esta en baja
	exec clientes.darAltaClienteEnBaja 1 --lo damos de alta
	select * from clientes.Cliente where id = 1 --vemos que se puso de alta
rollback

--CAMBIAR DNI DEL CLIENTE
--intentamos con parametros nulos
exec clientes.cambiarDNICliente @idCli = null, @nvoDNI = null
--intentamos con un dni existente
exec clientes.cambiarDNICliente @idCli = 1, @nvoDNI = 22222222
--cambiamos el dni de un cliente
begin transaction
select * from clientes.Cliente where id = 1
exec clientes.cambiarDNICliente @idCli = 1, @nvoDNI = 123
select * from clientes.Cliente where id = 1
rollback


--***FACTURA***
--MODIFICAR EL IDFACTURA
--intentamos con parametros nulos
exec ventas.modificarIdFactura @id = null, @idFactura = null
--intentamos un id que no existe y un idfactura invalido
exec ventas.modificarIdFactura @id = -1, @idFactura = '1-11-111'
--intentamos modificar una factura pagada y un idfactura en uso
exec ventas.modificarIdFactura @id = 1, @idFactura = '111-11-1111'
--modificamos el idfactura de una factura impaga (ejecutar transaccion completa)
begin transaction
	insert into ventas.Factura(idFactura, estado) values('289-23-9999', 'Impaga') --usamos un insert en vez del sp para insertar factura porque para los propositos
	--de esta prueba es mas rapido y directo hacerlo asi. (lo mismo se hace en las siguientes pruebas)
	declare @id int = (select id from ventas.Factura where idFactura = '289-23-9999')
	select * from ventas.Factura where id = @id
	exec ventas.modificarIdFactura @id = @id, @idFactura = '000-00-0000'

	set @id = (select id from ventas.Factura where idFactura = '000-00-0000')
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
	insert into ventas.Factura(idFactura, estado,tipoFactura) values('000-00-0000', 'Impaga','B') --vemos que originalmente es tipo B
	declare @id int = (select id from ventas.Factura where idFactura = '000-00-0000')
	select * from ventas.Factura where id = @id
	exec ventas.modificarTipoFactura @id = @id, @tipoFactura = 'A' --lo cambiamos a tipo A
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
	insert into ventas.Factura(idFactura, estado) values('000-00-0000', 'Impaga') --originalmente no tiene fecha
	declare @id int = (select id from ventas.Factura where idFactura = '000-00-0000')
	select * from ventas.Factura where id = @id
	exec ventas.modificarFechaFactura @id = @id, @fecha = '2020-01-01' --le ponemos una
	select * from ventas.Factura where id = @id
rollback

--MODIFICAR LA HORA DE LA FACTURA
--intentamos com parametros nulos
exec ventas.modificarHoraFactura @id = null, @hora = null
--intentamos con un id que no existe
exec ventas.modificarHoraFactura @id = -1, @hora = '12:03'
--intentamos con una facutura pagada
exec ventas.modificarHoraFactura @id = 1, @hora = '12:03'
--modificamos la hora de una factura
begin transaction
	insert into ventas.Factura(idFactura, estado) values('000-00-0000', 'Impaga') --originalmente no tiene hora
	declare @id int = (select id from ventas.Factura where idFactura = '000-00-0000')
	select * from ventas.Factura where id = @id
	exec ventas.modificarHoraFactura @id = @id, @hora = '12:03' --le ponemos una hora
	select * from ventas.Factura where id = @id
rollback

--MODIFICAR EMPLEADO DE UNA FACTURA
--intentamos con parametros nulos
exec ventas.modificarEmpleadoDeFactura @id = null, @legajoEmp = null
--intentamos con un id que no existe y empleado que no existe
exec ventas.modificarEmpleadoDeFactura @id = -1, @legajoEmp = 9209309
--intentamos con una factura pagada
declare @legajo int = (select top 1 legajo from recursosHumanos.Empleado)
exec ventas.modificarEmpleadoDeFactura @id = 1, @legajoEmp = @legajo
--modificamos el empleado que genera la factura
begin transaction
	insert into ventas.Factura(idFactura, estado) values('000-00-0000', 'Impaga') --originalmente no tiene empleado asociado
	declare @id int = (select id from ventas.Factura where idFactura = '000-00-0000')
	insert into recursosHumanos.Empleado(legajo) values(123) --creamos un empleado falso con legajo 123 para esta prueba
	declare @legajo int = 123
	select * from ventas.Factura where id = @id
	exec ventas.modificarEmpleadoDeFactura @id = @id, @legajoEmp = @legajo --lo asociamos a la factura que originalmente tenia empleado null
	select * from ventas.Factura where id = @id
rollback

--MODIFICAR CLIENTE FACTURA
--intentamos con parametros nulos
exec ventas.modificarClienteDeFactura @id = null, @idCliente = null
--intentamos con un id que no existe y cliente que no existe
exec ventas.modificarClienteDeFactura @id = -1, @idCliente = -1
--intentamos con una factura pagada
exec ventas.modificarClienteDeFactura @id = 1, @idCliente = 1
--modificamos el cliente que genera la factura
begin transaction
	insert into ventas.Factura(idFactura, estado) values('000-00-0000', 'Impaga')
	declare @id int = (select id from ventas.Factura where idFactura = '000-00-0000')
	insert into clientes.Cliente(nombre, apellido) values('Homero', 'Simpson') --insertamos un cliente para asociar a la factura
	declare @idCliente int = (select id from clientes.cliente where nombre='Homero' and apellido='Simpson')
	select * from ventas.Factura where id = @id
	exec ventas.modificarClienteDeFactura @id = @id, @idCliente = @idCliente --asociamos la factura a Homero Simpson
	select f.id,f.idFactura,f.estado,c.nombre,c.apellido from ventas.Factura f inner join clientes.cliente c on f.idCliente=c.id where f.id = @id
rollback

---***LINEA DE FACTURA***
--MODIFICAR PRODUCTO DE LINEA DE FACTURA
-- intentamos con parametros nulos
exec ventas.modificarProductoLineaDeFactura @idLn = null, @idFactura = null, @idProd = null
--intentamos con una linea, factura y producto inexistentes
exec ventas.modificarProductoLineaDeFactura @idLn = -1, @idFactura = -1, @idProd = -1
--intentamos con una factura pagada y una linea que no pertenece a esa factura
exec ventas.modificarProductoLineaDeFactura @idLn = 4, @idFactura = 1, @idProd = 1
select * from ventas.LineaDeFactura
--intentamos con un producto inexistente
begin transaction
	insert into ventas.Factura(idFactura) values('000-00-0000')
	declare @idFactura int = (select id from ventas.Factura where idFactura = '000-00-0000')
	insert into ventas.LineaDeFactura(idFactura)
		values(@idFactura)
	declare @idLn int = (select top 1 id from ventas.LineaDeFactura where idFactura = @idFactura)
	exec ventas.modificarProductoLineaDeFactura @idLn = @idLn, @idFactura = @idFactura, @idProd = -1
rollback
--intentamos modificar el producto de una linea a un producto que tiene otra linea de la misma factura
begin transaction
	insert into ventas.Factura(idFactura) values('000-00-0000')
	declare @idFactura int = (select id from ventas.Factura where idFactura = '000-00-0000')
	insert into ventas.LineaDeFactura(idFactura, idProd)
		values(@idFactura, 1)
	insert into ventas.LineaDeFactura(idFactura, idProd)
		values(@idFactura, 2)
	declare @idLn int = (select top 1 id from ventas.LineaDeFactura where idFactura = @idFactura)
	exec ventas.modificarProductoLineaDeFactura @idLn = @idLn, @idFactura = @idFactura, @idProd = 2
rollback
--modificamos el producto de una linea de una factura
begin transaction
	insert into ventas.Factura(idFactura) values('000-00-0000')
	declare @idFactura int = (select id from ventas.Factura where idFactura = '000-00-0000')
	insert into ventas.LineaDeFactura(idFactura, idProd, cantidad, precioUn,subtotal)
		values(@idFactura, 1, 3, 2,6) --le insertamos esta linea con idprod 1
	declare @idLn int = (select top 1 id from ventas.LineaDeFactura where idFactura = @idFactura)
	select * from ventas.LineaDeFactura where id = @idLn
	exec ventas.modificarProductoLineaDeFactura @idLn = @idLn, @idFactura = @idFactura, @idProd = 2 --lo modificamos para que esa linea sea de idprod 2 (se recalcula el subtotal)
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
	insert into ventas.Factura(idFactura) values ('000-00-0000'), ('666-66-6666')
	insert into ventas.LineaDeFactura(idFactura, idProd)
		select id, 1 from ventas.Factura where idFactura in ('000-00-0000', '666-66-6666')
	declare @idFactura1 int = (select id from ventas.Factura where idFactura = '000-00-0000')
	declare @idLn int = (select id from ventas.LineaDeFactura where idFactura = @idFactura1 )
	declare @idFactura2 int = (select id from ventas.Factura where idFactura = '666-66-6666')
	exec ventas.modificarIdFacturaLineaDeFactura @idLn = @idLn, @idFactura = @idFactura2
rollback
--modificamos el idFactura de una linea
begin transaction
	insert into ventas.Factura(idFactura) values ('000-00-0000'), ('666-66-6666')
	insert into ventas.LineaDeFactura(idFactura, idProd)
		select id, 1 from ventas.Factura where idFactura in ('000-00-0000')
	insert into ventas.LineaDeFactura(idFactura, idProd)
		select id, 2 from ventas.Factura where idFactura in ('666-66-6666')
	
	declare @idFactura1 int = (select id from ventas.Factura where idFactura = '000-00-0000')
	declare @idLn int = (select id from ventas.LineaDeFactura where idFactura = @idFactura1 )
	declare @idFactura2 int = (select id from ventas.Factura where idFactura = '666-66-6666')

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
	insert into ventas.Factura(idFactura) values ('000-00-0000')
	declare @idFactura int = (select id from ventas.Factura where idFactura = '000-00-0000')
	insert into ventas.LineaDeFactura(idFactura, idProd, precioUn, cantidad, subtotal) 
		values (@idFactura, 1, 2.0, 2, 4)
	declare @idLn int = (select id from ventas.LineaDeFactura where idFactura = @idFactura )
	select * from ventas.LineaDeFactura where id = @idLn
	exec ventas.modificarCantidadLineaDeFactura @idLn = @idLn, @cantidad = 3
	select * from ventas.LineaDeFactura where id = @idLn
rollback

---***COMPROBANTE***
--MODIFICAR IDPAGO COMPROBANTE
--intentamos con parametros nulos
exec comprobantes.cambiarIdPagoComprobante @id = null, @nvoIdPago = null
--intentamos con un id que no existe y un idpago vacio
exec comprobantes.cambiarIdPagoComprobante @id = -1, @nvoIdPago = '                 '
--intentamos modificar el id de pago de una nota de credito
begin transaction
	insert into comprobantes.Comprobante(tipoComprobante) values('Nota de Credito')
	declare @idComp int = (select top 1 id from comprobantes.Comprobante order by id desc)
	exec comprobantes.cambiarIdPagoComprobante @id = @idComp, @nvoIdPago = '123'
rollback
--intentamos modificar a un id de pago asociado a otro comprobante de pago
begin transaction
	insert into comprobantes.Comprobante(tipoComprobante, idPago) values('Factura', '456')
	insert into comprobantes.Comprobante(tipoComprobante, idPago) values('Factura', '123')
	declare @idComp int = (select id from comprobantes.Comprobante where idPago = '456')
	exec comprobantes.cambiarIdPagoComprobante @id = @idComp, @nvoIdPago = '123'
rollback
--modificamos el id de pago
begin transaction
	insert into comprobantes.Comprobante(tipoComprobante, idPago) values('Factura', '456')
	declare @idComp int = (select top 1 id from comprobantes.Comprobante order by id desc)
	select * from comprobantes.Comprobante where id = @idComp
	exec comprobantes.cambiarIdPagoComprobante @id = @idComp, @nvoIdPago = '123'
	select * from comprobantes.Comprobante where id = @idComp
rollback

--MODIFICAR MEDIO DE PAGO DE UN COMPROBANTE
--intentamos con parametros nulos
exec comprobantes.modificarMedioPagoDeComprobante @id = null, @idMedPago = null
--intentamos con un id que no existe y un medio de pago que no existe
exec comprobantes.modificarMedioPagoDeComprobante @id = -1, @idMedPago = -1 
--intentamos modificar el id de pago de una nota de credito
begin transaction
	insert into comprobantes.Comprobante(tipoComprobante) values('Nota de Credito')
	insert into comprobantes.MedioDePago(nombreEsp) values('Transferencia')
	declare @idComp int = (select top 1 id from comprobantes.Comprobante order by id desc)
	declare @idMedPago int = (select id from comprobantes.MedioDePago where nombreEsp = 'Transferencia')
	exec comprobantes.modificarMedioPagoDeComprobante @id = @idComp, @idMedPago = @idMedPago
rollback
--modificamos el medio de pago
begin transaction
	insert into comprobantes.Comprobante(tipoComprobante) values('Factura')
	insert into comprobantes.MedioDePago(nombreEsp) values('Transferencia')
	declare @idComp int = (select top 1 id from comprobantes.Comprobante order by id desc)
	declare @idMedPago int = (select id from comprobantes.MedioDePago where nombreEsp = 'Transferencia')
	select * from comprobantes.Comprobante where id = @idComp
	exec comprobantes.modificarMedioPagoDeComprobante @id = @idComp, @idMedPago = @idMedPago
	select * from comprobantes.Comprobante where id = @idComp
rollback

--MODIFICAR LA FACTURA DE UN COMPROBANTE
--intentamos con parametros nulos
exec comprobantes.modificarFacturaDeComprobante @id = null, @nvoIdFactura = null
--intentamos con un id que no existe y una factura que no existe
exec comprobantes.modificarFacturaDeComprobante @id = -1, @nvoIdFactura = -1
--intentamos modificar la factura de un comprobante de pago a otra factura que ya tiene un comprobante de pago
begin transaction
	insert into comprobantes.Comprobante(tipoComprobante) values('Factura')
	insert into ventas.Factura(idFactura, estado) values('000-00-0000', 'Pagada')
	declare @idComp int = (select top 1 id from comprobantes.Comprobante order by id desc)
	declare @idFactura int = (select id from ventas.Factura where idFactura = '000-00-0000')
	exec comprobantes.modificarFacturaDeComprobante @id = @idComp, @nvoIdFactura = @idFactura
rollback
--modificamos la factura de un comprobante
begin transaction
	insert into comprobantes.Comprobante(tipoComprobante) values('Factura')
	insert into ventas.Factura(idFactura) values('000-00-0000')
	declare @idComp int = (select top 1 id from comprobantes.Comprobante order by id desc)
	declare @idFactura int = (select id from ventas.Factura where idFactura = '000-00-0000')
	select * from comprobantes.Comprobante where id = @idComp
	exec comprobantes.modificarFacturaDeComprobante @id = @idComp, @nvoIdFactura = @idFactura
	select * from comprobantes.Comprobante where id = @idComp
rollback

--MODIFICAR FECHA COMPROBANTE
--intentamos con parametros nulos
exec ventas.modificarFechaComprobante @id = null, @fecha = null
--intentamos con un id que no existe
exec ventas.modificarFechaComprobante @id = -1, @fecha = '2020-01-01'
--modificamos la fecha de un comprobante
begin transaction
	insert into comprobantes.Comprobante(idPago) values('123')
	declare @id int = (select top 1 id from comprobantes.Comprobante order by id desc)
	select * from comprobantes.Comprobante where id = @id
	exec ventas.modificarFechaComprobante @id = @id, @fecha = '2020-01-01'
	select * from comprobantes.Comprobante where id = @id
rollback

--MODIFICAR LA HORA COMPROBANTE
--intentamos com parametros nulos
exec ventas.modificarHoraComprobante @id = null, @hora = null
--intentamos con un id que no existe
exec ventas.modificarHoraComprobante @id = -1, @hora = '12:03'
--modificamos la hora de un comprobante
begin transaction
	insert into comprobantes.Comprobante(idPago) values('123')
	declare @id int = (select top 1 id from comprobantes.Comprobante order by id desc)
	select * from comprobantes.Comprobante where id = @id
	exec ventas.modificarHoraComprobante @id = @id, @hora = '12:03'
	select * from comprobantes.Comprobante where id = @id
rollback

--***SUPERMERCADO***
--MODIFICAR RAZON SOCIAL 
--intentamos con una razon social null
exec supermercado.cambiarRazonSocial NULL
--intentamos con una razon social vacia
exec supermercado.cambiarRazonSocial '    '
--ahora un caso valido (ejecutar transaccion completa)
begin transaction
select * from supermercado.Supermercado --vemos el nombre actual
exec supermercado.cambiarRazonSocial 'Aurora RLD' --lo actualizamos
select * from supermercado.Supermercado --vemos el nombre nuevo
rollback

--MODIFICAR CUIT
--intentamos con un cuit null (se mantendra el cuit generico 20-22222222-3)
exec supermercado.cambiarCuit NULL
--intentamos con uno vacio (se mantendra el cuit generico 20-22222222-3)
exec supermercado.cambiarCuit '       '
--intentamos un formato incorrecto de cuit
exec supermercado.cambiarCuit '20-32'
--intentamos con un caso valido con cuit no generico (ejecutar transaccion completa)
begin transaction
select * from supermercado.Supermercado --vemos el cuit actual
exec supermercado.cambiarCuit '30-12345678-1'--lo cambiamos
select * from supermercado.Supermercado --vemos el cuit nuevo
rollback

--MODIFICAR INGRESOS BRUTOS
--intentamos con un numero no valido
exec supermercado.cambiarNroIngresosBrutos '2903'
--un caso valido
begin transaction
select * from supermercado.Supermercado --vemos el numero actual (nota que null es valido)
exec supermercado.cambiarNroIngresosBrutos '12345678910' -- lo actualizamos
select * from supermercado.Supermercado --vemos el numero nuevo
rollback

--MODIFICAR CONDICION FRENTE AL IVA
--intentamos con un valor nulo
exec supermercado.cambiarCondIva null
--ahora con un valor vacio
exec supermercado.cambiarCondIva '      '
--ahora con un caso valido
begin transaction
select * from supermercado.Supermercado --vemos la condicion actual
exec supermercado.cambiarCondIva 'Exento' --lo actualizamos
select * from supermercado.Supermercado --vemos que se actualizo
rollback


--MODIFICAR FECHA DE INICIO DE ACTIVIDADES
--ejecutar transaccion completa
begin transaction
declare @fecha date = getdate()
select * from supermercado.Supermercado --vemos la fecha actual
exec supermercado.cambiarFechaInicioAct @fecha --actualizamos la fecha
select * from supermercado.Supermercado --vemos los cambios
rollback

--BORRAR LOS DATOS DE PRUEBA (opcional)
--Nota: solo ejecutar una unica vez y una vez que ya se probaron los demas sp de delete e insert ya que una vez que se borran no se pueden volver a cargar.
--Ademas, no se debe ejecutar si ya se cargaron los archivos ya que se borraran todas las tablas.
exec testing.borrarDatosDePrueba

