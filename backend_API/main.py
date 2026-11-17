from contextlib import asynccontextmanager
from fastapi import FastAPI, Depends, HTTPException, UploadFile, File, Form
from fastapi.staticfiles import StaticFiles
from pathlib import Path
import shutil
import uuid
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
from pwdlib import PasswordHash
from database import Base, engine, obtener_sesion
from models import Usuario, Blog, Comentario
from schemas import (
    UsuarioCrear,
    UsuarioActualizar,
    UsuarioRespuesta,
    BlogRespuesta,
    BlogCrear,
    ComentarioCrear,
    ComentarioRespuesta,
    LoginRequest,
)

password_hash = PasswordHash.recommended()


@asynccontextmanager
async def lifespan(app: FastAPI):
    yield


app = FastAPI(
    title="API GlowSip",
    lifespan=lifespan,
)
UPLOAD_DIR = Path(r"C:\xampp\htdocs\blog_web\uploads")
UPLOAD_DIR.mkdir(parents=True, exist_ok=True)
app.mount("/uploads", StaticFiles(directory=UPLOAD_DIR), name="uploads")


@app.get("/")
def inicio():
    return {"mensaje": "API funcionando correctamente"}


# Permitir la comunicación con Flutter Web
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:60451",
        "http://127.0.0.1:60451",
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.post("/login", response_model=UsuarioRespuesta)
def iniciar_sesion(
    datos: LoginRequest,
    db: Session = Depends(obtener_sesion),
):
    correo = datos.mail.strip().lower()

    usuario = db.scalar(select(Usuario).where(Usuario.mail == correo))

    # Se utiliza el mismo mensaje para no revelar
    # si el correo esta registrado
    import bcrypt

    if usuario is None or not bcrypt.checkpw(
        datos.password.encode("utf-8"),
        usuario.pass_hash.replace("$2y$", "$2b$", 1).encode("utf-8"),
    ):
        raise HTTPException(
            status_code=401,
            detail="Correo o contraseña incorrectos",
        )

    # Devuelve únicamanet los datos públicos del usuario
    return {
        "id_usr": usuario.id_usr,
        "nom_usr": usuario.nom_usr,
        "mail": usuario.mail,
        "tip_usu": 1 if usuario.rol == "administrador" else 2,
    }


# Conserva debajo todos tus endpoints existentes:
# @app.get("/usuarios")
# @app.post("/usuarios")
# etc.

# USUARIOS


@app.get("/usuarios", response_model=list[UsuarioRespuesta])
def listar_usuarios(db: Session = Depends(obtener_sesion)):
    usuarios = db.scalars(select(Usuario).order_by(Usuario.id_usr)).all()
    return [
        {
            "id_usr": usuario.id_usr,
            "nom_usr": usuario.nom_usr,
            "mail": usuario.mail,
            "tip_usu": 1 if usuario.rol == "administrador" else 2,
        }
        for usuario in usuarios
    ]


@app.post("/usuarios", response_model=UsuarioRespuesta, status_code=201)
def crear_usuario(
    datos: UsuarioCrear,
    db: Session = Depends(obtener_sesion),
):
    usuario = Usuario(
        nom_usr=datos.nom_usr.strip(),
        mail=datos.mail.strip().lower(),
        pass_hash=password_hash.hash(datos.password),
        rol="visor",
    )

    db.add(usuario)

    try:
        db.commit()
        db.refresh(usuario)
    except IntegrityError:
        db.rollback()
        raise HTTPException(
            status_code=409,
            detail="El correo ya está registrado",
        )

    return {
        "id_usr": usuario.id_usr,
        "nom_usr": usuario.nom_usr,
        "mail": usuario.mail,
        "tip_usu": 1 if usuario.rol == "administrador" else 2,
    }


