# # SCRIPT QUE GENERA LA BD "cafeteria" Y SUS TABLAS
#
# # drop si ya existe
# DROP SCHEMA IF EXISTS cafeteria;
#
# CREATE SCHEMA IF NOT EXISTS cafeteria DEFAULT CHARACTER SET utf8;
# USE cafeteria;
#
# CREATE TABLE IF NOT EXISTS pedido
# (
#     id           INT          NOT NULL AUTO_INCREMENT UNIQUE,
#     fecha        DATE         NOT NULL,
#     cant_a_pagar INT          NULL, # puede ser nulo si el pedido se paga con tarjeta
#     propina      INT          NOT NULL,
#     total        INT          NOT NULL,
#     pagado       TINYINT      NOT NULL,
#     preferencias VARCHAR(500) NOT NULL,
#     ubicacion    VARCHAR(500) NOT NULL,
#     folio        VARCHAR(45)  NULL, # puede ser nulo si el pedido se en efectivo
#     estado       VARCHAR(45)  NOT NULL,
#     PRIMARY KEY (id)
# ) ENGINE = InnoDB;
#
# CREATE TABLE IF NOT EXISTS usuario
# (
#     id              INT          NOT NULL AUTO_INCREMENT UNIQUE,
#     rol             VARCHAR(13)  NOT NULL DEFAULT 'usuario', # puede ser usuario o administrador
#     clave           VARCHAR(10)  NOT NULL,
#     nombre_completo VARCHAR(100) NOT NULL,
#     email           VARCHAR(100) NOT NULL,
#     imagen_perfil   BLOB         NOT NULL,
#     pedido_id       INT          NULL,                       # puede ser nulo si el usuario no ha hecho un pedido
#     PRIMARY KEY (id),
#     INDEX fk_usuario_pedido1_idx (pedido_id ASC),
#     CONSTRAINT fk_usuario_pedido1 FOREIGN KEY (pedido_id) REFERENCES pedido (id) ON DELETE NO ACTION ON UPDATE NO ACTION
# ) ENGINE = InnoDB;
#
#
# CREATE TABLE IF NOT EXISTS mensaje
# (
#     id        INT           NOT NULL AUTO_INCREMENT UNIQUE,
#     fecha     DATE          NOT NULL,
#     hora      TIME          NOT NULL,
#     contenido VARCHAR(1000) NOT NULL,
#     PRIMARY KEY (id)
# ) ENGINE = InnoDB;
#
# CREATE TABLE IF NOT EXISTS producto
# (
#     id            INT         NOT NULL AUTO_INCREMENT UNIQUE,
#     precio        INT         NOT NULL CHECK (precio > 0),
#     cantidad      INT         NOT NULL check ( cantidad >= 0),
#     recomendacion TINYINT     NOT NULL,           # 1 recomendado, 0 no recomendado
#     imagen        BLOB        NOT NULL,
#     categoria     VARCHAR(20) NOT NULL,           # solo: 'bebida abierta', 'bebida cerrada' y 'alimentos'
#     nombre        VARCHAR(50) NOT NULL,
#     visible       TINYINT     NOT NULL DEFAULT 1, # 1 visible, 0 no visible
#     PRIMARY KEY (id)
# ) ENGINE = InnoDB;
#
# CREATE TABLE IF NOT EXISTS pedido_tiene_producto
# (
#     pedido_id   INT NOT NULL,
#     producto_id INT NOT NULL,
#     cantidad    INT NOT NULL,
#     precio      INT NOT NULL CHECK (precio > 0), # precio del producto en el momento de la compra
#     PRIMARY KEY (pedido_id, producto_id),
#     INDEX fk_pedido_has_producto_producto1_idx (producto_id ASC),
#     INDEX fk_pedido_has_producto_pedido1_idx (pedido_id ASC),
#     CONSTRAINT fk_pedido_has_producto_pedido1 FOREIGN KEY (pedido_id) REFERENCES pedido (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
#     CONSTRAINT fk_pedido_has_producto_producto1 FOREIGN KEY (producto_id) REFERENCES producto (id) ON DELETE NO ACTION ON UPDATE NO ACTION
# ) ENGINE = InnoDB;
#
# CREATE TABLE IF NOT EXISTS usuario_tiene_mensaje
# (
#     usuario_id INT NOT NULL,
#     mensaje_id INT NOT NULL,
#     PRIMARY KEY (usuario_id, mensaje_id),
#     INDEX fk_usuario_has_mensaje_mensaje1_idx (mensaje_id ASC),
#     INDEX fk_usuario_has_mensaje_usuario1_idx (usuario_id ASC),
#     CONSTRAINT fk_usuario_has_mensaje_usuario1 FOREIGN KEY (usuario_id) REFERENCES usuario (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
#     CONSTRAINT fk_usuario_has_mensaje_mensaje1 FOREIGN KEY (mensaje_id) REFERENCES mensaje (id) ON DELETE NO ACTION ON UPDATE NO ACTION
# ) ENGINE = InnoDB;
#

