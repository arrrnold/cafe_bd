/*
# SCRIPT QUE GENERA LA BD "cafeteria" Y SUS TABLAS

# drop si ya existe
DROP SCHEMA IF EXISTS cafeteria;

CREATE SCHEMA IF NOT EXISTS cafeteria DEFAULT CHARACTER SET utf8;
USE cafeteria;

CREATE TABLE IF NOT EXISTS mensajes
(
    id        INT AUTO_INCREMENT PRIMARY KEY,
    fecha     DATETIME     NOT NULL,
    hora      TIME         NOT NULL,
    contenido VARCHAR(255) NOT NULL
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS pedidos
(
    id           INT AUTO_INCREMENT PRIMARY KEY,
    fecha        DATETIME     NOT NULL,
    cant_a_pagar INT          DEFAULT NULL, # puede ser nulo si el pedido se paga con tarjeta
    propina      INT          NOT NULL,
    total        INT          NOT NULL,
    pagado       TINYINT(1)   NOT NULL,
    preferencias VARCHAR(500) NOT NULL,
    ubicacion    VARCHAR(500) NOT NULL,
    folio        VARCHAR(45)  DEFAULT NULL, # puede ser nulo si el pedido se paga en efectivo
    estado       VARCHAR(45)  NOT NULL
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS productos
(
    id            INT AUTO_INCREMENT PRIMARY KEY,
    nombre        VARCHAR(255) NOT NULL,
    precio        INT          NOT NULL CHECK (precio > 0),
    cantidad      INT          NOT NULL CHECK (cantidad >= 0),
    recomendacion VARCHAR(255) NOT NULL, # 1 recomendado, 0 no recomendado
    imagen        VARCHAR(255) NOT NULL,
    categoria     VARCHAR(255) NOT NULL, # solo: 'bebida abiertas', 'bebida cerradas' y 'alimentos'
    visible       TINYINT(1)   DEFAULT 1 # 1 visible, 0 no visible
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS pedido_tiene_producto
(
    id          INT AUTO_INCREMENT PRIMARY KEY,
    pedido_id   INT NOT NULL,
    producto_id INT NOT NULL,
    cantidad    INT NOT NULL,
    precio      INT NOT NULL CHECK (precio > 0), # precio del producto en el momento de la compra
    CONSTRAINT pedido_tiene_producto_ibfk_1 FOREIGN KEY (pedido_id) REFERENCES pedidos (id) ON UPDATE CASCADE,
    CONSTRAINT pedido_tiene_producto_ibfk_2 FOREIGN KEY (producto_id) REFERENCES productos (id) ON UPDATE CASCADE
) ENGINE = InnoDB;

CREATE INDEX pedido_id ON pedido_tiene_producto (pedido_id);
CREATE INDEX producto_id ON pedido_tiene_producto (producto_id);

CREATE TABLE IF NOT EXISTS usuarios
(
    id                        INT AUTO_INCREMENT PRIMARY KEY,
    rol                       VARCHAR(13) DEFAULT 'usuario' NOT NULL, # puede ser usuario o administrador
    clave                     VARCHAR(255) NOT NULL,
    nombre_completo           VARCHAR(100) NOT NULL,
    email                     VARCHAR(100) NOT NULL,
    imagen_perfil             VARCHAR(255) DEFAULT NULL, # por defecto no tiene foto de perfil
    token_de_restablecimiento VARCHAR(100) DEFAULT NULL
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS usuario_tiene_mensaje
(
    id         INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    mensaje_id INT NOT NULL,
    CONSTRAINT usuario_tiene_mensaje_ibfk_1 FOREIGN KEY (usuario_id) REFERENCES usuarios (id) ON UPDATE CASCADE,
    CONSTRAINT usuario_tiene_mensaje_ibfk_2 FOREIGN KEY (mensaje_id) REFERENCES mensajes (id) ON UPDATE CASCADE
) ENGINE = InnoDB;

CREATE INDEX mensaje_id ON usuario_tiene_mensaje (mensaje_id);
CREATE INDEX usuario_id ON usuario_tiene_mensaje (usuario_id);

CREATE TABLE IF NOT EXISTS usuarios_tienen_pedidos
(
    id         INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    pedido_id  INT NOT NULL,
    CONSTRAINT usuarios_tienen_pedidos_ibfk_1 FOREIGN KEY (usuario_id) REFERENCES usuarios (id) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT usuarios_tienen_pedidos_ibfk_2 FOREIGN KEY (pedido_id) REFERENCES pedidos (id)
) ENGINE = InnoDB;

CREATE INDEX pedido_id ON usuarios_tienen_pedidos (pedido_id);
CREATE INDEX usuario_id ON usuarios_tienen_pedidos (usuario_id);
*/
# 1. Insertar un pedido en efectivo
INSERT INTO pedidos (fecha, cant_a_pagar, propina, total, pagado, preferencias, ubicacion, folio, estado)
VALUES ('2021-05-01 00:00:00', 100, 20, 120, 1, 'sin azúcar', 'Aula 123', NULL, 'entregado');

# 2. Insertar un pedido con tarjeta
INSERT INTO pedidos (fecha, cant_a_pagar, propina, total, pagado, preferencias, ubicacion, folio, estado)
VALUES ('2021-05-01 00:00:00', NULL, 20, 120, 1, 'sin cebolla', 'Lab. de computo', '1234567890', 'entregado');

# 3. Insertar un usuario
INSERT INTO usuarios (rol, clave, nombre_completo, email, imagen_perfil)
VALUES ('usuario', '123456', 'Juan Pérez', 'juan@mail.com', 'imagen');

# 3.1 Insertar un administrador
INSERT INTO usuarios (rol, clave, nombre_completo, email, imagen_perfil)
VALUES ('administrador', '123456', 'Pedro Pérez', 'pedro@mail.com', 'imagen');

