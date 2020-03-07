
class_name PQueue

var queue

func _init():
	self.queue = Array()

func _to_string():
	var ch = "["
	for i in range(self.queue.size()-1):
		ch += self.queue[i]._to_string() + ","
	ch += self.queue[len(self.queue)-1]._to_string() + "]"
	return ch

func pop():
	return self.queue.pop_front()

func insert(node : AstarNode):
	var i = 0;
	while(i < self.queue.size() and node.heuristic >= self.queue[i].heuristic):
		i += 1
	self.queue.insert(i, node)

func empty():
	return self.queue.empty()
