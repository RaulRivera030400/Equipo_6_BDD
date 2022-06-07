use covidHistorico

--Consulta 1: Listar los casos positivos por entidad de residencia.
--1.1 Solucion Inicial
	select ENTIDAD_RES, count(*) total_confirmado -- conteo casos confirmados
	from dbo.datoscovid
	where CLASIFICACION_FINAL between 1 and 3 -- condicion donde los casos son confirmados
	group by ENTIDAD_RES --Se agrupan y ordenan respetando el indice de ENTIDAD_RES
	order by ENTIDAD_RES
--1.2 Solución con indices de la tabla COPIA_ENTI
	select ENTIDAD_RES, count(*) total_confirmado -- conteo casos confirmados
	from dbo.COPIA_ENTI
	where CLASIFICACION_FINAL between 1 and 3 -- condicion donde los casos son confirmados
	group by ENTIDAD_RES --Se agrupan y ordenan respetando el indice de ENTIDAD_RES
	order by ENTIDAD_RES
--1.3 Solución con indices de la tabla COPIA_CLASIF
	select ENTIDAD_RES, count(*) total_confirmado -- conteo casos confirmados
	from dbo.COPIA_CLASIF
	where CLASIFICACION_FINAL between 1 and 3 -- condicion donde los casos son confirmados
	group by ENTIDAD_RES --Se agrupan y ordenan respetando el indice de ENTIDAD_RES
	order by ENTIDAD_RES

--Consulta 2: Listar los casos sospechosos por entidad.
--Solución inicial	
	Select ENTIDAD_UM, ENTIDAD_RES, count(*) total_sospechosos
	from dbo.datoscovid
	where CLASIFICACION_FINAL = 6	--Casos sospechosos es cuando CLASIFICACION_FINAL=6
	group by ENTIDAD_UM, ENTIDAD_RES
	order by ENTIDAD_UM

--2.1 Solución con indices de la tabla COPIA_CLASIF
	Select ENTIDAD_UM, ENTIDAD_RES, count(*) total_sospechosos
	from dbo.COPIA_CLASIF
	where CLASIFICACION_FINAL = 6
	group by ENTIDAD_UM, ENTIDAD_RES
	order by ENTIDAD_UM

--Consulta 3: Consulta numero 3: Listar el Top 5 de municipios por entidad con el mayor numero de casos reportados, 
--indicando casos sospechosos y casos confirmados.

--Solucion inicial	
	select ENTIDAD_RES,MUNICIPIO_RES,count(*) as reportados, count(case CLASIFICACION_FINAL when 1 then CLASIFICACION_FINAL
												when 2 then CLASIFICACION_FINAL
												when 3 then CLASIFICACION_FINAL
								end) as confirmado,				-- Se consideran los casos a evaluar para ser sumados en el count
			count(case CLASIFICACION_FINAL when 6 then CLASIFICACION_FINAL end) as sospechoso
	from dbo.datoscovid
	group by ENTIDAD_RES, MUNICIPIO_RES
	order by ENTIDAD_RES, reportados desc

--Solucion con indices de la Tabla COPIA_CLASIF
	select ENTIDAD_RES,MUNICIPIO_RES,count(*) as reportados, count(case CLASIFICACION_FINAL when 1 then CLASIFICACION_FINAL
												when 2 then CLASIFICACION_FINAL
												when 3 then CLASIFICACION_FINAL
								end) as confirmado,
			count(case CLASIFICACION_FINAL when 6 then CLASIFICACION_FINAL end) as sospechoso
	from dbo.COPIA_CLASIF
	group by ENTIDAD_RES, MUNICIPIO_RES
	order by ENTIDAD_RES, reportados desc

--Consulta 4: Determinar el municipio con el mayor número de defunciones en casos confirmados
--Solucion inicial
	Select TOP 1 ENTIDAD_RES,MUNICIPIO_RES, count(case CLASIFICACION_FINAL when 1 then CLASIFICACION_FINAL
													when 2 then CLASIFICACION_FINAL
													when 3 then CLASIFICACION_FINAL
									end) as Confirmados_fallecidos
	from dbo.datoscovid
	where FECHA_DEF != '9999-99-99' -- Caso donde no hay fecha de defunción, por lo que daría unicamente fechas reales
	GROUP BY ENTIDAD_RES,MUNICIPIO_RES
	ORDER BY Confirmados_fallecidos DESC;

