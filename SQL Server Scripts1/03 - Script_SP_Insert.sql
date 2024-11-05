use [Com5600G13]
go
--SUCURSAL
create or alter proc sucursales.insertarSucursal 
	@ciudad varchar(20), 
	@dir varchar(100), 
	@horario varchar(50),
	@telefono char(9)
as
begin
	declare @error varchar(500)
	set @error = ''

	if @ciudad is null or ltrim(rtrim(@ciudad)) = ''
	begin
		set @error = 'No paso el nombre de la sucursal o paso un nombre vacio' + char(13) + char(10)
	end

	if @dir is null or ltrim(rtrim(@dir)) = ''
	begin
		set @error = @error + 'No paso la direccion de la sucursal o paso una direccion vacia' + char(13) + char(10)
	end

	if @horario is null or ltrim(rtrim(@horario)) = ''
	begin
		set @error = @error + 'No paso el horario de la sucursal o paso un horario vacio' + char(13) + char(10)
	end

	if @telefono is null or ltrim(rtrim(@telefono)) = ''
	begin
		set @error = @error + 'No paso el telefono de la sucursal o paso un telefono vacio' + char(13) + char(10)
	end

	if @telefono not like ('[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]')
	begin
		set @error = @error + 'El telefono ingresado no es valido, formato te telefono: xxxx-xxxx' + char(13) + char(10)
	end

	if exists (select 1 from sucursales.Sucursal where direccion = @dir and ciudad = @ciudad)
	begin
		set @error = @error + 'Ya existe una sucursal en: ' + @dir + char(13) + char(10)
	end
	
	if @error <> ''
	begin
		raiserror(@error, 16, 1)
		return
	end
	
	insert into sucursales.Sucursal(ciudad, direccion, horario, telefono)
	values(@ciudad, @dir, @horario, @telefono)

end

--EMPLEADO
--CARGO
--LINEAPRODUCTO
--PRODUCTO
--CATEGORIA
--TIPOCLIENTE
--FACTURA (recibe una tabla con los productos a guardar en lineafactura)
--MEDIODEPAGO
--COMPROBANTE