# 1. Insertar un pedido en efectivo
INSERT INTO pedidos (fecha, cant_a_pagar, propina, total, pagado, preferencias, ubicacion, folio, estado)
VALUES ('2021-05-01', 100, 20, 120, 1, 'sin azúcar', 'Aula 123', null, 'entregado');

# 2. Insertar un pedido con tarjeta
INSERT INTO pedidos (fecha, cant_a_pagar, propina, total, pagado, preferencias, ubicacion, folio, estado)
VALUES ('2021-05-01', null, 20, 120, 1, 'sin cebolla', 'Lab. de computo', '1234567890', 'entregado');

# 3. Insertar un usuario
INSERT INTO usuarios (rol, clave, nombre_completo, email, imagen_perfil, pedido_id)
VALUES ('usuario', '123456', 'Juan Pérez', 'juan@mail.com', 'imagen', null);

# 4. Insertar un mensaje
INSERT INTO mensajes (fecha, hora, contenido)
VALUES ('2021-05-01', '12:00:00', 'Hola, ¿cómo estás?');

# 5. Insertar un producto
INSERT INTO productos (precio, cantidad, recomendacion, imagen, categoria, nombre, visible)
VALUES (20, 100, 1, 'imagen', 'bebida abierta', 'Coca Cola', 1);

# 6. Añadir ese producto a un pedido
INSERT INTO pedido_tiene_producto (pedido_id, producto_id, cantidad, precio)
VALUES (1, 1, 2, 20);

# 7. Añadir un mensaje a un usuario
INSERT INTO usuario_tiene_mensaje (usuario_id, mensaje_id)
VALUES (1, 1);

# 7.1 Añadir un pedido a un usuario
UPDATE usuarios
SET pedido_id = 1
WHERE id = 1;

/* Pruebas de actualizacion (solo actualizan los usuarios y los productos) */

# 8. Actualizar un usuario
UPDATE usuarios
SET nombre_completo = 'Juan Pérez Pérez'
WHERE id = 1;

# 9. Actualizar un producto
UPDATE productos
SET precio = 25
WHERE id = 1;

/* Pruebas de 'eliminacion' de los productos */

# 10. Eliminar un producto (solo se oculta)
UPDATE productos
SET visible = 0
WHERE id = 1;

/*
 ******************** 10 PRUEBAS DE CONSULTAS ********************
 */

# 11. Consultar todos los pedidos
SELECT * FROM pedidos;

# 12. Consultar todos los usuarios
SELECT * FROM usuarios;

# 13. Consultar todos los mensajes
SELECT * FROM mensajes;

# 14. Consultar todos los productos
SELECT * FROM productos;

/* Consultas mas avanzadas */

# 16. Todos los pedidos de un usuario
SELECT * FROM pedidos
WHERE id = (SELECT pedido_id FROM usuarios WHERE id = 1);