--4.2 Solucion con indices de la tabla COPIA_CLASIF
	Select TOP 1 ENTIDAD_RES,MUNICIPIO_RES, count(case CLASIFICACION_FINAL when 1 then CLASIFICACION_FINAL
													when 2 then CLASIFICACION_FINAL
													when 3 then CLASIFICACION_FINAL
									end) as Confirmados_fallecidos
	from dbo.COPIA_CLASIF
	where FECHA_DEF != '9999-99-99'
	GROUP BY ENTIDAD_RES,MUNICIPIO_RES
	ORDER BY Confirmados_fallecidos DESC;

--Consulta 5: Determinar por entidad si por casos sospechosos hay defunciones reportadas asociadas a neumonía.
--Solución inicial
	SELECT DISTINCT ENTIDAD_RES from dbo.datoscovid --Debido a que la consulta arroja repeticiones se coloca un distinct
	where EXISTS(Select *from dbo.datoscovid 
				Where NEUMONIA = 1 and FECHA_DEF != '9999-99-99')	--1 corresponde a Si
	GROUP BY ENTIDAD_RES

--5.1 Solucion con indices de la tabla COPIA_CLASIF
	SELECT DISTINCT ENTIDAD_RES from dbo.COPIA_CLASIF 
	where EXISTS(Select *from dbo.datoscovid 
				Where NEUMONIA = 1 and FECHA_DEF != '9999-99-99')
	GROUP BY ENTIDAD_RES

--5.2 Solución 2 con indices de la tabla COPIA_CLASIF
	select ENTIDAD_RES,  count(*) from dbo.COPIA_CLASIF				-- Se obtiene la candidad de defunciones con el count
	where neumonia=1 and CLASIFICACION_FINAL=6 and FECHA_DEF !='9999-99-99'
	group by ENTIDAD_RES

--Consulta 6: Listar por entidad el total de casos sospechosos, casos confirmados, total de defunciones 
-- en los meses de Marzo a Agosto 2020 y de diciembre de 2020 a Mayo de 2021
	
--Solución inicial	
	select ENTIDAD_RES, count(*) as fallecidos, count(case CLASIFICACION_FINAL when 1 then CLASIFICACION_FINAL
													when 2 then CLASIFICACION_FINAL
													when 3 then CLASIFICACION_FINAL
									end) as confirmado, --Conteo casos confirmados 
									count(case CLASIFICACION_FINAL when 6 then CLASIFICACION_FINAL end) as sospechoso -- conteo casos sospechosos
	from dbo.datoscovid
	where (FECHA_DEF between '2020-03-01' and '2020-08-31') or (FECHA_DEF between '2020-12-01' and '2021-05-31') -- se filtra a unicamente el rango de esas fechas
	GROUP BY ENTIDAD_RES
--6.2 Solución con indices de la tabla COPIA_CLASIF
	select ENTIDAD_RES, count(*) as fallecidos, count(case CLASIFICACION_FINAL when 1 then CLASIFICACION_FINAL
													when 2 then CLASIFICACION_FINAL
													when 3 then CLASIFICACION_FINAL
									end) as confirmado,
									count(case CLASIFICACION_FINAL when 6 then CLASIFICACION_FINAL end) as sospechoso
	from dbo.COPIA_CLASIF
	where (FECHA_DEF between '2020-03-01' and '2020-08-31') or (FECHA_DEF between '2020-12-01' and '2021-05-31')
	GROUP BY ENTIDAD_RES

--Consulta 7:

--Consulta 8: Determinar si en el año 2020 hay una mayor cantidad de defunciones de menores de edad que en el año 2021 y 2022

--Solución inicial
		select  Defunciones_2020.d_20,Defunciones_2021.d_21,Defunciones_2022.d_22,
				case  when Defunciones_2020.d_20>Defunciones_2021.d_21+Defunciones_2022.d_22 then 'Es mayor a 2021+2022'
				else 'Es menor a 2021+2022'
		end as vs_SUMA_2122, case  when Defunciones_2020.d_20>Defunciones_2021.d_21 then 'Es mayor a 2021'
				else 'Es menor a 2021'
		end as vs_2021, case  when Defunciones_2020.d_20>Defunciones_2022.d_22 then 'Es mayor a 2022'
				else 'Es menor a 2022'
		end as vs_2022
				--Se filtra al año 2020
			from(select count(*) as d_20 from dbo.datoscovid where edad<18 and FECHA_DEF  between '2020-01-01' and '2020-12-31') Defunciones_2020,
				--Se filtra al año 2021
				(select count(*) as d_21 from dbo.datoscovid where edad<18 and FECHA_DEF  between '2021-01-01' and '2021-12-31') Defunciones_2021,
				--Se filtra al año 2022
				(select count(*) as d_22 from dbo.datoscovid where edad<18 and FECHA_DEF  between '2022-01-01' and '2022-12-31') Defunciones_2022

