
class Rotor():
    ''' A class that represents a rotor, that cycles from the numbers 1 to 25. '''
    _rotor_position = 0
    _offset = 0

    def __str__(self) -> str:
        """
        Returns the rotor's initial position, and its current offset.
        :return: The rotor's initial position, and its current offset.
        """
        NEWLINE: str = "\n"
        result: str = ""

        result += "Current Position: " + str(self._rotor_position + self._offset) + NEWLINE
        result += "Initial Position: " + str(self._rotor_position) + NEWLINE
        result += "Offset:           " + str(self._offset) + NEWLINE

        return result

    def increment_position(self):
        """
        Increments the position of the rotor.
        :return:
        """
        # increment offset
        self._offset += 1

        # check if need to do rotation, that is, offset + initial position = 26
        if (self._offset + self._rotor_position) == 26:
            self._offset = -self._rotor_position

    def get_current_offset(self) -> int:
        """
        Returns the current offset of the rotor.
        :return: The current offset of the rotor.
        """
        return (self._rotor_position + self._offset)

    def __init__(self, n: int):
        """
        Initializes the rotor's starting position.

        PRECONDITION: n in [0, 25].
        :return: The rotor object.
        """
        self._rotor_position = n





if (__name__ == "__main__"):
    my_rotor = Rotor(25)
    print(my_rotor)

    print(my_rotor.get_current_offset())
    my_rotor.increment_position()
    print(my_rotor)