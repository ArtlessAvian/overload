Terminology:
* Blocks can be swapped or raised.

Decisions Made:
* Test Driven Development is used!

* Model and View are separated.
	* Models are Scripts, not Scenes.
		* Models need initialization.
		* Models are heirarchical.
			* Models can instance other Models as its children.
			* Models are aware of their child models (and grandchild models).
			* Models are not aware of their parent models.
			* Benefit: Model is traversable through get_node()
			* Consequence: Models interact with parents through signals, and parents have to subscribe to their children.
		* (Models are technically runnable as their own scene.)
			* Models have no view or controller.
			* Testing is better done in tests.
	* Views are Scenes.
		* Views do not need initialization.
		* Views can be edited in editor.
		* No model is aware of their view.
			* Benefit: Views can be placed anywhere in the SceneTree.
			* Benefit: Models can be decorated arbitrarily.
		* Views are runnable as their own scene
			* Benefit: Independent testing!

* Blocks / DynamicBlocks:
	* "Blocks" only handles static blocks and matching.
	* Static blocks are represented by a jagged array, even if there are floating blocks.
		* Enforcing a hard limit is arbitrary, and requires deletion of garbage.
		* Becoming jagged after a limit adds weird edge cases.
	* The dimensions of the game do not change after initialization.
	* Needing to match more than 3 is probably unfun.
	* Both "Blocks" avoids time.
		* _physics_process is a small exception.
		* "Blocks" does everything (mostly) instantly.
		* DynamicBlocks hands responsibility to Exploders and Fallers to keep track of time.

* Board:
	* Automates the Blocks.
	* Minimum Playable Unit
	* Decorators:
		* Cursor
		* Mascot