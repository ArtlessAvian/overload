

Decisions Made:
* Test Driven Development is used!
* Model and View are seperated.
	* Models are Nodes.
		* Models are heirarchical.
			* Models are aware of their child models.
			* Models are not aware of their parent models.
	* Views are placed anywhere.
		* No model is aware of their view.
* All models are runnable as their own scene.

* Blocks:
	* Blocks only handle static things and matching.
	* Static blocks are represented by a jagged array, even if there are floating blocks.
		* Enforcing a hard limit is arbitrary, and requires deletion of garbage.
		* Becoming jagged after a limit adds weird edge cases.
			* Code simplicity is more important than premature optimization.

	* The dimensions of the game do not change after initialization.
	* Needing to match more than 3 is unfun.

* Board:
	* Automates the Blocks and all its decorators.
	* Decorators:
		* Cursor
		* Mascot