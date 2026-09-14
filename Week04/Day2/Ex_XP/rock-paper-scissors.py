from game import Game


def get_user_menu_choice():

    print("\n--- ROCK PAPER SCISSORS ---")
    print("1. Play a new game")
    print("2. Show scores")
    print("q. Quit")

    choice = input("Select an option: ").lower().strip()

    if choice in ["1", "2", "q"]:
        return choice

    print("Invalid menu choice.")
    return None


def print_results(results):

    print("\n--- GAME RESULTS ---")

    print(f"Wins: {results['win']}")
    print(f"Losses: {results['loss']}")
    print(f"Draws: {results['draw']}")

    total_games = (
        results["win"]
        + results["loss"]
        + results["draw"]
    )

    print(f"Total games: {total_games}")

    print("\nThank you for playing!")


def main():

    results = {
        "win": 0,
        "loss": 0,
        "draw": 0
    }

    while True:

        choice = get_user_menu_choice()

        if choice == "1":

            game = Game()

            result = game.play()

            results[result] += 1


        elif choice == "2":

            print_results(results)


        elif choice == "q":

            print_results(results)

            break


if __name__ == "__main__":
    main()