@app.put(
    "/usuarios/{usuario_id}",
    response_model=UsuarioRespuesta,
)
def actualizar_usuario(
    usuario_id: int,
    datos: UsuarioActualizar,
    db: Session = Depends(obtener_sesion),
):
    usuario = db.get(Usuario, usuario_id)

    if usuario is None:
        raise HTTPException(
            status_code=404,
            detail="Usuario no encontrado",
        )

    usuario.nom_usr = datos.nom_usr.strip()
    usuario.mail = datos.mail.strip().lower()
    usuario.rol = "administrador" if datos.tip_usu == 1 else "visor"

    try:
        db.commit()
        db.refresh(usuario)
    except IntegrityError:
        db.rollback()
        raise HTTPException(
            status_code=409,
            detail="El correo ya está registrado",
        )

    return {
        "id_usr": usuario.id_usr,
        "nom_usr": usuario.nom_usr,
        "mail": usuario.mail,
        "tip_usu": 1 if usuario.rol == "administrador" else 2,
    }


@app.delete("/usuarios/{usuario_id}")
def eliminar_usuario(
    usuario_id: int,
    db: Session = Depends(obtener_sesion),
):
    usuario = db.get(Usuario, usuario_id)

    if usuario is None:
        raise HTTPException(
            status_code=404,
            detail="Usuario no encontrado",
        )

    db.delete(usuario)
    db.commit()

    return {"mensaje": "Usuario eliminado correctamente"}


# BLOG


@app.get("/blog", response_model=list[BlogRespuesta])
def listar_blog(db: Session = Depends(obtener_sesion)):
    return db.scalars(select(Blog).order_by(Blog.id_blog)).all()


@app.post("/blog")
async def crear_blog(
    titulo: str = Form(...),
    descripcion: str = Form(...),
    tags: str = Form(""),
    imagen: UploadFile = File(...),
    id_autor: int = Form(...),
    db: Session = Depends(obtener_sesion),
):
    extension = Path(imagen.filename or "").suffix.lower()
    if extension not in [".jpg", ".jpeg", ".png", ".webp"]:
        raise HTTPException(400, "Formato de imagen no permitido")

    nombre_archivo = f"{uuid.uuid4().hex}{extension}"
    ruta_archivo = UPLOAD_DIR / nombre_archivo

    with ruta_archivo.open("wb") as destino:
        shutil.copyfileobj(imagen.file, destino)

    ruta_publica = f"/uploads/{nombre_archivo}"

    publicacion = Blog(
        titulo=titulo,
        descripcion=descripcion,
        tags=tags,
        img=nombre_archivo,
        estado="publicada",
        id_autor=id_autor,
    )
    db.add(publicacion)
    db.commit()
    db.refresh(publicacion)

    return {
        "mensaje": "Archivo recibido",
        "titulo": titulo,
        "descripcion": descripcion,
        "imagen": nombre_archivo,
    }


# COMENTARIOS


@app.get(
    "/comentarios",
    response_model=list[ComentarioRespuesta],
)
def listar_comentarios(db: Session = Depends(obtener_sesion)):
    return db.scalars(select(Comentario).order_by(Comentario.id_com)).all()


@app.post(
    "/comentarios",
    response_model=ComentarioRespuesta,
    status_code=201,
)
def crear_comentario(
    datos: ComentarioCrear,
    db: Session = Depends(obtener_sesion),
):
    if not datos.comentario.strip():
        raise HTTPException(
            status_code=422,
            detail="El comentario no puede estar vacío",
        )

    if db.get(Usuario, datos.usr_id) is None:
        raise HTTPException(
            status_code=404,
            detail="Usuario no encontrado",
        )

    if db.get(Blog, datos.blog_id) is None:
        raise HTTPException(
            status_code=404,
            detail="Publicación no encontrada",
        )

    nuevo = Comentario(
        comentario=datos.comentario.strip(),
        usr_id=datos.usr_id,
        blog_id=datos.blog_id,
    )

    db.add(nuevo)
    db.commit()
    db.refresh(nuevo)

    return nuevo