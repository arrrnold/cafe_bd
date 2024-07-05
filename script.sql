-- SCRIPT QUE GENERA LA BD "cafeteria" Y SUS TABLAS

-- drop si ya existe
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
    cant_a_pagar INT          DEFAULT NULL, -- puede ser nulo si el pedido se paga con tarjeta
    propina      INT          NOT NULL,
    total        INT          NOT NULL,
    pagado       TINYINT(1)   NOT NULL,
    preferencias VARCHAR(500) NOT NULL,
    ubicacion    VARCHAR(500) NOT NULL,
    folio        VARCHAR(45)  DEFAULT NULL, -- puede ser nulo si el pedido se paga en efectivo
    estado       VARCHAR(45)  NOT NULL
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS productos
(
    id            INT AUTO_INCREMENT PRIMARY KEY,
    nombre        VARCHAR(255) NOT NULL,
    precio        INT          NOT NULL CHECK (precio > 0),
    cantidad      INT          NOT NULL CHECK (cantidad >= 0),
    recomendacion VARCHAR(255) NOT NULL, -- 1 recomendado, 0 no recomendado
    imagen        VARCHAR(255) NOT NULL,
    categoria     VARCHAR(255) NOT NULL, -- solo: 'bebida abierta', 'bebida cerrada' y 'alimentos'
    visible       TINYINT(1)   DEFAULT 1 -- 1 visible, 0 no visible
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS pedido_tiene_producto
(
    id          INT AUTO_INCREMENT PRIMARY KEY,
    pedido_id   INT NOT NULL,
    producto_id INT NOT NULL,
    cantidad    INT NOT NULL,
    precio      INT NOT NULL CHECK (precio > 0), -- precio del producto en el momento de la compra
    CONSTRAINT pedido_tiene_producto_ibfk_1 FOREIGN KEY (pedido_id) REFERENCES pedidos (id) ON UPDATE CASCADE,
    CONSTRAINT pedido_tiene_producto_ibfk_2 FOREIGN KEY (producto_id) REFERENCES productos (id) ON UPDATE CASCADE
) ENGINE = InnoDB;

CREATE INDEX pedido_id ON pedido_tiene_producto (pedido_id);
CREATE INDEX producto_id ON pedido_tiene_producto (producto_id);

CREATE TABLE IF NOT EXISTS usuarios
(
    id                        INT AUTO_INCREMENT PRIMARY KEY,
    rol                       VARCHAR(13) DEFAULT 'usuario' NOT NULL, -- puede ser usuario o administrador
    clave                     VARCHAR(255) NOT NULL,
    nombre_completo           VARCHAR(100) NOT NULL,
    email                     VARCHAR(100) NOT NULL,
    imagen_perfil             VARCHAR(255) DEFAULT NULL, -- por defecto no tiene foto de perfil
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

