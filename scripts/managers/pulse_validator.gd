extends Node

# =============================================================================
# SISTEMA DE VALIDACIÓN DE PULSOS
# =============================================================================
# Este sistema asegura que los pulsos de energía solo existan mientras
# el haz de luz que los creó sigue activo

var pulsos_activos = {}  # {pulse_id: sifon_owner}
var haces_activos = []   # Lista de sifones con haz activo

func registrar_haz_activo(sifon):
	if not haces_activos.has(sifon):
		haces_activos.append(sifon)

func desregistrar_haz_activo(sifon):
	haces_activos.erase(sifon)
	_limpiar_pulsos_de_sifon(sifon)

func registrar_pulso(pulso, sifon_dueno):
	pulsos_activos[pulso.get_instance_id()] = sifon_dueno

func validar_pulso(pulso) -> bool:
	var id = pulso.get_instance_id()
	if not pulsos_activos.has(id):
		return false
	
	var sifon = pulsos_activos[id]
	return haces_activos.has(sifon)

func _limpiar_pulsos_de_sifon(sifon):
	for pulso_id in pulsos_activos.keys():
		if pulsos_activos[pulso_id] == sifon:
			var pulso = instance_from_id(pulso_id)
			if pulso and is_instance_valid(pulso):
				pulso.queue_free()
			pulsos_activos.erase(pulso_id)
