# 🌟 Exercise 1: Random Sentence Generator
# Instructions:

# Download the provided word list and save it in your development directory.
# Create a function to read the words from the file.
# Create a function to generate a random sentence of a given length.
# Create a main function to handle user input and program flow.


# Step 1: Create the get_words_from_file function

# Create a function named get_words_from_file that takes the file path as an argument.
# Open the file in read mode ("r").
# Read the file content.
# Split the content into a list of words.
# Return the list of words.


# Step 2: Create the get_random_sentence function

# Create a function named get_random_sentence that takes the sentence length as an argument.
# Call get_words_from_file to get the list of words.
# Select a random word from the list length times.
# Create a sentence with the selected words.
# Convert the sentence to lowercase.
# Return the sentence.


# Step 3: Create the main function

# Create a function named main.
# Print a message explaining the program’s purpose.
# Ask the user for the desired sentence length.
# Validate the user input:
# Check if it is an integer.
# Check if it is between 2 and 20 (inclusive).
# If the input is invalid, print an error message and exit.
# If the input is valid, call get_random_sentence with the length and print the generated sentence.





import random


def get_words_from_file(file_path):
    with open(file_path, "r") as file:
        content = file.read()
        words = content.split()

    return words


def get_random_sentence(length):
    words = get_words_from_file("words.txt")

    random_words = []

    for i in range(length):
        random_word = random.choice(words)
        random_words.append(random_word)

    sentence = " ".join(random_words)

    return sentence.lower()


def main():
    print("This program generates a random sentence.")
    print("Choose a sentence length between 2 and 20.")

    try:
        length = int(input("Enter the sentence length: "))

        if length < 2 or length > 20:
            print("Error: the length must be between 2 and 20.")
            return

        sentence = get_random_sentence(length)
        print("Random sentence:")
        print(sentence)

    except ValueError:
        print("Error: please enter an integer.")


main()

#  Exercise 2: Working with JSON
# Goal: Access a nested key in a JSON string, add a new key, and save the modified JSON to a file.

# Instructions:

# Using the follow code:

# import json
# sampleJson = """{ 
#    "company":{ 
#       "employee":{ 
#          "name":"emma",
#          "payable":{ 
#             "salary":7000,
#             "bonus":800
#          }
#       }
#    }
# }"


# Access the nested “salary” key.
# Add a new key “birth_date” wich value is of format “YYYY-MM-DD”, to the “employee” dictionary: "birth_date": "YYYY-MM-DD".
# Save the modified JSON to a file.


# Step 1: Load the JSON string

# Import the json module.
# Use json.loads() to parse the JSON string into a Python dictionary.


# Step 2: Access the nested “salary” key

# Access the “salary” key using nested dictionary access (e.g., data["company"]["employee"]["payable"]["salary"]).
# Print the value of the “salary” key.


# Step 3: Add the “birth_date” key

# Add a new key-value pair to the “employee” dictionary: "birth_date": "YYYY-MM-DD".
# Replace "YYYY-MM-DD" with an actual date.


# Step 4: Save the JSON to a file

# Open a file in write mode ("w").
# Use json.dump() to write the modified dictionary to the file in JSON format.
# Use the indent parameter to make the JSON file more readable.









import json


sampleJson = """
{
    "company": {
        "employee": {
            "name": "emma",
            "payable": {
                "salary": 7000,
                "bonus": 800
            }
        }
    }
}
"""


# Convert JSON string into a Python dictionary
data = json.loads(sampleJson)


# Access the salary
salary = data["company"]["employee"]["payable"]["salary"]

print("Salary:", salary)


# Add birth_date to employee
data["company"]["employee"]["birth_date"] = "1995-04-18"


# Save modified data to a JSON file
with open("employee_data.json", "w") as file:
    json.dump(data, file, indent=4)


print("JSON file saved successfully.")