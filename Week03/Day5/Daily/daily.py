import string
import re


class Text:
    def __init__(self, text):
        self.text = text

    def word_frequency(self, word):
        words = self.text.split()
        count = words.count(word)

        if count == 0:
            return None

        return count

    def most_common_word(self):
        words = self.text.split()

        frequencies = {}

        for word in words:
            if word in frequencies:
                frequencies[word] += 1
            else:
                frequencies[word] = 1

        most_common = max(frequencies, key=frequencies.get)

        return most_common

    def unique_words(self):
        words = self.text.split()

        unique = set(words)

        return list(unique)

    @classmethod
    def from_file(cls, file_path):
        with open(file_path, "r") as file:
            content = file.read()

        return cls(content)


class TextModification(Text):

    def remove_punctuation(self):
        cleaned_text = ""

        for character in self.text:
            if character not in string.punctuation:
                cleaned_text += character

        return cleaned_text

    def remove_stop_words(self):
        stop_words = {
            "a", "an", "the", "is", "are", "was", "were",
            "in", "on", "at", "to", "of", "for", "with",
            "and", "or", "but", "this", "that", "it",
            "he", "she", "they", "we", "you", "i"
        }

        words = self.text.split()

        filtered_words = []

        for word in words:
            if word.lower() not in stop_words:
                filtered_words.append(word)

        return " ".join(filtered_words)

    def remove_special_characters(self):
        cleaned_text = re.sub(r"[^a-zA-Z0-9\s]", "", self.text)

        return cleaned_text


# -------------------------
# TESTS
# -------------------------

sample_text = "Python is great. Python is easy, and Python is useful!"

text = Text(sample_text)

print("Python frequency:", text.word_frequency("Python"))
print("Most common word:", text.most_common_word())
print("Unique words:", text.unique_words())


modified_text = TextModification(sample_text)

print("Without punctuation:")
print(modified_text.remove_punctuation())

print("Without stop words:")
print(modified_text.remove_stop_words())

print("Without special characters:")
print(modified_text.remove_special_characters())