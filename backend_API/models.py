from sqlalchemy import Column, Integer, String, Text, DateTime, ForeignKey, func
from database import Base


class Usuario(Base):
    __tablename__ = "usuarios"

    id_usr = Column("id_usuario", Integer, primary_key=True, index=True)
    nom_usr = Column("nombre", String(100), nullable=False)
    mail = Column("correo", String(150), unique=True, nullable=False)
    pass_hash = Column("password", String(255), nullable=False)
    rol = Column(String(20), nullable=False)
    fecha_registro = Column(DateTime, nullable=True)


class Blog(Base):
    __tablename__ = "publicaciones"

    id_blog = Column("id_publicacion", Integer, primary_key=True, index=True)
    titulo = Column(String(150), nullable=False)
    descripcion = Column("contenido", Text, nullable=True)
    img = Column("imagen", String(500), nullable=True)
    tags = Column("categoria", String(255), nullable=True)
    estado = Column(String(20), nullable=True)
    id_autor = Column(
        Integer,
        ForeignKey("usuarios.id_usuario"),
        nullable=False,
    )
    fecha_publicacion = Column(DateTime, nullable=True)


class Comentario(Base):
    __tablename__ = "comentarios"

    id_com = Column("id_comentario", Integer, primary_key=True, index=True)
    comentario = Column(Text, nullable=False)

    fecha = Column(
        "fecha_comentario",
        DateTime,
        nullable=False,
        server_default=func.current_timestamp(),
    )

    usr_id = Column(
        "id_usuario",
        Integer,
        ForeignKey("usuarios.id_usuario"),
        nullable=False,
    )

    blog_id = Column(
        "id_publicacion",
        Integer,
        ForeignKey("publicaciones.id_publicacion"),
        nullable=False,
    )
