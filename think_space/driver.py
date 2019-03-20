from letter_rotor import LetterRotor

class Driver():
    @staticmethod
    def main():
        PREFIX: str = "ABC"
        translated_prefix: str

        initial_rotor_posn: int
        user_message: str

        encrypted_message: str = ""

        initial_rotor_posn = int(input("Desired rotor position: "))
        l_rotor: LetterRotor = LetterRotor(initial_rotor_posn)

        user_message = input("Message:")

        encrypted_message += Driver.send_message_to_rotor(PREFIX, l_rotor)
        encrypted_message += Driver.send_message_to_rotor(encrypted_message, l_rotor)

        print("\n\nYour encrypted message is:\n", encrypted_message)

    @staticmethod
    def send_message_to_rotor(message: str, letter_rotor: LetterRotor) -> str:
        '''
        :param message: The message to send to encrypt.
        :param rotor_posn: The desired initial position of the rotor.

        PRECONDITION: rotor_posn must be in range(0, 26).
        :return: The encrypted message.
        '''
        result: str = ""

        # encrypt result, letter by letter.
        for i in range(0, len(message)):
            result += letter_rotor.get_letter(message[i])

        return result

if (__name__ == "__main__"):
    Driver.main()