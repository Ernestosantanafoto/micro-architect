class_name GameConstants

const DEBUG_MODE = false 

# --- TILES ---
const TILE_VACIO = -1
const TILE_ESTABILIDAD = 0 
const TILE_CARGA = 1        
const TILE_ROJO = 2         

# --- CAPAS ---
const LAYER_PAREDES = 1
const LAYER_PULSOS = 2
const LAYER_EDIFICIOS = 4

# --- CÁMARA ---
const CAMARA_SENSIBILIDAD = 0.05
const CAMARA_INCLINACION_X = -80.0
const CAMARA_ZOOM_INICIAL = 100.0
const CAMARA_ZOOM_MIN = 5.0
const CAMARA_ZOOM_MAX = 200.0
const CAMARA_ZOOM_PASO = 3.0
## Margen extra al encuadrar selección: la cuadrícula nunca toca los bordes (siempre un poco más de espacio).
const CAMARA_SELECCION_MARGEN := 1.4

# --- JUEGO ---
const GAME_TICK_DURATION = 1.0 

# --- ENERGÍA ---
const ENERGIA_BASE = 1
const ENERGIA_COMPRIMIDA = 10
const UMBRAL_COMPRESION = 10

# --- PULSOS ---
const PULSO_VELOCIDAD_BASE = 2.0
const PULSO_VELOCIDAD_VISUAL = 1.0  # Unidades/seg para visual constante
const PULSO_RANGO_MAXIMO = 6
const PULSO_INTENSIDAD_BRILLO = 3.0
const PULSO_TIEMPO_DESAPARECER = 0.2

# --- HACES DE LUZ ---
const HAZ_LONGITUD_PREVIEW = 1
const HAZ_LONGITUD_MAXIMA = 5
const HAZ_OFFSET_ORIGEN = 0.25   # primer segmento: centro aquí para que el haz arranque en el prisma (0.5 de largo)
const HAZ_SEGMENTO_OFFSET = 0.25
const HAZ_ALPHA_TRANSPARENCIA = 0.4
const HAZ_EMISION_ENERGIA = 3.0

# --- PRISMAS ---
const ALCANCE_PRISMA = 5
const ALCANCE_PRISMA_T2 = 15
const TIEMPO_PERSISTENCIA_LUZ = 50
const UMBRAL_ESCALA_MINIMA = 0.1
const OFFSET_SPAWN_PULSO = 0.05
const UMBRAL_ALINEACION_RECTA = 0.9
const UMBRAL_REFLEXION_ANGULO = -0.5
const TIEMPO_REBOTE_PRISMA = 0.0
const TIEMPO_VIAJE_CENTRO = 0.15
const PRISMA_DISTANCIA_CENTRO_MIN = 0.05
# Apagado: T1 gris azulado muy transparente, T2 casi opaco y blanco
const PRISMA_COLOR_APAGADO_T1 = Color(0.52, 0.58, 0.72, 0.18)   # gris azulado, mucha transparencia
const PRISMA_COLOR_APAGADO_T2 = Color(1.0, 1.0, 1.0, 0.95)      # casi opaco, blanco
const PRISMA_ALPHA_ENCENDIDO = 0.4               
const PRISMA_TIEMPO_ANIMACION_COLOR = 0.2        
const PRISMA_BRILLO_INTENSIDAD = 6.0             

# --- CONSTRUCCIÓN ---
const RAYCAST_LONGITUD = 1000.0
const ANGULO_ROTACION = -90.0
const ALTURA_FANTASMA = 0.5
const ESCALA_AL_RECOGER = 1.2
const ESCALA_POP_ROTACION = 1.1
const TIEMPO_ANIM_RECOGER = 0.15
const TIEMPO_ANIM_SOLTAR = 0.1
const COLOR_CONSTRUCCION_VALIDA = Color.WHITE
const COLOR_CONSTRUCCION_INVALIDA = Color(1.0, 0.212, 0.161, 0.745)

# --- UI ---
const UI_OFFSET_3D_Y = 2.0      
const UI_POP_TIME = 0.2          
const UI_CLICK_DEBOUNCE = 0.01   

# --- RECURSOS ---
const RECURSO_STABILITY = "Stability"
const COLOR_STABILITY = Color(0.2, 0.8, 0.2)
const RECURSO_CHARGE = "Charge"
const COLOR_CHARGE = Color(1.0, 0.0, 1.0, 1.0)