# 4. Insertar un mensaje
INSERT INTO mensajes (fecha, hora, contenido)
VALUES ('2021-05-01 00:00:00', '12:00:00', 'Hola, ¿cómo estás?');

# 5. Insertar un producto
INSERT INTO productos (nombre, precio, cantidad, recomendacion, imagen, categoria, visible)
VALUES ('Coca Cola', 20, 100, '1', 'imagen', 'Bebidas abiertas', 1);

# otro producto
INSERT INTO productos (nombre, precio, cantidad, recomendacion, imagen, categoria, visible)
VALUES ('Agua', 15, 100, '0', 'imagen', 'Bebidas cerradas', 1);

# 6. Añadir ese producto a un pedido
INSERT INTO pedido_tiene_producto (pedido_id, producto_id, cantidad, precio)
VALUES (1, 1, 2, 20);

# 7. Añadir un mensaje a un usuario
INSERT INTO usuario_tiene_mensaje (usuario_id, mensaje_id)
VALUES (1, 1);

# 7.1 Añadir un pedido a un usuario
INSERT INTO usuarios_tienen_pedidos (usuario_id, pedido_id)
VALUES (1, 1);

# Pruebas de actualización (solo actualizan los usuarios y los productos)
# 8. Actualizar un usuario
UPDATE usuarios
SET nombre_completo = 'Juan Pérez Pérez'
WHERE id = 1;

# 9. Actualizar un producto
UPDATE productos
SET precio = 25
WHERE id = 1;

# Pruebas de 'eliminación' de los productos (solo se ocultan)
# 10. Eliminar un producto (solo se oculta)
UPDATE productos
SET visible = 0
WHERE id = 1;

# 11. Consultar todos los pedidos
SELECT *
FROM pedidos;

# 12. Consultar todos los usuarios
SELECT *
FROM usuarios;

# 13. Consultar todos los mensajes
SELECT *
FROM mensajes;

# 14. Consultar todos los productos
SELECT *
FROM productos;

# Consultas más avanzadas
# 16. Todos los pedidos de un usuario
SELECT *
FROM pedidos
WHERE id IN (SELECT pedido_id FROM usuarios_tienen_pedidos WHERE usuario_id = 1);

# Agregar más productos al pedido con id = 1
# Producto: Coca Cola (id = 1), agregar 3 unidades al pedido
INSERT INTO pedido_tiene_producto (pedido_id, producto_id, cantidad, precio)
VALUES (1, 1, 3, 20);

# Producto: Agua (id = 2), agregar 1 unidad al pedido
INSERT INTO pedido_tiene_producto (pedido_id, producto_id, cantidad, precio)
VALUES (1, 2, 1, 15);

# Insertar 10 productos con nombres comunes
INSERT INTO productos (nombre, precio, cantidad, recomendacion, imagen, categoria, visible)
VALUES ('Refresco', 25, 50, '1', 'imagen', 'Bebidas abiertas', 1),
       ('Hamburguesa', 30, 30, '1', 'imagen', 'Alimentos', 1),
       ('Agua', 10, 100, '0', 'imagen', 'Bebidas cerradas', 1),
       ('Pizza', 40, 20, '1', 'imagen', 'Alimentos', 1),
       ('Jugo de Naranja', 15, 80, '0', 'imagen', 'Bebidas abiertas', 1),
       ('Tacos', 50, 10, '1', 'imagen', 'Alimentos', 1),
       ('Café', 12, 90, '0', 'imagen', 'Bebidas abiertas', 1),
       ('Sándwich', 35, 40, '1', 'imagen', 'Alimentos', 1),
       ('Limonada', 8, 120, '0', 'imagen', 'Bebidas cerradas', 1),
       ('Ensalada', 45, 15, '1', 'imagen', 'Alimentos', 1);

# Crear nuevos pedidos utilizando los productos recién insertados
# Pedido 2 (pago en efectivo)
INSERT INTO pedidos (fecha, cant_a_pagar, propina, total, pagado, preferencias, ubicacion, folio, estado)
VALUES ('2021-05-02 00:00:00', 90, 15, 105, 1, 'sin cebolla', 'Casa', NULL, 'pendiente');

# Asociar productos al Pedido 2 en la tabla pedido_tiene_producto
INSERT INTO pedido_tiene_producto (pedido_id, producto_id, cantidad, precio)
VALUES (2, 2, 1, 30), # Hamburguesa
       (2, 5, 2, 15), # Jugo de Naranja
       (2, 7, 1, 12);
# Café

# Pedido 3 (pago con tarjeta)
INSERT INTO pedidos (fecha, cant_a_pagar, propina, total, pagado, preferencias, ubicacion, folio, estado)
VALUES ('2021-05-03 00:00:00', NULL, 10, 55, 1, 'extra queso', 'Oficina', '9876543210', 'entregado');

# Asociar productos al Pedido 3 en la tabla pedido_tiene_producto
INSERT INTO pedido_tiene_producto (pedido_id, producto_id, cantidad, precio)
VALUES (3, 3, 3, 10), # Agua
       (3, 9, 1, 8);
# Limonada

# Insertar productos en el pedido_tiene_producto
INSERT INTO pedido_tiene_producto (pedido_id, producto_id, cantidad, precio)
VALUES (1, 1, 2, 20),
       (1, 2, 1, 15),
       (1, 2, 1, 15),
       (1, 3, 3, 10),
       (1, 4, 1, 40),
       (1, 5, 2, 15),
       (1, 6, 1, 50),
       (1, 7, 1, 12),
       (1, 8, 1, 35),
       (1, 9, 1, 8),
       (1, 10, 1, 45);
