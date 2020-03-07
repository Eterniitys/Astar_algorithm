extends Node2D

var use_diagonale = false
var draw_path = true

var NB_ROW = 50
var NB_COL = 50

var nodes = Array()

var rect_size := Vector2(10, 10)
var dist_between_rect = 1
var vdist_between_rect = Vector2(dist_between_rect, dist_between_rect)

var global_width = 400
var global_height = 400

var start_node : AstarNode
var end_node : AstarNode

func _ready():
	# initialisation
	for x in range(NB_ROW):
		for y in range(NB_COL):
			nodes.append(AstarNode.new(y+x*NB_ROW, x, y))
	
	start_node = nodes[NB_ROW/2 + 4*NB_COL]
	end_node = nodes[NB_ROW/2 + NB_COL*(NB_COL-5)]
	
	# initialisation des voisin
	initNodesNeighbours();
	Astar()

func _process(delta):
	global_width = self.get_viewport().size[0]
	global_height = self.get_viewport().size[1]
	var mouse_pos = get_global_mouse_position()

	if Input.is_action_just_released("mouse_left"):
		var x = int(mouse_pos.x / (rect_size.x+dist_between_rect))
		var y = int(mouse_pos.y / (rect_size.y+dist_between_rect))
		if x < NB_COL and y < NB_ROW:
			if Input.is_action_pressed("ui_shift"):
				start_node = nodes[y+x*NB_ROW]
			elif Input.is_action_pressed("ui_ctrl"):
				end_node = nodes[y+x*NB_ROW]
			else:
				nodes[y+x*NB_ROW].isWall = !nodes[y+x*NB_ROW].isWall
			if nodes[y+x*NB_ROW] == end_node:
				nodes[y+x*NB_ROW].isWall = false
			Astar()
	if Input.is_action_just_pressed("ui_space"): # espace
		if Input.is_action_pressed("ui_ctrl"):
			use_diagonale = !use_diagonale
			initNodesNeighbours()
		else:
			draw_path = !draw_path
		Astar()
	
	update()

func _draw():
	# fond noir
	draw_rect(Rect2(0, 0, global_width, global_height), Color.black)
	# dessin des chemins
	if dist_between_rect >= 5:
		for node in nodes:
			for n in node.neighbours:
				if n.pos >= node.pos:
					var parent_center = node.pos * (rect_size + vdist_between_rect) + (rect_size + vdist_between_rect)/2
					var center = n.pos * (rect_size + vdist_between_rect) + (rect_size + vdist_between_rect)/2
					draw_line(parent_center, center, Color.blue, 1)
	
	# dessin d'une node
	for n in nodes:
		var color = Color.darkblue if n.visited else Color.bisque if n.isWall else Color.blue
		if n == start_node:
			color = Color.yellow
			var pos = n.pos*(rect_size + vdist_between_rect) + (rect_size + vdist_between_rect)/2
			draw_circle(pos , rect_size.x/2, color)
		elif n == end_node:
			color = Color.chocolate
			var pos = n.pos*(rect_size + vdist_between_rect) + (rect_size + vdist_between_rect)/2
			draw_circle(pos, rect_size.x/2, color)
		else:
			draw_rect(Rect2(Vector2(
				n.pos.x * (rect_size.x+dist_between_rect) + dist_between_rect/2,
				n.pos.y * (rect_size.y+dist_between_rect) + dist_between_rect/2), rect_size),
				color)
	
	# chemin le plus court
	var p = end_node
	while (draw_path and p.parent != null):
		var parent_center = p.parent.pos*(rect_size + vdist_between_rect) + (rect_size+vdist_between_rect)/2
		var center = p.pos*(rect_size+ vdist_between_rect) + (rect_size+vdist_between_rect)/2
		draw_line(parent_center, center, Color.yellow, 2)
		p = p.parent

func Astar():
	var lst = PQueue.new()
	# Mise a zéro de toutes les nodes
	for n in nodes:
		n.reset()
		n.calcHeuristic(end_node)
	#setup de la node de départ
	start_node.cost = 0
	start_node.calcHeuristic(end_node)
	lst.insert(start_node)
	var exploring_node
	var cmp = 0
	
	while (!lst.empty() and exploring_node != end_node):
		exploring_node = lst.pop()
		while exploring_node and exploring_node.visited:
			exploring_node = lst.pop()
		if !exploring_node:
			break
		cmp+=1
		exploring_node.visited = true
		for n in exploring_node.neighbours:
			if !n.visited and !n.isWall:
				# calcule du cout du voisin
				var vdist_between_rect = exploring_node.cost + exploring_node.distTo(n)
				# cout calculer inférieur au coup actuel
				if (vdist_between_rect < n.cost):
					n.parent = exploring_node
					n.cost = vdist_between_rect
					n.calcHeuristic(end_node)
				# ajout a la liste
				lst.insert(n)
	print("Nombre de nodes explorée: ",cmp)

func initNodesNeighbours():
	for x in range(NB_ROW):
		for y in range(NB_COL):
			nodes[y + x*NB_ROW].neighbours = []
			if x != 0:
				nodes[y + x*NB_ROW].neighbours.append(nodes[y + (x-1) * NB_ROW]) # voisin nord
			if x != NB_COL - 1:
				nodes[y + x*NB_ROW].neighbours.append(nodes[y + (x+1) * NB_ROW]) # voisin sud
			if y != 0:
				nodes[y + x*NB_ROW].neighbours.append(nodes[y-1 + x * NB_ROW]) # voisin droit
			if y != NB_ROW - 1:
				nodes[y + x*NB_ROW].neighbours.append(nodes[y+1 + x * NB_ROW]) # voisin gauche
			# diagonalement
			if use_diagonale :
				if x != 0 && y != 0:
					nodes[y + x*NB_ROW].neighbours.append(nodes[y-1 + (x-1) * NB_ROW]) # voisin haut-gauche
				if x != 0 && y != NB_ROW - 1:
					nodes[y + x*NB_ROW].neighbours.append(nodes[y+1 + (x-1) * NB_ROW]) # voisin bas-gauche
				if y != 0 && x != NB_COL - 1:
					nodes[y + x*NB_ROW].neighbours.append(nodes[y-1 + (x+1) * NB_ROW]) # voisin haut-gauche
				if y != NB_ROW - 1 && x != NB_COL - 1:
					nodes[y + x*NB_ROW].neighbours.append(nodes[y+1 + (x+1) * NB_ROW]) # voisin haut-gauche
