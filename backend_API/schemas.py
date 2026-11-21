from datetime import datetime
from pydantic import BaseModel, ConfigDict, Field


class UsuarioCrear(BaseModel):
    nom_usr: str = Field(min_length=2, max_length=100)
    mail: str = Field(min_length=5, max_length=150)
    password: str = Field(min_length=8, max_length=128)
    tip_usu: int = 2


class UsuarioRespuesta(BaseModel):
    id_usr: int
    nom_usr: str
    mail: str
    tip_usu: int

    model_config = ConfigDict(from_attributes=True)


class UsuarioActualizar(BaseModel):
    nom_usr: str = Field(min_length=2, max_length=100)
    mail: str = Field(min_length=5, max_length=150)
    tip_usu: int = 2


class BlogCrear(BaseModel):
    titulo: str = Field(min_length=2, max_length=150)
    descripcion: str = Field(min_length=1)
    img: str | None = Field(default=None, max_length=500)
    tags: str | None = Field(default=None, max_length=255)


class BlogRespuesta(BaseModel):
    id_blog: int
    titulo: str
    descripcion: str | None = None
    img: str | None = None
    tags: str | None = None

    model_config = ConfigDict(from_attributes=True)


class BlogActualizar(BaseModel):
    titulo: str = Field(min_length=2, max_length=150)
    descripcion: str = Field(min_length=1)
    tags: str | None = Field(default=None, max_length=255)


class ComentarioCrear(BaseModel):
    comentario: str = Field(min_length=1)
    usr_id: int
    blog_id: int


class ComentarioRespuesta(BaseModel):
    id_com: int
    comentario: str
    fecha: datetime
    usr_id: int
    blog_id: int

    model_config = ConfigDict(from_attributes=True)


class ComentarioActualizar(BaseModel):
    comentario: str = Field(min_length=1)


class LoginRequest(BaseModel):
    mail: str = Field(min_length=5, max_length=150)
    password: str = Field(min_length=1, max_length=128)

class CambiarPassword(BaseModel):
    password_actual: str = Field(min_length=1, max_length=128)
    password_nueva: str = Field(min_length=8, max_length=128)
