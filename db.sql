-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.admin_access_list (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  email text,
  id_escuela uuid DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  activo boolean DEFAULT false,
  tipo_administrador text,
  nombre text,
  apellido text,
  CONSTRAINT admin_access_list_pkey PRIMARY KEY (id)
);
CREATE TABLE public.alumno_tutores (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  id_alumno uuid NOT NULL,
  id_tutor uuid NOT NULL,
  fecha_vinculacion timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT alumno_tutores_pkey PRIMARY KEY (id),
  CONSTRAINT alumno_tutores_id_tutor_fkey FOREIGN KEY (id_tutor) REFERENCES public.usuarios(id),
  CONSTRAINT alumno_tutores_id_alumno_fkey FOREIGN KEY (id_alumno) REFERENCES public.alumnos(id)
);
CREATE TABLE public.alumnos (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  nombre text NOT NULL,
  id_grupo uuid NOT NULL,
  id_escuela uuid NOT NULL,
  matricula text NOT NULL,
  fecha_registro timestamp with time zone NOT NULL DEFAULT now(),
  id_turno uuid NOT NULL,
  CONSTRAINT alumnos_pkey PRIMARY KEY (id),
  CONSTRAINT alumnos_id_escuela_fkey FOREIGN KEY (id_escuela) REFERENCES public.escuelas(id),
  CONSTRAINT alumnos_id_turno_fkey FOREIGN KEY (id_turno) REFERENCES public.turnos(id),
  CONSTRAINT alumnos_id_grupo_fkey FOREIGN KEY (id_grupo) REFERENCES public.grupos(id)
);
CREATE TABLE public.contacto_webpage (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  tipo_solicitud text,
  correo text,
  telefono text,
  nombre_institucion text,
  cantidad_alumnos text,
  responsable text,
  mensaje text,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  tipo_institucion text,
  CONSTRAINT contacto_webpage_pkey PRIMARY KEY (id)
);
CREATE TABLE public.contactos_familiares (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  id_usuario uuid NOT NULL DEFAULT auth.uid(),
  nombre text NOT NULL,
  parentesco text NOT NULL,
  telefono text NOT NULL,
  email text,
  fecha_registro timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT contactos_familiares_pkey PRIMARY KEY (id),
  CONSTRAINT contacto_familiar_id_usuario_fkey FOREIGN KEY (id_usuario) REFERENCES public.usuarios(id)
);
CREATE TABLE public.escuelas (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  nombre text NOT NULL,
  codigo text,
  tipo text NOT NULL,
  direccion text NOT NULL,
  telefono text NOT NULL,
  email text NOT NULL,
  fecha_registro timestamp with time zone NOT NULL DEFAULT now(),
  descripcion text,
  preescolar boolean,
  primaria boolean,
  secundaria boolean,
  preparatoria boolean,
  sitio_web text,
  CONSTRAINT escuelas_pkey PRIMARY KEY (id)
);
CREATE TABLE public.grupos (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  id_escuela uuid NOT NULL,
  grupo text NOT NULL,
  nivel_educativo text NOT NULL,
  fecha_registro timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT grupos_pkey PRIMARY KEY (id),
  CONSTRAINT grupos_id_escuela_fkey FOREIGN KEY (id_escuela) REFERENCES public.escuelas(id)
);
CREATE TABLE public.horarios (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  id_materia uuid NOT NULL,
  id_escuela uuid NOT NULL,
  id_grupo uuid NOT NULL,
  lunes boolean,
  martes boolean,
  miercoles boolean,
  jueves boolean,
  viernes boolean,
  sabado boolean,
  domingo boolean,
  hora_inicio time with time zone,
  hora_fin time with time zone,
  aula text NOT NULL,
  fecha_registro timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT horarios_pkey PRIMARY KEY (id),
  CONSTRAINT horarios_id_escuela_fkey FOREIGN KEY (id_escuela) REFERENCES public.escuelas(id),
  CONSTRAINT horarios_id_materia_fkey FOREIGN KEY (id_materia) REFERENCES public.materias(id),
  CONSTRAINT horarios_id_grupo_fkey FOREIGN KEY (id_grupo) REFERENCES public.grupos(id)
);
CREATE TABLE public.llaves (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  codigo text NOT NULL,
  id_alumno uuid NOT NULL DEFAULT gen_random_uuid(),
  id_escuela uuid NOT NULL DEFAULT gen_random_uuid(),
  fecha_registro timestamp with time zone NOT NULL DEFAULT now(),
  fecha_desactivacion timestamp with time zone NOT NULL,
  limite_vinculacion bigint NOT NULL DEFAULT '2'::bigint,
  activo boolean DEFAULT false,
  CONSTRAINT llaves_pkey PRIMARY KEY (id),
  CONSTRAINT llaves_id_escuela_fkey FOREIGN KEY (id_escuela) REFERENCES public.escuelas(id),
  CONSTRAINT llaves_id_alumno_fkey FOREIGN KEY (id_alumno) REFERENCES public.alumnos(id)
);
CREATE TABLE public.materias (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  id_escuela uuid NOT NULL,
  nombre text NOT NULL,
  profesor text NOT NULL,
  color text,
  fecha_registro timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT materias_pkey PRIMARY KEY (id),
  CONSTRAINT materias_id_escuela_fkey FOREIGN KEY (id_escuela) REFERENCES public.escuelas(id)
);
CREATE TABLE public.mobile_tokens (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  id_usuario uuid NOT NULL DEFAULT gen_random_uuid(),
  token text NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT mobile_tokens_pkey PRIMARY KEY (id),
  CONSTRAINT mobile_tokens_id_usuario_fkey FOREIGN KEY (id_usuario) REFERENCES public.usuarios(id)
);
CREATE TABLE public.niveles_educativos (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  nombre text NOT NULL,
  id_escuela uuid NOT NULL,
  fecha_registro timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT niveles_educativos_pkey PRIMARY KEY (id),
  CONSTRAINT niveles_eduactivos_id_escuela_fkey FOREIGN KEY (id_escuela) REFERENCES public.escuelas(id)
);
CREATE TABLE public.notificaciones (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  id_alumno uuid NOT NULL,
  id_admin uuid NOT NULL,
  titulo text NOT NULL,
  mensaje text NOT NULL,
  tipo_notificacion text NOT NULL,
  tipo_comunicado text,
  prioridad_comunicado text,
  destinatarios_comunicado text,
  estado text NOT NULL DEFAULT 'nueva'::text,
  fecha_registro timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT notificaciones_pkey PRIMARY KEY (id),
  CONSTRAINT notificacion_id_alumno_fkey FOREIGN KEY (id_alumno) REFERENCES public.alumnos(id),
  CONSTRAINT notificacion_id_admin_fkey FOREIGN KEY (id_admin) REFERENCES public.usuarios(id)
);
CREATE TABLE public.turnos (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  turno text NOT NULL,
  hora_inicio time with time zone NOT NULL,
  hora_fin time with time zone NOT NULL,
  fecha-registro timestamp with time zone NOT NULL,
  id_escuela uuid NOT NULL DEFAULT gen_random_uuid(),
  tolerancia bigint DEFAULT '15'::bigint,
  CONSTRAINT turnos_pkey PRIMARY KEY (id),
  CONSTRAINT turnos_id_escuela_fkey FOREIGN KEY (id_escuela) REFERENCES public.escuelas(id)
);
CREATE TABLE public.usuarios (
  id uuid NOT NULL DEFAULT auth.uid(),
  email text NOT NULL,
  nombre text NOT NULL,
  apellido text NOT NULL,
  tipo text NOT NULL,
  tipo_administrador text,
  fecha_registro timestamp with time zone NOT NULL DEFAULT now(),
  id_escuela uuid,
  CONSTRAINT usuarios_pkey PRIMARY KEY (id),
  CONSTRAINT usuarios_id_escuela_fkey FOREIGN KEY (id_escuela) REFERENCES public.escuelas(id)
);