/*
Fecha de Entrega: 15/11/2024
Comision: 5600
Grupo 13
Bases de Datos Aplicadas

Alumnos:
	- Diaz, Nicolas 41714473
	- Huang, Luis 43098142

**ENUNCIADO**
Reportes: 
El sistema debe ofrecer los siguientes reportes en xml. 
Mensual: ingresando un mes y año determinado mostrar el total facturado por días de 
la semana, incluyendo sábado y domingo. 
Trimestral: mostrar el total facturado por turnos de trabajo por mes. 
Por rango de fechas: ingresando un rango de fechas a demanda, debe poder mostrar 
la cantidad de productos vendidos en ese rango, ordenado de mayor a menor. 
Por rango de fechas: ingresando un rango de fechas a demanda, debe poder mostrar 
la cantidad de productos vendidos en ese rango por sucursal, ordenado de mayor a 
menor. 
Mostrar los 5 productos más vendidos en un mes, por semana 
Mostrar los 5 productos menos vendidos en el mes. 
Mostrar total acumulado de ventas (o sea tambien mostrar el detalle) para una fecha 
y sucursal particulares 
*/

use Com5600G13
go

--Mensual: ingresando un mes y año determinado mostrar el total facturado por días de 
--la semana, incluyendo sábado y domingo. 
create or alter proc reportes.reporteMensualPorDia
    @mes int,
    @anio int
as
begin
	declare @error varchar(200)
	set @error = ''
	if @mes <= 0 or @mes > 12 or @mes is null
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

--Trimestral: mostrar el total facturado por turnos de trabajo por mes. 
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
		from ventas.Factura f
			join ventas.LineaDeFactura l on l.idFactura = f.id
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

/*
Por rango de fechas: ingresando un rango de fechas a demanda, debe poder mostrar 
la cantidad de productos vendidos en ese rango, ordenado de mayor a menor. 
*/
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
	if @fechaFin is not null and @fechaInicio is not null
		if datediff(day, @fechaInicio, @fechaFin) < 0
			set @error = @error + 'La fecha de fin es menor a la fecha de inicio' + char(13) + char(10)

	if @error <> ''
	begin
		raiserror(@error, 16, 1)
		return
	end;

	with cantProdVendPorDia as
	(
		select f.fecha, sum(l.cantidad) as total
		from ventas.Factura f join ventas.LineaDeFactura l on l.idFactura = f.id
		group by f.fecha
	)
    select 
        fecha as Fecha,
        sum(total) as CantidadVendida
    from cantProdVendPorDia
    where fecha between @FechaInicio and @FechaFin
    group by fecha
    order by sum(total) desc
    for xml path('CantProdVendidosXDia'), root('ReporteProductosVendidos');
end
go

/*
Por rango de fechas: ingresando un rango de fechas a demanda, debe poder mostrar 
la cantidad de productos vendidos en ese rango por sucursal, ordenado de mayor a 
menor. 
*/
create or alter proc reportes.reporteProductosPorSucursal
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
	if @fechaFin is not null and @fechaInicio is not null
		if datediff(day, @fechaInicio, @fechaFin) < 0
			set @error = @error + 'La fecha de fin es menor a la fecha de inicio' + char(13) + char(10)
	if @error <> ''
	begin
		raiserror(@error, 16, 1)
		return
	end;

	with cantProdVendPorSuc as
	(
		select f.fecha, s.id, s.ciudad, sum(l.cantidad) as total
		from ventas.Factura f 
			join ventas.LineaDeFactura l on l.idFactura = f.id
			join recursosHumanos.Empleado e on e.legajo = f.empleadoLeg
			join sucursales.Sucursal s on s.id = e.idSucursal
		group by f.fecha, s.id, s.ciudad
	)
	select 
		id as IDSucursal,
		ciudad as CiudadSucursal, 
		sum(total) as Total
	from cantProdVendPorSuc
    where Fecha between @fechaInicio and @fechaFin
    group by id, ciudad
    order by sum(total) desc
    for xml path('CantProdVendXSuc'), root('ReporteCantProdPorSucursal');
end
go

--Mostrar los 5 productos más vendidos en un mes, por semana 
create or alter proc reportes.reporteTop5ProductosPorSemana
    @mes int,
	@anio int
