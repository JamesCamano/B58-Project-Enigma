from rotor import Rotor

class LetterRotor():
    """
    A class to represent a simplified version of the Enigma
    letter rotor.
    """
    _start_letter = "A"
    _numeric_rotor: Rotor

    def increment(self):
        """
        Increments the rotor position.
        """
        self._numeric_rotor.increment_position()

    def get_letter(self, c: str) -> str:
        """
        Takes a character c and translates it according to the position of self.

        PRECONDITION: c is a lowercase alpha character. (i.e. |c| = 1, and c in [a, z]))

        :return: c, translated.
        """
        RESTART_POSN = ord('a')
        OVERFLOW_POSN = ord('z')

        # get shift number - this is the current offset of the numeric rotor
        shift_number: int = self._numeric_rotor.get_current_offset()

        # add to shift_number the character position of c
        untrimmed_char_posn: int = ord(c)+shift_number

        # check if we have overflow.
        if untrimmed_char_posn > OVERFLOW_POSN:
            untrimmed_char_posn -= OVERFLOW_POSN
            untrimmed_char_posn -= 1 # subtract 1, since want "a" if untrimmed_char_posn = ord("z") + 1
                                     # if not, then will get "b"
            untrimmed_char_posn += RESTART_POSN # reset to starting position

        trimmed_char_posn: int = untrimmed_char_posn

        return chr(trimmed_char_posn)

    def __init__(self, initial_posn: int = 0):
        """
        Initializes the letter rotor, with the desired initial position.
        PRECONDITION: initial_posn in [0, 25]
        """
        self._numeric_rotor = Rotor(initial_posn)


if (__name__ == "__main__"):
    letter_rotor = LetterRotor(10)

    for z in range(26+1):
        print(letter_rotor.get_letter("z"))
        letter_rotor.increment()