# --- SIFÓN ---
const SIFON_TICKS_POR_DISPARO = 5 
const SIFON_OFFSET_SALIDA_Y = 0.5
const SIFON_BRILLO_CARA = 2.0
const SIFON_T2_TICKS = 2          
const SIFON_T2_ENERGIA = 2        
const SIFON_T2_BRILLO = 5.0

# --- COMPRESOR ---
const COLOR_COMPRESOR_DEFECTO = Color.WHITE
const PREFIJO_COMPRIMIDO = "Compressed-"
const COMPRESOR_SPAWN_ALTURA = 0.5
const COMPRESOR_ESCALA_PULSO = 1.5
const COMPRESOR_OFFSET_SALIDA = 1.2
const COMPRESOR_ANIM_ESCALA_MAX = 1.3
const COMPRESOR_TIEMPO_HINCHAR = 0.1
const COMPRESOR_TIEMPO_RECUPERAR = 0.2
const COMPRESOR_TIEMPO_CARGA = 5.0 
const COMPRESOR_VIBRACION = 0.05
const COMPRESOR_BRILLO_MAX = 10.0
const COMPRESOR_UI_OFFSET_Y = 1.5
const COMPRESOR_T2_TIEMPO_CARGA = 2.5

# --- FUSIONADOR ---
const MERGER_TIEMPO_PROCESO = 15.0 
const MERGER_COSTO_STABILITY = 100
const MERGER_COSTO_CHARGE = 200
const MERGER_ANIM_SQUASH = Vector3(1.1, 0.9, 1.1)
const MERGER_ANIM_BIRTH_SCALE = Vector3(2.5, 2.5, 2.5)
const MERGER_OFFSET_SALIDA = 1.5
const RECURSO_UP_QUARK = "Up-Quark"
const RECURSO_DOWN_QUARK = "Down-Quark"
const COLOR_UP_QUARK = Color(1, 1, 0)
const COLOR_DOWN_QUARK = Color(1, 0.5, 0)

# --- ELECTRONES (v0.5 – cadena quarks → electrón) ---
const RECURSO_ELECTRON = "Electron"
const COLOR_ELECTRON = Color(0.2, 0.85, 1.0)  # Cyan claro

# --- NUCLEONES: Protón (2U+1D) y Neutrón (1U+2D) ---
const RECURSO_PROTON = "Proton"
const RECURSO_NEUTRON = "Neutron"
const COLOR_PROTON = Color(0.9, 0.35, 0.35)   # Rojo suave
const COLOR_NEUTRON = Color(0.7, 0.7, 0.75)   # Gris neutro

# --- FABRICADOR HADRÓN (quarks → protón/neutrón) ---
const HADRON_COSTO_PROTON_UP = 2
const HADRON_COSTO_PROTON_DOWN = 1
const HADRON_COSTO_NEUTRON_UP = 1
const HADRON_COSTO_NEUTRON_DOWN = 2
const HADRON_TIEMPO_PROCESO = 12.0

# --- CONSTRUCTOR ---
const CONSTRUCTOR_RADIO = 1
const CONSTRUCTOR_AGUJERO = false
const COLOR_CONSTRUCTOR_BASE = Color(0.6, 0.6, 0.6)
const CONSTRUCTOR_ANIM_EAT_SCALE = Vector3(1.05, 0.95, 1.05) 
const CONSTRUCTOR_PROB_SIMULACION = 0.01      

# --- MÁQUINAS: VOID GENERATOR ---
const VOID_GEN_RADIO = 7
const VOID_GEN_TIEMPO_TILE = 2
const VOID_GEN_ALTURA_VISUAL = -0.45
const VOID_GEN_COLOR_AREA = Color(1.0, 0.0, 0.0, 0.071)
const VOID_GEN_COLOR_BORDE = Color(1.0, 0.0, 0.0, 0.294)
const VOID_GEN_BOX_SIZE = Vector3(0.9, 0.05, 0.9)
const VOID_GEN_VIBRACION_FUERZA = 0.04
const VOID_GEN_TIEMPO_DESTRUCCION = 0.4
const VOID_GEN_PERIMETRO_GROSOR = 0.03
const VOID_GEN_PERIMETRO_OFFSET_Y = 0.02
const VOID_GEN_PERIMETRO_BRILLO = 2.0
const VOID_GEN_FACTOR_RELLENO = 0.95
const VOID_GEN_FADE_MACHINE = 0.5
const VOID_GEN_FADE_TILES = 0.5
const VOID_GEN_WAVE_SPEED = 0.02

