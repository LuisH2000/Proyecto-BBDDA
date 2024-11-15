use [Com5600G13]
go

--***SUPERMERCADO***
--probamos con parametros nulos
exec supermercado.insertarSupermercado @razonSocial = null, @cuit = null, @ingBrutos = null, @condIVA = null, @fInicioAct = null
--probamos con un cuit y ingreso bruto invalidos
exec supermercado.insertarSupermercado @razonSocial = null, @cuit = '123', @ingBrutos = '23', @condIVA = null, @fInicioAct = null
--insertamos los datos del supermercado (como cuit esta null se usara un cuit generico)
exec supermercado.insertarSupermercado 
	@razonSocial = 'Aurora S.A.',
	@cuit = null,
	@ingBrutos = null,
	@condIVA = 'Responsable Inscripto',
	@fInicioAct = null
--CARGA INICIAL DE DATOS (ejecutar el SP, solo hace falta hacerlo una vez, si ya lo ejecuto previamente en otro script ignore este paso)
exec testing.crearDatosDePrueba

--***SUCURSAL***
-- Probamos insertar valores nulos o vacios, nos deberia aparecer mensajes de errores
exec sucursales.insertarSucursal null, null, null, null
exec sucursales.insertarSucursal ' ', '', '       ', ' '

--Probamos un telefono invalido
exec sucursales.insertarSucursal 'La Matanza', 'AV. Don Bosco', 'L a V: 8 - 20, S y D: 10 - 20', '151111-1111'

-- Probamos insertar una direccion y ciudad en donde ya existe una sucursal
exec sucursales.insertarSucursal 'Lomas de Zamora', 'Torquinst 829, B1765 Lomas, prov bs as, arg', 'L a V: 8 - 20, S y D: 10 - 20', '1111-1111'
-- Probamos una direccion que existe pero en otra ciudad (caso valido)
exec sucursales.insertarSucursal 'La Matanza', 'Torquinst 829, B1765 Lomas, prov bs as, arg', 'L a V: 8 - 20, S y D: 10 - 20', '1111-1211'
--Vemos que se haya insertado
select * from sucursales.Sucursal
--Borramos la sucursal insertada
delete from sucursales.Sucursal
where ciudad='La Matanza'
and direccion='Torquinst 829, B1765 Lomas, prov bs as, arg'
--Nota: no usamos el sp correspondiente para borrar porque el sp realiza un borrado logico, solo cambia el valor del campo 'activo' a 0. (hay mas
--casos donde hacemos esto mismo en el transcurso de este script)

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
exec recursosHumanos.insertarEmpleadoSucursalPorCiudadDireccion 257020, 'Pollito', 'Perez', 36383025, 'Av. Vergara 1910 , Hurlingham , Buenos Aires','pollitoPerez@gmail.com','pollitoPerez@gmail.com', 20349,'Mago', 'Turno madrugada', 'La matanza','Avenida siempre viva 239' 

--Ahora intentemos con un registro valido
exec recursosHumanos.insertarEmpleadoSucursalPorCiudadDireccion 300000, 'Arnaldo', 'Krauss', 41714474, 'Av. Vergara 1910 , Hurlingham , Buenos Aires','arnaldoKrauss@gmail.com','arnaldoKRAUSS@superA.com','21-41714470-1','Rey de la limpieza', 'TM', 'Lomas de Zamora','Torquinst 829, B1765 Lomas, prov bs as, arg'
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
exec recursosHumanos.insertarEmpleadoSucursalPorId 257020, 'Pollito', 'Perez', 36383025, 'Av. Vergara 1910 , Hurlingham , Buenos Aires','pollitoPerez@gmail.com','pollitoPerez@gmail.com', 20349,'Mago', 'Turno madrugada', 900

--Ingresamos un registro valido
exec recursosHumanos.insertarEmpleadoSucursalPorId 300000, 'Arnaldo', 'Krauss', 41714474, 'Av. Vergara 1910 , Hurlingham , Buenos Aires','arnaldoKrauss@gmail.com','arnaldoKRAUSS@superA.com','21-41714470-1','Rey de la limpieza', 'TM', 1
--Comprobamos que efectivamente se pudo ingresar
select * from recursosHumanos.empleado
where legajo=300000 

--borramos el registro
delete from recursosHumanos.Empleado
where legajo=300000

---***CARGO***
select * from recursosHumanos.cargo
--SP Para ingresar un cargo nuevo
--Valida que el cargo no exista, intentemos ingresar uno que ya existe, por ejemplo, barrendero
exec recursosHumanos.insertarCargo 'barrendero'
--Ahora intentemos ingresar un cargo nuevo, ejemplo, limpiapisos
exec recursosHumanos.insertarCargo 'Limpiapisos'

