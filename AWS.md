# AWS Infrastructure

Documentación del servicio serverless creado como proxy intermedio 
entre Postly y la API pública de jsonplaceholder.

## Arquitectura
Postly App → API Gateway → Lambda → jsonplaceholder.typicode.com

## Recursos creados

| Recurso       | Nombre              | Región        |
|---------------|---------------------|---------------|
| Lambda        | postly-posts-api    | us-east-1     |
| API Gateway   | postly-api          | us-east-1     |
| Runtime       | Node.js 22.x        | —             |
| Stage         | $default            | Auto-deploy   |

## Endpoint

| Método | Ruta     | Descripción                    |
|--------|----------|-------------------------------|
| GET    | /posts   | Retorna los 100 posts          |
| OPTIONS| /posts   | Preflight CORS                 |

Base URL:
https://0ppd7fmnp7.execute-api.us-east-1.amazonaws.com

## Lambda — postly-posts-api

Función proxy que:
1. Recibe el request desde API Gateway
2. Consume https://jsonplaceholder.typicode.com/posts
3. Retorna la respuesta con headers CORS correctos

Maneja 3 escenarios:
- OPTIONS → responde preflight CORS con 200
- Upstream error → retorna el status code del upstream
- Error interno → retorna 500 con mensaje

## CORS

Configurado en dos niveles para garantizar compatibilidad:

1. API Gateway — configuración nativa de CORS
2. Lambda — headers en cada respuesta

| Header                       | Valor            |
|------------------------------|------------------|
| Access-Control-Allow-Origin  | *                |
| Access-Control-Allow-Methods | GET, OPTIONS     |
| Access-Control-Allow-Headers | Content-Type, Accept |
| Access-Control-Max-Age       | 300              |

> En producción se restringiría Access-Control-Allow-Origin 
> al dominio de la aplicación y se agregaría autenticación 
> mediante API Keys en API Gateway.

## Por qué serverless

| Criterio        | Beneficio                                      |
|-----------------|------------------------------------------------|
| Costo           | Pay per request — gratis en tier gratuito AWS  |
| Escalabilidad   | Auto-scaling sin configuración                 |
| Mantenimiento   | Sin servidores que administrar                 |
| Despliegue      | Instantáneo desde la consola AWS               |

## Por qué un proxy intermedio

Siguiendo el principio de Clean Architecture, la app no depende 
directamente de un proveedor externo. El proxy actúa como 
capa de abstracción:

- Si jsonplaceholder cambia su API, solo se actualiza la Lambda
- La app nunca sabe de dónde vienen los datos realmente
- Permite agregar caché, transformación o autenticación 
  en el futuro sin tocar la app
