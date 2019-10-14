extends Board
class_name BoardDefaultView

var _view : Node2D;

func _ready() -> void:
	self._view = load("res://board/BoardView.tscn").instance();
	self.add_child(self._view);
	self._view.model_path = self.get_path();
	print(self._view.model_path)
	self._view.get_node("DynamicBlocksViewDebug").model_path = self._dynamic_blocks.get_path()
	self._view.get_node("CursorViewDebug").model_path = self._cursor.get_path()

	self._dynamic_blocks.connect("new_exploder", _view.get_node("DynamicBlocksViewDebug"), "new_exploder");
	self._dynamic_blocks.connect("new_faller", _view.get_node("DynamicBlocksViewDebug"), "new_faller");