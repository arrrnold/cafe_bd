# SCRIPT QUE GENERA LA BD "cafeteria" Y SUS TABLAS

# drop si ya existe
DROP SCHEMA IF EXISTS cafeteria;

CREATE SCHEMA IF NOT EXISTS cafeteria DEFAULT CHARACTER SET utf8;
USE cafeteria;

CREATE TABLE IF NOT EXISTS pedido
(
    id           INT          NOT NULL AUTO_INCREMENT UNIQUE,
    fecha        DATE         NOT NULL,
    cant_apagar  INT          NULL,
    propina      INT          NOT NULL,
    total        INT          NOT NULL,
    pagado       TINYINT      NOT NULL,
    preferencias VARCHAR(500) NOT NULL,
    ubicacion    VARCHAR(500) NOT NULL,
    folio        VARCHAR(45)  NOT NULL,
    estado       VARCHAR(45)  NOT NULL,
    PRIMARY KEY (id)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS usuario
(
    id              INT          NOT NULL AUTO_INCREMENT UNIQUE,
    rol             VARCHAR(13)  NOT NULL,
    clave           VARCHAR(10)  NOT NULL,
    nombre_completo VARCHAR(100) NOT NULL,
    email           VARCHAR(100) NOT NULL,
    imagen_perfil   BLOB         NOT NULL,
    pedido_id       INT          NOT NULL,
    PRIMARY KEY (id, pedido_id),
    INDEX fk_usuario_pedido1_idx (pedido_id ASC),
    CONSTRAINT fk_usuario_pedido1 FOREIGN KEY (pedido_id) REFERENCES pedido (id) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS mensaje
(
    id        INT           NOT NULL AUTO_INCREMENT UNIQUE,
    fecha     DATE          NOT NULL,
    hora      DATETIME      NOT NULL,
    contenido VARCHAR(1000) NOT NULL,
    PRIMARY KEY (id)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS producto
(
    id            INT         NOT NULL AUTO_INCREMENT UNIQUE,
    precio        INT         NOT NULL CHECK (precio > 0),
    cantidad      INT         NOT NULL,
    recomendacion TINYINT     NOT NULL,
    imagen        BLOB        NOT NULL,
    categoria     VARCHAR(20) NOT NULL,
    nombre        VARCHAR(50) NOT NULL,
    PRIMARY KEY (id)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS pedido_tiene_producto
(
    pedido_id   INT NOT NULL,
    producto_id INT NOT NULL,
    cantidad    INT NOT NULL,
    PRIMARY KEY (pedido_id, producto_id),
    INDEX fk_pedido_has_producto_producto1_idx (producto_id ASC),
    INDEX fk_pedido_has_producto_pedido1_idx (pedido_id ASC),
    CONSTRAINT fk_pedido_has_producto_pedido1 FOREIGN KEY (pedido_id) REFERENCES pedido (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT fk_pedido_has_producto_producto1 FOREIGN KEY (producto_id) REFERENCES producto (id) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS usuario_has_mensaje
(
    usuario_id        INT NOT NULL,
    usuario_pedido_id INT NOT NULL,
    mensaje_id        INT NOT NULL,
    PRIMARY KEY (usuario_id, usuario_pedido_id, mensaje_id),
    INDEX fk_usuario_has_mensaje_mensaje1_idx (mensaje_id ASC),
    INDEX fk_usuario_has_mensaje_usuario1_idx (usuario_id ASC, usuario_pedido_id ASC),
    CONSTRAINT fk_usuario_has_mensaje_usuario1 FOREIGN KEY (usuario_id, usuario_pedido_id) REFERENCES usuario (id, pedido_id) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT fk_usuario_has_mensaje_mensaje1 FOREIGN KEY (mensaje_id) REFERENCES mensaje (id) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE = InnoDB;

/*
 ******************** 10 PRUEBAS DE INSERCIÓN, ACTUALIZACIÓN Y ELIMINACIÓN ********************
 */

# 1. Insertar un nuevo pedido
INSERT INTO pedido (fecha, cant_apagar, propina, total, pagado, preferencias, ubicacion, folio, estado)
VALUES ('2024-03-12', 50, 5, 55, 1, 'Sin azúcar', 'Mesa 3', '123456', 'En proceso');

# 2. Insertar un nuevo usuario y asociarlo a un pedido existente
INSERT INTO usuario (rol, clave, nombre_completo, email, imagen_perfil, pedido_id)
VALUES ('cliente', 'ocholetras', 'Juan Pérez', 'juan@example.com', 'foto', 1);

# 3. Insertar un nuevo mensaje
INSERT INTO mensaje (fecha, hora, contenido)
VALUES ('2024-03-12', '2024-03-12 10:00:00', '¡Pedido listo para recoger!');

# 4. Insertar un nuevo producto
INSERT INTO producto (precio, cantidad, recomendacion, imagen, categoria, nombre)
VALUES (15, 20, 0, 'foto', 'bebida', 'Jugo de naranja');

# 5. Insertar una relación entre un pedido y un producto existente
INSERT INTO pedido_tiene_producto (pedido_id, producto_id, cantidad)
VALUES (1, 1, 2);
# Suponiendo que el pedido y el producto existen con los IDs respectivos.

# 6. Actualizar el estado de un pedido existente
UPDATE pedido
SET estado = 'Listo para entregar'
WHERE id = 1;

# 7. Actualizar la información de un usuario existente
UPDATE usuario
SET nombre_completo = 'Juanita Pérez'
WHERE id = 1;

# 8. Eliminar un mensaje existente
DELETE
FROM mensaje
WHERE id = 1;

# 9. Eliminar un producto existente
DELETE
FROM producto
WHERE id = 1;

# 10. Consulta con JOIN para obtener información de pedidos y productos asociados
SELECT pedido.*, producto.nombre AS nombre_producto, producto.precio
FROM pedido
         JOIN pedido_tiene_producto ON pedido.id = pedido_tiene_producto.pedido_id
         JOIN producto ON pedido_tiene_producto.producto_id = producto.id;

# Pruebas adicionales

# 11. Insertar un pedido con fecha nula y verificar que se rechace la inserción
INSERT INTO pedido (cant_apagar, propina, total, pagado, preferencias, ubicacion, folio, estado)
VALUES (0, 0, 0, 0, '', '', '', '');
# Se espera un error debido a la fecha nula

# 12. Insertar un usuario con email duplicado y verificar que se rechace la inserción
INSERT INTO usuario (rol, clave, nombre_completo, email, imagen_perfil, pedido_id)
VALUES ('cliente', 'password', 'Pedro Pérez', 'juan@example.com', 'foto', 2);
# Se espera un error debido a email duplicado

# 13. Insertar un mensaje con contenido excesivamente largo y verificar que se trunque
INSERT INTO mensaje (fecha, hora, contenido)
VALUES ('2024-03-12', '2024-03-12 10:00:00', REPEAT('Mensaje largo. ', 100));
# Se espera que se trunque el contenido

# 14. Insertar un producto con precio negativo y verificar que se rechace la inserción
INSERT INTO producto (precio, cantidad, recomendacion, imagen, categoria, nombre)
VALUES (-10, 20, 0, 'foto', 'bebida', 'Jugo de naranja');
# Se espera un error debido a precio negativo

# 15. Insertar un pedido con estado inválido y verificar que se rechace la inserción
INSERT INTO pedido (fecha, cant_apagar, propina, total, pagado, preferencias, ubicacion, folio, estado)
VALUES ('2024-03-12', 50, 5, 55, 1, 'Sin azúcar', 'Mesa 3', '123456', 'Estado inválido');
# Se espera un error debido a estado inválido

# 16. Actualizar un usuario con clave demasiado larga y verificar que se rechace la actualización
UPDATE usuario
SET clave = 'contraseñademasiadolarga'
WHERE id = 1;
# Se espera un error debido a la longitud de la clave

# 17. Actualizar un pedido con fecha futura y verificar que se rechace la actualización
UPDATE pedido
SET fecha = DATE_ADD(CURDATE(), INTERVAL 1 DAY)
WHERE id = 1;
# Se espera un error debido a la fecha futura

# 18. Eliminar un mensaje inexistente y verificar que no ocurran cambios
DELETE
FROM mensaje
WHERE id = 100;
# Se espera que no ocurran cambios

# 19. Eliminar un producto asociado a un pedido y verificar que se eliminen las relaciones en `pedido_tiene_producto`
DELETE
FROM producto
WHERE id = 1;
# Se espera que se eliminen las relaciones en `pedido_tiene_producto`

# 20. Consultar un pedido asociado a un usuario inexistente y verificar que no se obtengan resultados
SELECT pedido.*
FROM pedido
         JOIN usuario ON pedido.id = usuario.pedido_id
WHERE usuario.id = 100;
# Se espera que no se obtengan resultados

# 21. Insertar un pedido con folio duplicado y verificar que se rechace la inserción
INSERT INTO pedido (fecha, cant_apagar, propina, total, pagado, preferencias, ubicacion, folio, estado)
VALUES ('2024-03-12', 50, 5, 55, 1, 'Sin azúcar', 'Mesa 3', '123456', 'En proceso');
# Se espera un error debido a folio duplicado

# 22. Actualizar el estado de un pedido a un valor no permitido y verificar que se rechace la actualización
UPDATE pedido
SET estado = 'Estado inválido'
WHERE id = 1;
# Se espera un error debido a estado no permitido

# 23. Consultar un pedido sin asociar a ningún usuario y verificar que no se obtengan resultados
SELECT pedido.*
FROM pedido
         LEFT JOIN usuario ON pedido.id = usuario.pedido_id
WHERE usuario.id IS NULL;
# Se espera que no se obtengan resultados

# 24. Eliminar un usuario con mensajes asociados y verificar que se eliminen las relaciones en `usuario_has_mensaje`
DELETE
FROM usuario
WHERE id = 1;
# Se espera que se eliminen las relaciones en `usuario_has_mensaje`

# 25. Insertar un producto sin asignar una categoría y verificar que se rechace la inserción
INSERT INTO producto (precio, cantidad, recomendacion, imagen, categoria, nombre)
VALUES (15, 20, 0, 'foto', '', 'Jugo de naranja');
# Se espera un error debido a categoría vacía

# 26. Actualizar un mensaje inexistente y verificar que no ocurran cambios
UPDATE mensaje
SET contenido = 'Mensaje actualizado'
WHERE id = 100;
# Se espera que no ocurran cambios

# 27. Eliminar un pedido asociado a un usuario y verificar que se elimine también el usuario
DELETE
FROM pedido
WHERE id = 1;
# Se espera que se elimine también el usuario asociado

# 28. Consultar un producto con una categoría inválida y verificar que no se obtengan resultados
SELECT *
FROM producto
WHERE categoria = 'Categoría inválida';
# Se espera que no se obtengan resultados

# 29. Insertar un usuario con rol no permitido y verificar que se rechace la inserción
INSERT INTO usuario (rol, clave, nombre_completo, email, imagen_perfil, pedido_id)
VALUES ('Rol inválido', 'password', 'Pedro Pérez', 'pedro@example.com', 'foto', 3);
# Se espera un error debido a rol no permitido

# 30. Actualizar la imagen de perfil de un usuario con formato inválido y verificar que se rechace la actualización
UPDATE usuario
SET imagen_perfil = 'imagen.jpg'
WHERE id = 1;
# Se espera un error debido a formato de imagen inválido

# Pruebas adicionales más estrictas

# 31. Verificar que la tabla `pedido` no permita valores nulos para las columnas requeridas
INSERT INTO pedido (cant_apagar, propina, total, pagado, preferencias, ubicacion, folio, estado)
VALUES (0, 0, 0, 0, '', '', '', '');
# Se espera un error debido a valores nulos

# 32. Insertar un pedido con una fecha futura y verificar que se inserte correctamente
INSERT INTO pedido (fecha, cant_apagar, propina, total, pagado, preferencias, ubicacion, folio, estado)
VALUES (DATE_ADD(CURDATE(), INTERVAL 1 DAY), 0, 0, 0, 0, '', '', '', 'En proceso');

# 33. Insertar un pedido con un valor negativo para la propina y verificar que se rechace la inserción
INSERT INTO pedido (fecha, cant_apagar, propina, total, pagado, preferencias, ubicacion, folio, estado)
VALUES (CURDATE(), 0, -5, 0, 0, '', '', '', 'En proceso');
# Se espera un error debido a la propina negativa

# 34. Insertar un pedido con un estado inválido y verificar que se rechace la inserción
INSERT INTO pedido (fecha, cant_apagar, propina, total, pagado, preferencias, ubicacion, folio, estado)
VALUES (CURDATE(), 0, 0, 0, 0, '', '', '', 'Estado inválido');
# Se espera un error debido a un estado inválido

# 35. Insertar un pedido con un folio duplicado y verificar que se rechace la inserción
INSERT INTO pedido (fecha, cant_apagar, propina, total, pagado, preferencias, ubicacion, folio, estado)
VALUES (CURDATE(), 0, 0, 0, 0, '', '', '123456', 'En proceso');
# Se espera un error debido a un folio duplicado

# 36. Verificar que la tabla `usuario` no permita valores nulos para las columnas requeridas
INSERT INTO usuario (rol, clave, nombre_completo, email, pedido_id)
VALUES ('', '', '', '', 0);
# Se espera un error debido a valores nulos

# 37. Insertar un usuario con un rol inválido y verificar que se rechace la inserción
INSERT INTO usuario (rol, clave, nombre_completo, email, pedido_id)
VALUES ('Rol inválido', 'contraseña', 'Juan Pérez', 'juan@example.com', 1);
# Se espera un error debido a un rol inválido

# 38. Insertar un usuario con un email duplicado y verificar que se rechace la inserción
INSERT INTO usuario (rol, clave, nombre_completo, email, pedido_id)
VALUES ('cliente', 'contraseña', 'Pedro Pérez', 'juan@example.com', 2);
# Se espera un error debido a un email duplicado

# 39. Insertar un usuario con una clave de longitud superior a 10 caracteres y verificar que se rechace la inserción
INSERT INTO usuario (rol, clave, nombre_completo, email, pedido_id)
VALUES ('cliente', 'contraseñalarga', 'Pedro Pérez', 'pedro@example.com', 2);
# Se espera un error debido a una clave demasiado larga

# 40. Insertar un usuario sin asociarlo a un pedido existente y verificar que se rechace la inserción
INSERT INTO usuario (rol, clave, nombre_completo, email, pedido_id)
VALUES ('cliente', 'contraseña', 'Pedro Pérez', 'pedro@example.com', 0);
# Se espera un error debido a un pedido inexistente

# 41. Verificar que la tabla `mensaje` no permita valores nulos para las columnas requeridas
INSERT INTO mensaje (fecha, hora, contenido)
VALUES (NULL, NULL, NULL);
# Se espera un error debido a valores nulos

# 42. Insertar un mensaje con un contenido vacío y verificar que se rechace la inserción
INSERT INTO mensaje (fecha, hora, contenido)
VALUES (CURDATE(), NOW(), '');
# Se espera un error debido a contenido vacío

# 43. Insertar un mensaje con una fecha posterior a la hora actual y verificar que se rechace la inserción
INSERT INTO mensaje (fecha, hora, contenido)
VALUES (DATE_ADD(CURDATE(), INTERVAL 1 DAY), NOW(), 'Hola mundo');
# Se espera un error debido a fecha futura

# 44. Insertar un mensaje con una hora posterior a la hora actual y verificar que se rechace la inserción
INSERT INTO mensaje (fecha, hora, contenido)
VALUES (CURDATE(), DATE_ADD(NOW(), INTERVAL 1 HOUR), 'Hola mundo');
# Se espera un error debido a hora futura


# TODO ojo no retorna lo que esperaba
# 45. 1 producto de cada pedido por fecha de pedido de 1 usuario sin repetirse
SELECT pedido.fecha, producto.nombre
FROM pedido
         JOIN pedido_tiene_producto ON pedido.id = pedido_tiene_producto.pedido_id
         JOIN producto ON pedido_tiene_producto.producto_id = producto.id
         JOIN usuario ON pedido.id = usuario.pedido_id
WHERE usuario.id = 1
GROUP BY pedido.fecha, producto.nombre;