--Solución con indices de la tabla COPIA_CLASIF
--8.2
		select  Defunciones_2020.d_20,Defunciones_2021.d_21,Defunciones_2022.d_22,
				case  when Defunciones_2020.d_20>Defunciones_2021.d_21+Defunciones_2022.d_22 then 'Es mayor a 2021+2022'
				else 'Es menor a 2021+2022'
		end as vs_SUMA_2122, case  when Defunciones_2020.d_20>Defunciones_2021.d_21 then 'Es mayor a 2021'
				else 'Es menor a 2021'
		end as vs_2021, case  when Defunciones_2020.d_20>Defunciones_2022.d_22 then 'Es mayor a 2022'
				else 'Es menor a 2022'
		end as vs_2022
			from(select count(*) as d_20 from dbo.COPIA_CLASIF where edad<18 and FECHA_DEF  between '2020-01-01' and '2020-12-31') Defunciones_2020,
				(select count(*) as d_21 from dbo.COPIA_CLASIF where edad<18 and FECHA_DEF  between '2021-01-01' and '2021-12-31') Defunciones_2021,
				(select count(*) as d_22 from dbo.COPIA_CLASIF where edad<18 and FECHA_DEF  between '2022-01-01' and '2022-12-31') Defunciones_2022


--Consulta 9: Determinar si en el año 2021 hay un porcentaje mayor al 60 de casos reportados que son confirmados por 
--estudios de laboratorio en comparación al año 2020.

--Solución inicial
	Select t1.Confirmados_2020,t2.Confirmados_2021,(((t2.Confirmados_2021-t1.Confirmados_2020)*100)/Confirmados_2020)as Porcentaje -- Evaluar porcentaje
	from(select count(case CLASIFICACION_FINAL when 1 then CLASIFICACION_FINAL
													when 2 then CLASIFICACION_FINAL
													when 3 then CLASIFICACION_FINAL
									end) as Confirmados_2020 --Conteo casos confirmados
									from dbo.datoscovid where FECHA_SINTOMAS between '2020-01-01' and '2020-12-31') as t1,--subconsulta para casos totales 2020
									(select count(case CLASIFICACION_FINAL when 1 then CLASIFICACION_FINAL
													when 2 then CLASIFICACION_FINAL
													when 3 then CLASIFICACION_FINAL
									end) as Confirmados_2021 
									from dbo.datoscovid where FECHA_SINTOMAS between '2021-01-01' and '2021-12-31') as t2 --Subconsulta para casos totales 2021
--9.2 Solución con indices de la tabla COPIA_CLASIF
	Select t1.Confirmados_2020,t2.Confirmados_2021,(((t2.Confirmados_2021-t1.Confirmados_2020)*100)/Confirmados_2020)as Porcentaje
	from(select count(case CLASIFICACION_FINAL when 1 then CLASIFICACION_FINAL
													when 2 then CLASIFICACION_FINAL
													when 3 then CLASIFICACION_FINAL
									end) as Confirmados_2020 
									from dbo.COPIA_CLASIF where FECHA_SINTOMAS between '2020-01-01' and '2020-12-31') as t1,
									(select count(case CLASIFICACION_FINAL when 1 then CLASIFICACION_FINAL
													when 2 then CLASIFICACION_FINAL
													when 3 then CLASIFICACION_FINAL
									end) as Confirmados_2021 
									from dbo.COPIA_CLASIF where FECHA_SINTOMAS between '2021-01-01' and '2021-12-31') as t2 

--Consulta 10: Determinar en que rango de edad: menor de edad, 19 a 40, 40 a 60 o mayor de 60 hay mas casos reportados que 
--se hayan recuperado.

