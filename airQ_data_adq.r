# Cargar librería necesaria
library(bogotAIR)
library(dplyr)

# Definir intervalo de fechas
start_date <- "01-10-2020"
end_date <- format(Sys.time(), "%d-%m-%Y %H:%M:%S")  # Fecha y hora actual
# end_date <- "31-12-2023"

# Obtener la lista de estaciones disponibles
estaciones <- rmcab_aqs

# Función para descargar datos de una estación
descargar_datos_estacion <- function(codigo_estacion) {
  tryCatch(
    {
      # Descargar los datos
      data <- download_rmcab_data(
        aqs_code = codigo_estacion,
        start_date = start_date,
        end_date = end_date
      )
      # Verificar si hay datos
      if (is.null(data) || nrow(data) == 0) {
        message(paste("Sin datos para la estación:", codigo_estacion))
        return(NULL)
      }
      message(paste("Datos descargados para la estación:", codigo_estacion))
      return(data)
    },
    error = function(e) {
      message(paste("Error al descargar datos para la estación:", codigo_estacion, ":", e))
      return(NULL)
    }
  )
}

# Descargar datos de todas las estaciones
datos_todas_estaciones <- lapply(estaciones$code, descargar_datos_estacion)

# Filtrar estaciones sin datos
datos_todas_estaciones <- datos_todas_estaciones[!sapply(datos_todas_estaciones, is.null)]

# Combinar todos los datos en un solo dataframe
if (length(datos_todas_estaciones) > 0) {
  base_datos <- bind_rows(datos_todas_estaciones)
  
  # Guardar el resultado en un archivo CSV
  write.csv(base_datos, "datos_calidad_aire_bogota_2020_2023.csv", row.names = FALSE)
  message("Archivo 'datos_calidad_aire_bogota_2020_2023.csv' guardado con éxito.")
} else {
  message("No se encontraron datos para ninguna estación en el rango de fechas especificado.")
}