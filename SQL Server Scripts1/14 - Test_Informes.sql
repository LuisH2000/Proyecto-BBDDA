use Com5600G13
go

--Probamos generar el reporte con mes y anios invalidos, esperamos un mensaje de error
exec reportes.reporteMensualPorDia -1,-2019
exec reportes.reporteMensualPorDia null, null
--Generamos el reporte mensual con las ventas por dias
exec reportes.reporteMensualPorDia 1,2019

--Probamos generar el reporte con mes y anios invalidos, esperamos un mensaje de error
exec reportes.reporteTrimestralPorTurno -1,-2019
exec reportes.reporteTrimestralPorTurno null,null
--Generamos el reporte trimestral, mostrando las ventas totales por turnos para cada mes
exec reportes.reporteTrimestralPorTurno 1,2019


--Probamos generar el reporte con fechas invalidas, esperamos un mensaje de error
exec reportes.reporteProductosVendidos null, null
--Generamos el reporte de la cantidad de productos vendidos en el rango de fechas
--de mayor a menor
exec reportes.reporteProductosVendidos '2019-01-01', '2019-01-02'