# --- SISTEMA DE CRAFTEO ---
const RECETAS = {
	"Prisma Recto": { 
		"inputs": { "Stability": 5, "Charge": 5 }, 
		"output_scene": "res://scenes/buildings/prism_straight.tscn", 
		"tiempo": 2.0 
	},
	"Prisma Angular": { 
		"inputs": { "Stability": 5, "Charge": 10 }, 
		"output_scene": "res://scenes/buildings/prism_angle.tscn", 
		"tiempo": 2.0 
	},
	"Sifón": { 
		"inputs": { "Stability": 15, "Charge": 5 }, 
		"output_scene": "res://scenes/buildings/siphon_t1.tscn", 
		"tiempo": 3.0 
	},
	"Prisma Recto T2": { 
		"inputs": { "Stability": 50, "Charge": 50 }, 
		"output_scene": "res://scenes/buildings/prism_straight_t2.tscn", 
		"tiempo": 4.0 
	},
	"Prisma Angular T2": { 
		"inputs": { "Stability": 50, "Charge": 50 }, 
		"output_scene": "res://scenes/buildings/prism_angle_t2.tscn", 
		"tiempo": 4.0 
	},
	"Sifón T2": { 
		"inputs": { "Compressed-Stability": 5, "Compressed-Charge": 5 }, 
		"output_scene": "res://scenes/buildings/siphon_t2.tscn", 
		"tiempo": 5.0 
	},
	"Void Generator": { 
		"inputs": { "Stability": 200, "Charge": 200 },  
		"output_scene": "res://scenes/buildings/void_generator.tscn",   
		"tiempo": 10.0 
	},
	"Compresor": { 
		"inputs": { "Stability": 150, "Charge": 150 }, 
		"output_scene": "res://scenes/buildings/compressor.tscn", 
		"tiempo": 8.0 
	},
	"Compresor T2": { 
		"inputs": { "Compressed-Stability": 20, "Compressed-Charge": 20 }, 
		"output_scene": "res://scenes/buildings/compressor_t2.tscn", 
		"tiempo": 12.0 
	},
	"Fusionador": { 
		"inputs": { "Compressed-Stability": 100, "Compressed-Charge": 100 }, 
		"output_scene": "res://scenes/buildings/merger.tscn", 
		"tiempo": 10.0 
	},
	"Constructor": { 
		"inputs": { "Up-Quark": 50, "Down-Quark": 50 }, 
		"output_scene": "res://scenes/buildings/constructor.tscn", 
		"tiempo": 30.0 
	},
	"Fabricador Hadrón": { 
		"inputs": { "Up-Quark": 40, "Down-Quark": 40 }, 
		"output_scene": "res://scenes/buildings/hadron_factory.tscn", 
		"tiempo": 15.0 
	}
}

# --- HUD: categorías y etiquetas cortas (fuente única = RECETAS) ---
## Orden de edificios por categoría en la barra inferior. Claves = nombres en RECETAS.
const HUD_CATEGORIAS = {
	"SIFONES": ["Sifón", "Sifón T2"],
	"PRISMAS": ["Prisma Recto", "Prisma Angular", "Prisma Recto T2", "Prisma Angular T2"],
	"MANIPULA": ["Compresor", "Compresor T2", "Fusionador", "Fabricador Hadrón", "Void Generator"],
	"CONSTR": ["Constructor"]
}
## Etiqueta corta para botón (si no existe, se usa el nombre de RECETA).
const HUD_LABELS = {
	"Sifón": "Sifón T1",
	"Sifón T2": "Sifón T2",
	"Prisma Recto": "Recto T1",
	"Prisma Angular": "Ang. T1",
	"Prisma Recto T2": "Recto T2",
	"Prisma Angular T2": "Ang. T2",
	"Compresor": "Compr. T1",
	"Compresor T2": "Compr. T2",
	"Fusionador": "Fusión",
	"Void Generator": "Void Gen",
	"Constructor": "Maker",
	"Fabricador Hadrón": "Hadrón"
}

# --- STARTER PACK (Nueva partida) ---
## Inventario inicial: desafiante pero jugable. Constructor necesario para craftear.
## God Siphon solo en modo DEV.
const STARTER_PACK = {
	"Sifón": 4,
	"Sifón T2": 0,
	"Prisma Recto": 8,
	"Prisma Angular": 4,
	"Prisma Recto T2": 0,
	"Prisma Angular T2": 0,
	"Compresor": 1,
	"Compresor T2": 0,
	"Fusionador": 0,
	"Constructor": 1,
	"GodSiphon": 0,
	"Void Generator": 0,
	"Electron": 0,
	"Fabricador Hadrón": 0,
	"Proton": 0,
	"Neutron": 0
}
