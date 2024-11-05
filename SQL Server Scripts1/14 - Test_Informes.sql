use Com5600G13
go
--***Reporte mensual con las ventas por dias***
--Probamos generar el reporte con mes y anios invalidos, esperamos un mensaje de error
exec reportes.reporteMensualPorDia -1,-2019
exec reportes.reporteMensualPorDia null, null
--Generamos el reporte mensual con las ventas por dias
exec reportes.reporteMensualPorDia 1,2019

--***Reporte trimestral, ventas totales por turnos para cada mes***
--Probamos generar el reporte con mes y anios invalidos, esperamos un mensaje de error
exec reportes.reporteTrimestralPorTurno -1,-2019
exec reportes.reporteTrimestralPorTurno null,null
--Generamos el reporte trimestral, mostrando las ventas totales por turnos para cada mes
exec reportes.reporteTrimestralPorTurno 1,2019

--***Reporte de cantidad de productos vendidos en el rango de fechas***
--Probamos generar el reporte con fechas invalidas, esperamos un mensaje de error
exec reportes.reporteProductosVendidos null, null
--Generamos el reporte de la cantidad de productos vendidos en el rango de fechas
--de mayor a menor
exec reportes.reporteProductosVendidos '2019-01-01', '2019-01-02'

--***Reporte de cantidad de productos vendidos en el rango de fechas
--Probamos generar el reporte con fechas invalidas, esperamos un mensaje de error
exec reportes.reporteProductosVendidos null, null
--Generamos el reporte de la cantidad de productos vendidos en el rango de fechas
--de mayor a menor
exec reportes.reporteProductosVendidos '2019-01-01', '2019-01-02'

--***Reporte de cantidad de productos vendidos por sucursales en un rango de fechas***
--Probamos generar el reporte con fechas invalidas, esperamos un mensaje de error
exec reportes.reporteProductosPorSucursal null, null
--Generamos el reporte de cantidad de productos vendidos por sucursales en un rango
--de fechas de mayor a menor
exec reportes.reporteProductosPorSucursal '2019-01-01', '2019-01-02'

--***Reporte para mostrar los 5 productos más vendidos en un mes, por semana***
--Probamos generar el reporte con mes y anio invalidos, esperamos un mensaje de error
exec reportes.reporteTop5ProductosPorSemana -1, 0
exec reportes.reporteTop5ProductosPorSemana null, null
--Generamos el reporte de los 5 productos mas vendidos en un mes, por semana
exec reportes.reporteTop5ProductosPorSemana 2019, 2