--vemos que se cargo
select * from recursosHumanos.cargo
order by id

--borramos el registro
delete from recursosHumanos.Cargo
where cargo='limpiapisos'

---***CATEGORIA***
--SP para insertar una nueva linea de Producto junto con su categoria (tal como venian en el archivo, de a pares)
--Si la linea de producto no existe la crea, si ya existe asocia la categoria a ese LP existente, si la categoria ya existe tira error
--y avisa que la categoria ya esta registrada y asociada a un LP existente (y te muestra a cual)
select * from catalogo.Categoria
--Intentemos ingresar una combinacion de linea de producto / categoria que ya existe
exec catalogo.insertarLineaProductoYCategoria 'Bazar', 'Platos_chinos'

--Intentamos ingresar una categoria que ya existe con una linea de productos que no existe
exec catalogo.insertarLineaProductoYCategoria 'Ocultos', 'Platos_chinos'

--Intentamos ingresar combinaciones vacias
exec catalogo.insertarLineaProductoYCategoria ' ', NULL

--Ingresamos una categoria nueva con una linea de productos existente
exec catalogo.insertarLineaProductoYCategoria 'Bazar', 'Rascadores' --Nota: si la categoria es del tipo 'rascadores de espalda', el sp lo formatea a 'rascadores_de_espalda'
--Vemos que este se asocia correctamente con la linea de productos
select * from catalogo.Categoria c
inner join catalogo.LineaProducto lp
on c.idLineaProd=lp.id
where c.categoria='rascadores'

--borramos el registro
delete from catalogo.Categoria
where categoria='rascadores'

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

---***LINEA DE PRODUCTO***
--SP para insertar una linea de producto (sola, sin categoria)
--Intentamos insertar una linea de producto nula
exec catalogo.insertarLineaProducto ' '
--o
exec catalogo.insertarLineaProducto NULL

--Intentamos ingresar una linea de producto existente
exec catalogo.insertarLineaProducto 'Bazar'

--Ingresamos una linea de producto totalmente nueva (caso valido)
exec catalogo.insertarLineaProducto 'Fantasia'

--vemos que se ingreso
select * from catalogo.LineaProducto
where lineaProd='Fantasia'

--borramos el registro
delete from catalogo.LineaProducto
where lineaProd='Fantasia'

---***PRODUCTO***
--SP Para insertar un producto
--intentamos ingresar un producto sin precios
exec catalogo.insertarProducto 1,'Kiwi',NULL,NULL,1.29,kg,NULL,NULL,'Platos_chinos'

--intentamos ingresar un producto que ya existe
exec catalogo.insertarProducto 2,'Plato funshwei',NULL,30,NULL,NULL,'Moonton',NULL,'Platos_chinos'

--intentemos ingresar un producto con precios negativos
exec catalogo.insertarProducto 920392,'Bujias hescher',-0.26,NULL,-1.29,bujias,NULL,NULL,'Bujias'

--intentemos ingresar un producto sin aclarar la categoria
exec catalogo.insertarProducto 920392,'Bujias hescher',0.26,NULL,1.29,bujias,NULL,NULL,''

--Ahora ingresar uno donde la categoria no exista
exec catalogo.insertarProducto 920392,'Polvo de hada',0.26,NULL,1.29,bujias,NULL,NULL,'Ocultos'

--Ahora ingresamos dos registros validos (uno con precio en pesos y el otro en usd)
exec catalogo.insertarProducto NULL,'Plato Xiping',3000,NULL,NULL,NULL,NULL,NULL,'Platos_chinos'
exec catalogo.insertarProducto NULL,'Bujia Malcom',NULL,3,NULL,NULL,NULL,NULL,'Bujias'
--verificamos que se cargo correctamente en ambas tablas
select p.id, p.nombre, p.precio,p.precioUSD,p.fecha, p.activo, c.categoria, lp.lineaProd 
from catalogo.Producto p
inner join catalogo.perteneceA pa
on p.id=pa.idProd
inner join catalogo.Categoria c
on c.id=pa.idCategoria
inner join catalogo.LineaProducto lp
on lp.id=c.idLineaProd
where p.nombre='Plato Xiping'
or p.nombre='Bujia Malcom'
--borramos los registros
delete from catalogo.PerteneceA
where idProd in (select id from catalogo.Producto where nombre='Plato xiping' or nombre='Bujia malcom')

delete from catalogo.producto
where nombre='Plato xiping' or nombre='Bujia malcom'

