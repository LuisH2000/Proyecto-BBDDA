use Com5600G13
go

create or alter proc comprobantes.generarNotaDeCredito
	@factura char(11),
	@idProd int,
	@cantidadDevolver int
as
begin
	declare @error varchar(max) = ''
	declare @idFactura int
	declare @precio decimal(15,2)
	set @factura = ltrim(rtrim(@factura))
	--verificamos que la factura no este vacia
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
	--verificamos que el id del producto a devolver exista en la factura, y si existe, verificamos que se intente devolver la cantidad que compro o menos
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