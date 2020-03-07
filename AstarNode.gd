class_name AstarNode
   
var id
var pos : Vector2
var isWall : bool
var visited : bool
var neighbours
var parent
var cost
var heuristic

func _init(_id, _x, _y):
	self.id = _id
	self.pos = Vector2(_x, _y)
	self.visited = false
	self.isWall = false
	self.parent = null
	self.neighbours = []
	
	self.cost = INF
	self.heuristic = INF

func _to_string():
	return "[id:"+str(self.id)+",("+str(pos.x)+", "+str(pos.y)+"),("+str(cost)+", "+str(heuristic)+")]"

func reset():
	self.visited = false
	self.parent = null
	self.cost = INF
	self.heuristic = INF

func distTo(other):
	return sqrt(pow(self.pos.x - other.pos.x,2) + pow(self.pos.y - other.pos.y,2))
	   
func calcHeuristic(other):
	self.heuristic = self.cost + self.distTo(other)
