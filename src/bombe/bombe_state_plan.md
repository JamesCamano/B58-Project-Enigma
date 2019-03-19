# States for the Bombe Machine

This document contains information relating to the states of the Bombe machine - detailing how it will "implement" the algorithm discussed in the documentation.

***

## Stage Outline
### Stage 1: Loading
* **Load** s0, s1, and s2 encrypted letters into their holder registers (call these registers S0, S1, and S2).
  * This loading should occupy multiple states
* **Initialize the Rotor** to  0 (we could start at any state, but 0 is natural).


### Stage 2: Lexicographic Arithmetic
  * Send the values of S0, S1 and S2, along with the current rotor value into a **numero-lexicographic shifter** (3 of them: one for each register.)
  * Call these shifted letter values s0', s1' and s2'.

### Stage 3: Comparison
  * Send s0', s1' and s2' to a **lexicographic equality** comparator circuit (again, 3 for each letter), along with the values for "A", "B" and "C", respectively.

  * Call the result of these comparisons F1, F2, and F3 - respectively.

### Stage 4a: Comparative Failure
  * Comparative failure occurs when `F1 ^ F2 ^ F3 == 0`.
  * If `rotor_value < 25`, then incrment `rotor_value` and **restart** from Stage 2.

  * else, set `rotor_value = 11111` and head to Stage 5.

### Stage 4b: Comparative Success
  * Comparative success occurs when `F1 ^ F2 ^ F3 == 1`.

  * head to Stage 5.

### Stage 5: Result
  * Output `rotor_value` and remain in this state until user restarts.

  * If user restarts, head to Stage 1.
***
## Tasks
- [ ] Write a general outline
- [ ] Create "true" FSM to model the above outline.
- [ ] Create circuits that realize the functionality of the Bombe circuit.
- [ ] Implement FSM in control circuit