---***TIPO DE CLIENTE***
--SP para insertar un tipo de cliente nuevo
--intentamos insertar un null
exec clientes.insertarTipoCliente null
--Ahora uno vacio
exec clientes.insertarTipoCliente '    '
--Ahora con uno que ya existe
exec clientes.insertarTipoCliente 'Gold'
--Ahora uno valido
exec clientes.insertarTipoCliente 'Pro'
--vemos que se inserto
select * from clientes.TipoCliente
--borramos el registro
delete from clientes.TipoCliente
where tipo='Pro'

---***MEDIO DE PAGO***
--SP Para insertar un nuevo medio de pago
--intentamos ingresar un medio de pago existente
exec comprobantes.insertarMedioDePago 'bitcoin', 'bitcoin'
--intentamos ingresar un medio de pago nulo
exec comprobantes.insertarMedioDePago null, null
--ahora uno vacio
exec comprobantes.insertarMedioDePago '   ', '    '

--ahora uno valido
exec comprobantes.insertarMedioDePago 'Debit card', 'Tarjeta de debito'

--vemos que se inserto
select * from comprobantes.MedioDePago

--borramos el registro
delete from comprobantes.MedioDePago
where nombreEsp='Tarjeta de debito'

---***FACTURA***
--SP para insertar una factura (venta) 
--intentamos pasar solo parametros null
declare @tablaProds tablaProductosIdCant
insert into @tablaProds
values(1,2),(2,2)
exec ventas.insertarFactura @idFactura = null,@tipoFactura = null,@empleadoLeg = null, @idCliente = null, @prodsId = @tablaProds
--intentamos insertar una factura que ya existe, junto con un tipo de factura inexistente, empleado inexsistente, cliente inexistente
declare @tablaProds tablaProductosIdCant
insert into @tablaProds
values(1,2),(2,2)
exec ventas.insertarFactura @idFactura = '111-11-1111',@tipoFactura = 'K',@empleadoLeg = 28, @idCliente = 456, @prodsId = @tablaProds
--intentamos insertar productos que no existen
declare @tablaProds tablaProductosIdCant
insert into @tablaProds
values(-1,2),(2,2)
exec ventas.insertarFactura @idFactura = '980-23-2932',@tipoFactura = 'A',@empleadoLeg = 1, @idCliente = 1, @prodsId = @tablaProds

--Probamos insertar una factura valida
declare @tablaProds tablaProductosIdCant
insert into @tablaProds
values(1,2),(2,2)
exec ventas.insertarFactura @idFactura = '888-88-8888',@tipoFactura = 'A',@empleadoLeg = 1, @idCliente = 1, @prodsId = @tablaProds
--vemos que efectivamente se inserto
select * from ventas.factura
where idFactura='888-88-8888'
--vemos las lineas de factura
select lf.id,lf.idFactura,lf.idProd,p.nombre,p.precio,p.precioUSD,lf.cantidad,lf.subtotal from ventas.LineaDeFactura lf
inner join ventas.factura f
on lf.idFactura=f.id
inner join catalogo.producto p
on p.id=lf.idProd
where f.idFactura='888-88-8888'
--nota: el precio del plato funshwei se calculo usando una api de conversion de moneda. (se convierte en el momento de usd a pesos)

--borramos las facturas
delete ventas.LineaDeFactura 
	where idFactura in (select id from ventas.Factura 
						where idFactura='888-88-8888')
delete ventas.Factura where idFactura='888-88-8888'

---***COMPROBANTE***
--intentamos crear un comprobante con un id vacio, medio de pago invalido y factura vacia
exec comprobantes.insertarComprobante '', 5, ''
exec comprobantes.insertarComprobante null, null, null
--intentamos crear un comprobante para una factura pagada
exec comprobantes.insertarComprobante '123', 1, '111-11-1111'
--intentamos crear un comprobante con un id de pago existente
exec comprobantes.insertarComprobante '2323-2323-2323-2323', 1, '111-11-1111'
--insertamos un comprobante valido
declare @tablaProds tablaProductosIdCant
insert into @tablaProds
values(1,3)
exec ventas.insertarFactura @idFactura = '777-77-7777',@tipoFactura = 'A',@empleadoLeg = 1, @idCliente = 1, @prodsId = @tablaProds
exec comprobantes.insertarComprobante '123', 1, '777-77-7777'
--insertamos un comprobante valido, cuando el pago es en efectivo el idPago pasa a ser --
declare @tablaProds tablaProductosIdCant
insert into @tablaProds
values(1,1)
exec ventas.insertarFactura @idFactura = '555-55-5555',@tipoFactura = 'A',@empleadoLeg = 1, @idCliente = 1, @prodsId = @tablaProds
exec comprobantes.insertarComprobante '456', 3, '555-55-5555'
--vemos el comprobante y el estado de la factura
select *
from comprobantes.Comprobante c
join ventas.Factura f on f.id = c.idFactura
where (idPago = '123' and f.idFactura = '777-77-7777') or
(idPago='--' and f.idFactura='555-55-5555')
--borramos el comprobante y las facturas
delete comprobantes.Comprobante 
where idFactura=(select id from ventas.factura where idFactura='777-77-7777')
or idFactura=(select id from ventas.Factura where idFactura='555-55-5555')
delete ventas.LineaDeFactura 
	where idFactura in (select id from ventas.Factura 
						where idFactura in ('777-77-7777', '555-55-5555' ))
