CREATE SCHEMA IF NOT EXISTS mydb DEFAULT CHARACTER SET utf8;
USE mydb;

CREATE TABLE IF NOT EXISTS pedido (
  id INT NOT NULL,
  fecha DATE NOT NULL,
  cant_apagar INT NULL,
  propina INT NOT NULL,
  total INT NOT NULL,
  pagado TINYINT NOT NULL,
  preferencias VARCHAR(500) NOT NULL,
  ubicacion VARCHAR(500) NOT NULL,
  folio VARCHAR(45) NOT NULL,
  estado VARCHAR(45) NOT NULL,
  PRIMARY KEY (id)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS usuario (
  id INT NOT NULL,
  rol VARCHAR(13) NOT NULL,
  clave VARCHAR(10) NOT NULL,
  nombre_completo VARCHAR(100) NOT NULL,
  email VARCHAR(100) NOT NULL,
  imagen_perfil BLOB NOT NULL,
  pedido_id INT NOT NULL,
  PRIMARY KEY (id, pedido_id),
  INDEX fk_usuario_pedido1_idx (pedido_id ASC),
  CONSTRAINT fk_usuario_pedido1
    FOREIGN KEY (pedido_id)
    REFERENCES pedido (id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS mensaje (
  id INT NOT NULL,
  fecha DATE NOT NULL,
  hora DATETIME NOT NULL,
  contenido VARCHAR(1000) NOT NULL,
  PRIMARY KEY (id)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS producto (
  id INT NOT NULL,
  precio INT NOT NULL,
  cantidad INT NOT NULL,
  recomendacion TINYINT NOT NULL,
  imagen BLOB NOT NULL,
  categoria VARCHAR(20) NOT NULL,
  nombre VARCHAR(50) NOT NULL,
  PRIMARY KEY (id)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS pedido_tiene_producto (
  pedido_id INT NOT NULL,
  producto_id INT NOT NULL,
  cantidad INT NOT NULL,
  PRIMARY KEY (pedido_id, producto_id),
  INDEX fk_pedido_has_producto_producto1_idx (producto_id ASC),
  INDEX fk_pedido_has_producto_pedido1_idx (pedido_id ASC),
  CONSTRAINT fk_pedido_has_producto_pedido1
    FOREIGN KEY (pedido_id)
    REFERENCES pedido (id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_pedido_has_producto_producto1
    FOREIGN KEY (producto_id)
    REFERENCES producto (id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS usuario_has_mensaje (
  usuario_id INT NOT NULL,
  usuario_pedido_id INT NOT NULL,
  mensaje_id INT NOT NULL,
  PRIMARY KEY (usuario_id, usuario_pedido_id, mensaje_id),
  INDEX fk_usuario_has_mensaje_mensaje1_idx (mensaje_id ASC),
  INDEX fk_usuario_has_mensaje_usuario1_idx (usuario_id ASC, usuario_pedido_id ASC),
  CONSTRAINT fk_usuario_has_mensaje_usuario1
    FOREIGN KEY (usuario_id , usuario_pedido_id)
    REFERENCES usuario (id , pedido_id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_usuario_has_mensaje_mensaje1
    FOREIGN KEY (mensaje_id)
    REFERENCES mensaje (id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
) ENGINE = InnoDB;
