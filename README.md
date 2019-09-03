

Decisions Made:
* Needing to match more than 3 is unfun.
* Static blocks are represented by a jagged array, even if there are floating blocks.
	* Enforcing a hard limit is arbitrary, and requires deletion of garbage.
	* Becoming jagged after a limit adds weird edge cases.
		* Code simplicity is more important than premature optimization.