as
begin
    declare @error varchar(200) = ''

    if @anio <= 0 or @anio is null
    begin
        set @error = @error + 'El año ingresado no es válido' + char(13) + char(10)
    end
    if @mes <= 0 or @mes > 12 or @mes is null
    begin
        set @error = @error + 'El mes ingresado no es válido' + char(13) + char(10)
    end

    if @error <> ''
    begin
        raiserror(@error, 16, 1);
        return
    end;

    -- CTE para obtener la cantidad total vendida de cada producto por semana
    with ventasPorProducto as (
        select 
            p.id,
            p.nombre,
			datepart(week, f.fecha) - datepart(week, dateadd(month, datediff(month, 0, f.fecha), 0)) + 1 as semana,
            sum(l.cantidad) as total
        from ventas.Factura f
			join ventas.LineaDeFactura l on l.idFactura = f.id
			join catalogo.Producto p on p.id = l.idProd
        where year(f.fecha) = @anio and month(f.fecha) = @mes
        group by p.id, p.nombre, datepart(week, f.fecha) - datepart(week, dateadd(month, datediff(month, 0, f.fecha), 0)) + 1
    ),
    -- CTE para ordenar los productos segun el total vendido por semana
    top5Productos as (
        select 
            id,
            nombre,
			semana,
            total,
            dense_rank() over (partition by semana order by total desc) as rnk
        from ventasPorProducto
    )
    select 
		@anio as Anio,
        @mes as Mes,
        semana as Semana,
        (
            select 
				rnk as Posicion,
                id as IdProducto,
                nombre as Nombre,
                total as Total
            from top5Productos as t2
            where t2.Semana = t1.Semana and t2.rnk <= 5
            for xml path('Producto'), type
        ) as Productos
    from top5Productos as t1
    group by semana
    order by semana
    for xml path('Semana'), root('ReporteTop5Productos');
end;
go

--Mostrar los 5 productos menos vendidos en el mes. 
create or alter proc reportes.reporteTop5MenosVendidos
    @mes int,
	@anio int
as
begin
    declare @error varchar(200) = ''

    if @anio <= 0 or @anio is null
    begin
        set @error = @error + 'El año ingresado no es válido' + char(13) + char(10)
    end
    if @mes <= 0 or @mes > 12 or @mes is null
    begin
        set @error = @error + 'El mes ingresado no es válido' + char(13) + char(10)
    end

    if @error <> ''
    begin
        raiserror(@error, 16, 1);
        return
    end;

    -- CTE para obtener la cantidad total vendida de cada producto en el mes
    with ventasPorProducto as (
        select 
            p.id,
            p.nombre,
            sum(l.cantidad) as total
        from ventas.Factura f
			join ventas.LineaDeFactura l on l.idFactura = f.id
			join catalogo.Producto p on p.id = l.idProd
        where year(f.fecha) = @anio and month(f.fecha) = @mes
        group by p.id, p.nombre
    ),
    -- CTE para ordernar los productos segun sus ventas de forma ascendente
    top5Productos as (
        select 
            id,
            nombre,
            total,
            dense_rank() over (order by total asc) as rnk
        from ventasPorProducto
    )
    select 
		@anio as Anio,
        @mes as Mes,
        (
            select 
				rnk as Posicion,
                id as IdProducto,
                nombre as Nombre,
                total as Total
            from top5Productos as t2
            where t2.rnk <= 5
            for xml path('Producto'), type
        ) as Productos
    from top5Productos as t1
    for xml path('Mes'), root('ReporteTop5Productos');
end;
go

--Mostrar total acumulado de ventas (o sea tambien mostrar el detalle) para una fecha 
--y sucursal particulares 
create or alter proc reportes.totalAcumuladoFechaSucursal
	@fecha date,
	@idSucursal int
as
begin
	declare @error varchar(200) = ''
	if @fecha is null
		set @error = @error + 'No se ingreso una fecha valida' + char(13) + char(10)
	if not exists (select 1 from sucursales.Sucursal where id = @idSucursal)
		set @error = @error + 'La sucursal ingresada no existe' + char(13) + char(10);
	if @error <> ''
	begin
		raiserror(@error, 16, 1)
		return
	end;

	with totalPorFactura as
	(
		select idFactura, sum(subtotal) as total
		from ventas.LineaDeFactura
		group by idFactura
	)
	select 
		s.ciudad as Sucursal,
		f.idFactura as Nro_Factura, 
		f.fecha as Fecha,
		f.hora as Hora,
		f.empleadoLeg as Legajo_Empleado,
		f.idCliente as Cliente,
		t.total as Total,
		sum(t.total) over (partition by e.idSucursal) as Acumulado_Ventas
	from ventas.Factura f 
		join totalPorFactura t on t.idFactura = f.id
		join recursosHumanos.Empleado e on e.legajo = f.empleadoLeg
		join sucursales.Sucursal s on s.id = e.idSucursal
	where f.fecha = @fecha and e.idSucursal = @idSucursal
	order by f.hora
	for xml path('Factura'), root('ReporteAcumuladoPorSucursal');
end

