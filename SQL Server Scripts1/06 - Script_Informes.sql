use Com5600G13
go

create or alter proc reportes.reporteMensualPorDia
    @mes int,
    @anio int
as
begin
	declare @error varchar(200)
	set @error = ''
	if @mes <= 0 or @mes is null
	begin
		set @error = @error + 'El mes ingresado no es valido' + char(13) + char(10)
	end
	if @anio <= 0 or @anio is null
	begin
		set @error = @error + 'El anio ingresado no es valido' + char(13) + char(10)
	end

	if @error <> ''
	begin
		raiserror(@error, 16, 1)
		return
	end;

	with totalFactura as
	(
		select f.idFactura, f.fecha, sum(l.subtotal) as total
		from ventas.Factura f join ventas.LineaDeFactura l on l.idFactura = f.id
		group by f.idFactura, f.fecha
	)
    select 
        datename(weekday, fecha) AS DiaSemana,
        sum(total) AS TotalFacturado
    from totalFactura
    where month(fecha) = @mes AND year(fecha) = @anio
    group by datename(weekday, fecha)
    order by case
                 when datename(weekday, fecha) = 'Lunes' then 1
                 when datename(weekday, fecha) = 'Martes' then 2
                 when datename(weekday, fecha) = 'Miércoles' then 3
                 when datename(weekday, fecha) = 'Jueves' then 4
				 when datename(weekday, fecha) = 'Viernes' then 5
				 when datename(weekday, fecha) = 'Sábado' then 6
				 when datename(weekday, fecha) = 'Domingo' then 7
             end
    for xml path('Dia'), root('ReporteMensual');
end;
go

create or alter proc reportes.reporteTrimestralPorTurno
    @trimestre int,
    @anio int
as
begin
declare @error varchar(200)
	set @error = ''
	if @trimestre <= 0 or @trimestre >= 5 or @trimestre is null
	begin
		set @error = @error + 'El trimestre ingresado no es valido' + char(13) + char(10)
	end
	if @anio <= 0 or @anio is null
	begin
		set @error = @error + 'El anio ingresado no es valido' + char(13) + char(10)
	end

	if @error <> ''
	begin
		raiserror(@error, 16, 1)
		return
	end;

	with totalFactura as
	(
		select f.idFactura, f.fecha, e.turno, sum(l.subtotal) as total
		from ventas.Factura f join ventas.LineaDeFactura l on l.idFactura = f.id
								join recursosHumanos.Empleado e on e.legajo = f.empleadoLeg 
		group by f.idFactura, f.fecha, e.turno
	)
    select
		@trimestre as Trimestre,
        month(fecha) as Mes,
        turno as Turno,
        sum(total) as TotalFacturado
    from totalFactura
    where datepart(quarter, fecha) = @trimestre and year(fecha) = @anio
    group by month(fecha), turno
	order by month(fecha), turno
    for xml path('TurnoPorMes'), root('ReporteTrimestral');
end;
go

create or alter proc reportes.reporteProductosVendidos
    @fechaInicio date,
    @fechaFin date
as
begin
	declare @error varchar(100)
	set @error = ''
	if @fechaInicio is null
	begin
		set @error = @error + 'La fecha de inicio no es valida' + char(13) + char(10)
	end;
	if @fechaFin is null
	begin
		set @error = @error + 'La fecha de fin no es valida' + char(13) + char(10)
	end
	if @error <> ''
	begin
		raiserror(@error, 16, 1)
		return
	end;

	with cantProdVendPorDia as
	(
		select p.id, p.nombre, f.fecha, sum(l.cantidad) as total
		from ventas.Factura f join ventas.LineaDeFactura l on l.idFactura = f.id
								join catalogo.Producto p on p.id = l.idProd 
		group by p.id, p.nombre, f.fecha
	)
    select 
        id as ID,
		nombre as Producto,
        sum(total) as CantidadVendida
    from cantProdVendPorDia
    where fecha BETWEEN @FechaInicio AND @FechaFin
    group by id, nombre
    order by sum(total) desc
    for xml path('Producto'), root('ReporteProductosVendidos');
END;