--10.1 Solución inicial
	select 
		--Condiciones para ver que rango es mayor, evaluandose cada uno
		case when R1.P_recuperadas>R2.P_recuperadas and R1.P_recuperadas>R3.P_recuperadas and R1.P_recuperadas>R4.P_recuperadas then 'Menores de edad se recuperan mas'
			 when R2.P_recuperadas>R1.P_recuperadas and R2.P_recuperadas>R3.P_recuperadas and R2.P_recuperadas>R4.P_recuperadas then '19 a 40 años se recuperan mas'
			 when R3.P_recuperadas>R1.P_recuperadas and R3.P_recuperadas>R2.P_recuperadas and R3.P_recuperadas>R4.P_recuperadas then '41 a 60 años se recuperan mas'
			 when R4.P_recuperadas>R1.P_recuperadas and R4.P_recuperadas>R2.P_recuperadas and R3.P_recuperadas>R4.P_recuperadas then 'Mayores de 60 se recuperan mas' 
	end as Supervivencia
	from 
			--Filtro para rango de menor de edad
			(select count(*) as P_recuperadas from dbo.datoscovid where FECHA_DEF ='9999-99-99' and (CLASIFICACION_FINAL= '1' or CLASIFICACION_FINAL = '3') and (EDAD<=18) AND TIPO_PACIENTE!=2) R1,
			--Filtro para rango de 19 a 40
			(select count(*) as P_recuperadas from dbo.datoscovid where FECHA_DEF ='9999-99-99' and (CLASIFICACION_FINAL= '1' or CLASIFICACION_FINAL = '3') and (EDAD between '19' and '40') AND TIPO_PACIENTE!=2) R2,
			--Filtro para rango de 40 a 60
			(select count(*) as P_recuperadas from dbo.datoscovid where FECHA_DEF ='9999-99-99' and (CLASIFICACION_FINAL= '1' or CLASIFICACION_FINAL = '3') and (EDAD between '41' and '60') AND TIPO_PACIENTE!=2 ) R3,
			--Filtro para rango de 60 en adelante
			(select count(*) as P_recuperadas from dbo.datoscovid where FECHA_DEF ='9999-99-99' and (CLASIFICACION_FINAL= '1' or CLASIFICACION_FINAL = '3') and (EDAD >'60') AND TIPO_PACIENTE!=2) R4

--10.2 Solución con índices de la tabla COPIA_CLASIF
	select 
		case when R1.P_recuperadas>R2.P_recuperadas and R1.P_recuperadas>R3.P_recuperadas and R1.P_recuperadas>R4.P_recuperadas then 'Menores de edad se recuperan mas'
			 when R2.P_recuperadas>R1.P_recuperadas and R2.P_recuperadas>R3.P_recuperadas and R2.P_recuperadas>R4.P_recuperadas then '19 a 40 años se recuperan mas'
			 when R3.P_recuperadas>R1.P_recuperadas and R3.P_recuperadas>R2.P_recuperadas and R3.P_recuperadas>R4.P_recuperadas then '41 a 60 años se recuperan mas'
			 when R4.P_recuperadas>R1.P_recuperadas and R4.P_recuperadas>R2.P_recuperadas and R3.P_recuperadas>R4.P_recuperadas then 'Mayores de 60 se recuperan mas' 
	end as Supervivencia
	from 
			(select count(*) as P_recuperadas from dbo.COPIA_CLASIF where FECHA_DEF ='9999-99-99' and (CLASIFICACION_FINAL= '1' or CLASIFICACION_FINAL = '3') and (EDAD<=18) AND TIPO_PACIENTE!=2) R1,
			(select count(*) as P_recuperadas from dbo.COPIA_CLASIF where FECHA_DEF ='9999-99-99' and (CLASIFICACION_FINAL= '1' or CLASIFICACION_FINAL = '3') and (EDAD between '19' and '40') AND TIPO_PACIENTE!=2) R2,
			(select count(*) as P_recuperadas from dbo.COPIA_CLASIF where FECHA_DEF ='9999-99-99' and (CLASIFICACION_FINAL= '1' or CLASIFICACION_FINAL = '3') and (EDAD between '41' and '60') AND TIPO_PACIENTE!=2 ) R3,
			(select count(*) as P_recuperadas from dbo.COPIA_CLASIF where FECHA_DEF ='9999-99-99' and (CLASIFICACION_FINAL= '1' or CLASIFICACION_FINAL = '3') and (EDAD >'60') AND TIPO_PACIENTE!=2) R4