delete ventas.Factura where idFactura in ('777-77-7777', '555-55-5555')

---***PerteneceA***
--intentamos insertar datos nulos
exec catalogo.agregarProductoACategoria null, null
--intentamos agregar un producto a una categoria inexistente
exec catalogo.agregarProductoACategoria 1, 1000
--agregamos un producto a una categoria
exec catalogo.agregarProductoACategoria 1, 2 --(agregamos el plato funshwei a la categoria bujias para esta prueba)
select * from catalogo.PerteneceA p 
	join catalogo.Categoria c on c.id = p.idCategoria
	inner join catalogo.producto pr
	on pr.id=p.idProd
where p.idProd = 1
--borramos el registro
delete from catalogo.PerteneceA where idProd = 1 and idCategoria = 2

---***LINEA DE PRODUCTO***
--Probamos insertar una linea con una factura, producto y cantidad invalidas
exec ventas.insertarLineaDeFactura @idFactura = -1, @idProd = -1, @cantidad = 0
--Insertarmos un producto que ya se encuentra en una linea de una factura
--Volver a ejecutar el select para verificar que la cantidad y el subtotal se haya actualizado (este producto tiene precio en dolares)
declare @tablaProds tablaProductosIdCant
insert into @tablaProds
values(1,1)
exec ventas.insertarFactura @idFactura = '999-99-9999',@tipoFactura = 'A',@empleadoLeg = 1, @idCliente = 1, @prodsId = @tablaProds
--vemos la factura y sus lineas asociadas (ejecutar bloque completo)
--inicio bloque
declare @idFactura int = (select id from ventas.Factura where idFactura = '999-99-9999')
select id,idFactura,idProd,precioUn,cantidad as cantidad_vieja, subtotal as subtotal_vieja from ventas.LineaDeFactura where idFactura = @idFactura
exec ventas.insertarLineaDeFactura @idFactura = @idFactura, @idProd = 1, @cantidad = 2 --agregamos una linea mas donde se compra 2 unidades mas del mismo producto
select id,idFactura,idProd,precioUn,cantidad as cantidad_nueva, subtotal as subtotal_nueva 
from ventas.LineaDeFactura where idFactura = @idFactura --comprobamos como se actualizo la linea
go
--fin bloque
--Insertamos un producto con precio en pesos (ejecutar bloque completo)
--inicio bloque
declare @idFactura int = (select id from ventas.Factura where idFactura = '999-99-9999')
select * from ventas.LineaDeFactura where idFactura = @idFactura --vemos la factura antes de la insercion
exec ventas.insertarLineaDeFactura @idFactura = @idFactura, @idProd = 2, @cantidad = 2
select * from ventas.LineaDeFactura where idFactura = @idFactura --luego de la insercion de productos nuevos
--fin bloque

--borramos los datos insertados
declare @idFactura int = (select id from ventas.Factura where idFactura = '999-99-9999')
delete from ventas.LineaDeFactura where idFactura = @idFactura
delete from ventas.Factura where id = @idFactura

--CLIENTE
--insertar un cliente nuevo
--intentamos insertar un cliente con todos los datos nulos
exec clientes.insertarNuevoCliente null,null,null,null,null,null
--ahora intentamos ingresar un cliente con un tipo que no existe
exec clientes.insertarNuevoCliente 90,123,'Pollito','Perez','Varela','Male'
--intentamos con un dni que ya tiene otro cliente
exec clientes.insertarNuevoCliente 1,11111111,'Pollito','Perez','Varela','Male'
--ahora intentamos con un caso valido (ejecutar transaccion completa)
begin transaction
exec clientes.insertarNuevoCliente 2,123, 'Braulio','Hernandez','Varela','Male'
--vemos que se inserto
select * from clientes.cliente
where nombre='Braulio'
rollback


