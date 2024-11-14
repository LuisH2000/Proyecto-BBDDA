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

create or alter proc comprobantes.generarNotaDeCredito
	@factura char(11),
	@idProd int,
	@cantidadDevolver decimal(5,3)
as
begin
	declare @error varchar(max) = ''
	declare @idFactura int
	declare @precio decimal(15,2)
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
	--verificamos la cantidad no sea nula y que sea mayor a 0
	if @cantidadDevolver is null or @cantidadDevolver <= 0
		set @error=@error+'La cantidad a devolver es invalida' + char(13) + char(10)
	--verificamos que el id del producto a devolver exista en la factura, y si existe, 
	--verificamos que se intente devolver la cantidad que compro o menos
	if not exists (select 1 from ventas.LineaDeFactura where idFactura = @idFactura and idProd = @idProd)
		set @error=@error+'El producto ingresado no se encuentra en la factura ingresada' + char(13) + char(10)
	else
		if (select cantidad from ventas.LineaDeFactura where idFactura = @idFactura and idProd = @idProd) < @cantidadDevolver
			set @error=@error+'La cantidad a devolver excede la cantidad comprada del producto para dicha factura' + char(13) + char(10)

	if @error <> ''
	begin
		raiserror(@error, 16, 1)
		return
	end
	set @precio = (select precioUn from ventas.LineaDeFactura where idFactura = @idFactura and idProd = @idProd)
	insert into comprobantes.Comprobante(tipoComprobante, idFactura, fecha, hora, monto)
		values('Nota de Credito', @idFactura, getdate(), convert(time, getdate()), @precio*@cantidadDevolver)
end
go