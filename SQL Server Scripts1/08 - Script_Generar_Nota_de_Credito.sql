/*
Fecha de Entrega: 15/11/2024
Comision: 5600
Grupo 13
Bases de Datos Aplicadas

Alumnos:
	- Diaz, Nicolas 41714473
	- Huang, Luis 43098142

**ENUNCIADO**
Cuando un cliente reclama la devolución de un producto se genera una nota de crédito por el 
valor del producto o un producto del mismo tipo. 
En el caso de que el cliente solicite la nota de crédito, solo los Supervisores tienen el permiso 
para generarla.  
Tener en cuenta que la nota de crédito debe estar asociada a una Factura con estado pagada. 
Asigne los roles correspondientes para poder cumplir con este requisito. 
Por otra parte, se requiere que los datos de los empleados se encuentren encriptados, dado 
que los mismos contienen información personal. 
La información de las ventas es de vital importancia para el negocio, por ello se requiere que 
se establezcan políticas de respaldo tanto en las ventas diarias generadas como en los 
reportes generados.  
Plantee una política de respaldo adecuada para cumplir con este requisito y justifique la 
misma. 
*/

/*
Cuando un cliente reclama la devolución de un producto se genera una nota de crédito por el 
valor del producto o un producto del mismo tipo. 
Tener en cuenta que la nota de crédito debe estar asociada a una Factura con estado pagada. 
*/

use Com5600G13
go

--Tipo de dato necesario para este SP (Fue creado durante el script de insercion, pero por las dudas se pone aca denuevo).
if not exists (select * from sys.types where name = 'tablaProductosIdCant' and is_user_defined = 1)
begin
	CREATE TYPE tablaProductosIdCant AS TABLE (
		idProd int,
		cantidad decimal(5,2)
	);
end
go

create or alter proc comprobantes.generarNotaDeCredito
	@factura char(11),
	@tablaProductos tablaProductosIdCant READONLY
as
begin
	declare @error varchar(max) = ''
	declare @idFactura int
	declare @precio decimal(15,2)
	declare @idNC int
	declare @cantProdDevHist int=0
	declare @tablaProdPrecio table
	(idProd int,
	cantidad decimal(5,2),
	precio decimal(15,2),
	cantidadHist decimal(5,2)
	)
	set @factura = ltrim(rtrim(@factura))
	--verificamos que la factura no este vacia
	--si no esta vacia, verificamos que exista y que este pagada
	if @factura is null or @factura = ''
		set @error = @error + 'No se ingreso la factura' + char(13)+ char(10)
	else
	begin
		set @idFactura = (select id from ventas.Factura where idFactura = @factura)
		if @idFactura is null
			set @error = @error + 'La factura ingresada no existe' + char(13)+ char(10)
		else
			if (select estado from ventas.Factura where id = @idFactura) = 'Impaga'
				set @error = @error + 'La factura ingresada esta impaga' + char(13)+ char(10)
	end
	--completamos la tabla auxiliar con los datos necesarios, idProd, cantidad, su precio en la linea de factura, y la cantidad historica devuelta
	insert into @tablaProdPrecio (idProd, cantidad, precio, cantidadHist)
	select tc.idProd, tc.cantidad, lf.precioUn, coalesce((select sum(ldc.cantProd) from comprobantes.comprobante c inner join comprobantes.LineaDeNotaDeCredito ldc on 
	ldc.idNotaCred=c.id where ldc.idProd=tc.idProd and c.idFactura=@idFactura and c.tipoComprobante='Nota de Credito'),0) from @tablaProductos tc
	left join ventas.LineaDeFactura lf
	on tc.idProd=lf.idProd and lf.idFactura=@idFactura

	--verificamos que ninguna cantidad sea nula
	if exists (select 1 from @tablaProdPrecio where cantidad<=0)
		set @error=@error+'Alguno de los productos contiene una cantidad para devolver invalida. (0 o menor).' + char(13) + char(10)
	--verificamos que los productos existan en la factura ingresada
	if exists (select 1 from @tablaProdPrecio where precio is null)
		set @error=@error+'Alguno de los productos ingresados no existen en la factura ingresada.'+char(13)+char(10)
	else
	begin
		--verificamos que de existir, ninguna cantidad sea mayor a su equivalente en la factura
		if exists (select 1 from ventas.LineaDeFactura lf inner join @tablaProdPrecio tp on lf.idProd=tp.idProd where idFactura=@idFactura and tp.cantidad>lf.cantidad)
			set @error=@error+'Alguno de los productos contiene una cantidad que sobrepasa la cantidad del mismo producto en la factura.' + char(13) + char(10)
		else if exists (select 1 from ventas.LineaDeFactura lf inner join @tablaProdPrecio tp on lf.idProd=tp.idProd where idFactura=@idFactura and tp.cantidad+tp.cantidadHist>lf.cantidad)
			set @error=@error+'Alguna cantidad de los productos contiene una cantidad que al ser sumado con otras notas de credito asociada a esta factura'+char(13)+char(10)+'sobrepasan la cantidad del mismo producto en la factura.'+char(13)+char(10)
		--y que de existir notas de credito anteriores que al sumarse con el actual no se sobrepasen
	end
	if @error <> ''
	begin
		raiserror(@error, 16, 1)
		return
	end
	begin transaction
		begin try
			declare @montoTotal decimal(20,2)
			set @montoTotal=(select sum(precio*cantidad) from @tablaProdPrecio)
			insert into comprobantes.Comprobante(tipoComprobante, idFactura, fecha, hora, monto)
				values('Nota de Credito', @idFactura, getdate(), convert(time, getdate()), @montoTotal)
			set @idNC = scope_identity() --obtenemos el id de la nota de credito recien generada
			insert into comprobantes.LineaDeNotaDeCredito (idNotaCred, idProd, cantProd,precioUn,subTotal)
			select @idNC, idProd, cantidad, precio, cantidad*precio from @tablaProdPrecio
	commit transaction
		end try
	begin catch
		rollback transaction
		raiserror('Hubo un error al realizar la transaccion que generaba la nota de credito. Intente nuevamente.',16,1)
	end catch
end
go
