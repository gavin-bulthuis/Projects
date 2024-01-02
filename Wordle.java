// Gavin Bulthuis bulth019 and Saxon Rudduck ruddu004
import java.io.FileWriter;
import java.io.BufferedReader;
import java.io.FileReader;
import java.util.Scanner;
import java.util.Random;
import java.io.*;
import java.io.IOException;

public class Wordle {
    private String fileName;
    private String wordsUsed = "history.txt";
    private int selectedWordsCount = 0;
    private String[] selectedWords = new String[5000];
    private static  String green = "\u001B[42m";
    private static String yellow = "\u001B[43m";
    private static String white = "";
    private static String black = "\u001B[47m";
    private static String black_text = "\u001B[30m";
    private static String reset = "\u001B[0m";
    private static String[] letters = {"a","b","c","d","e","f","g","h", "i", "j", "k", "l" ,"m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"};
    private static String[] colors = new String[26];
    private String history  = "";
   
   public Wordle() {
        for (int i = 0; i < 26; i++) {
            colors[i] = white;
        }
   }
    // Method that chooses the Wordle word
    public String chooseWord(String filename) throws IOException {
        String [] words = readWordList(filename); // read in the words from file
        String randomWord = chooseRandomWord(words); // find the random word to use
        while (isWordSelected(randomWord)) { // check if the word has been selected already
            randomWord = chooseRandomWord(words);
        }
        addSelectedWord(randomWord);
        writeSelectedWords(); // write the words to file
        return randomWord; 
    }

    // Method that reads in the word list
    private String[] readWordList(String filename) throws IOException {
        String[] wordList = new String[5000]; // create array
        BufferedReader reader = new BufferedReader(new FileReader(filename));
        String line = reader.readLine(); // read lines
        int count = 0; // create counter variable to track index
        while (line != null) { 
            wordList[count] = line; // assign words to word list at indices
            count++; // increment the count
            line = reader.readLine();
        }
        reader.close();
        return wordList;
    }

    // Method that chooses the random word
    private String chooseRandomWord(String[] wordList) {
        Random random = new Random(); // create random object
        String word = null;
        while (word == null) { 
            int index = random.nextInt(wordList.length); // take a random index to take a word from
            word = wordList[index]; // assign word to the word associated with the random index
        }
        return word;
    }

    // Method to check if the word has already been chosen
    private boolean isWordSelected(String word) {
        for (int i = 0; i < selectedWordsCount; i++) {
            if (selectedWords[i].equals(word)) { //check if the random word has been selected by comparing it with all words in the selected words array
                return true;
            }
        }
        return false;
    }

    // Method to check for duplicate letter in word
    private boolean duplicateLetters(String newWord)  {
        for (int i = 0; i < newWord.length(); i++) { 
           for (int j = i + 1; j < newWord.length(); j++) {
                if ((newWord.charAt(i) == newWord.charAt(j))) { // check if the character at the indexes equal each other
                    return true;
                }
           }
        }
        return false;
    }

    // Method to add the selected word to the history file
    private void addSelectedWord(String word) {
        selectedWords[selectedWordsCount++] = word; // add the word to selected words array
    }

    // Method that writes the words to the history file
    private void writeSelectedWords() throws IOException {
        PrintWriter writer = new PrintWriter(new FileWriter(wordsUsed, true));
        for (int i = 0; i < selectedWordsCount; i++) {
            writer.println(selectedWords[i]); // print the selected words into the file
        }
        writer.close();
    }

    // Play the game
    public static boolean guessWord(String selectedWord) {
        int numGuesses = 6;
        String[] guesses = new String[numGuesses];
        Scanner scanner = new Scanner(System.in); // scan input

        while (numGuesses > 0) {
            System.out.println("Guess the word (you have " + numGuesses + " chances):"); // print statement telling user to guess and showing guesses remaining
            String guess = scanner.nextLine();
            if (guess.length() != selectedWord.length()) {
                System.out.println("Invalid guess. Enter a 5 letter word");
            }
            
            else if (guess.equalsIgnoreCase(selectedWord)) { // check if entered word is the selected word
                System.out.println("You win.");
                return true;
            } else {
                numGuesses--; // subtract a guess
                guesses[guesses.length - numGuesses - 1] = guess;
                System.out.println("Incorrect. Here is the status of your guess: ");
                for (int i = 0; i < selectedWord.length(); i++) { // loop through the characters of word
                    char c = guess.charAt(i); // find letter
                    if (selectedWord.length() > i && selectedWord.charAt(i) == c) { // check if it is in the correct spot
                        System.out.print(green + c + reset);
                    }
                    else if (selectedWord.contains(String.valueOf(c))) { // check if it is in the word
                        System.out.print(yellow + c + reset);
                    }
                    else {
                        System.out.print(white + c + reset); // return a gray value 
                    }
                }
            }
        
            System.out.println();

            System.out.println("Previous guesses: ");
    
            for (int i = 0; i < guesses.length; i++) { // print out the previous guesses
                if (guesses[i] != null) {
                    System.out.println();
                    for (int j = 0; j < selectedWord.length(); j++) { // loop through the characters of word
                    char c = guesses[i].charAt(j);  // find letter
                    if (selectedWord.length() > j && selectedWord.charAt(j) == c) { // check if it is in the correct spot
                        System.out.print(green + c + reset);
                    }
                    else if (selectedWord.contains(String.valueOf(c))) { // check if it is in the word
                        System.out.print(yellow + c + reset);
                    }
                    else {
                        System.out.print(white + c + reset); // return a gray value 
                    }
                }
                
            }
            }
            
            System.out.println();
            
            for (int n = 0; n < guess.length(); n++) {
                if (guess.charAt(n) == selectedWord.charAt(n)) {
                    colors[guess.charAt(n) - 'a'] = green;
                }
                else if (guess.charAt(n) != selectedWord.charAt(n)) {
                    colors[guess.charAt(n) - 'a'] = white;
                }
                else {
                    for (int w = 0; w < guess.length(); w++) {
                        char c1 = guess.charAt(w);
                        for (int x = 0; x < guess.length(); x++) {
                            char c2 = selectedWord.charAt(x);
                            if (c1 == c2) {
                                colors[guess.charAt(n) - 'a'] = yellow;
                            }
                        }
                    }
                }
            
            }
            for (int y = 0; y < letters.length; y++) {
                System.out.print(colors[y] + letters[y] + reset + " "); // prints out alphabet
            }
            System.out.println();
    }
            scanner.close();
            System.out.println("The word was: " + selectedWord);
            return false;
    }


    public static void main(String[] args) throws Exception {
        Wordle wordle = new Wordle();
        String selectedWord;
        try {
            selectedWord = wordle.chooseWord("wordchoices.txt");
            //System.out.println("Selected random word: " + selectedWord);
            guessWord(selectedWord);
        } catch (IOException e) {

        }
    }
}

