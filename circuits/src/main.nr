use dep::std;
global PIECES_COUNT = 4;

fn main(
    solnA: u4,
    solnB: u4,
    solnC: u4,
    solnD: u4,
    salt: u32, //salt to avoid brute force attacks?
    guessA: pub u4,
    guessB: pub u4,
    guessC: pub u4,
    guessD: pub u4,
    solnHash: pub Field //hash that the prover commits to
) 
-> pub [u4; 2] 
{
    let mut guess = [guessA, guessB, guessC, guessD];
    let mut solution = [solnA, solnB, solnC, solnD];

    // TODO: Validate inputs. 4 colors | 1-4

    // Calculate white and black clues
    let (numBlacks, numWhites) = calculate_hits(solution, guess);

    // Constrain calculated hash vs solnHash
    let calculatedHash = std::hash::pedersen([salt as Field, solnA as Field, solnB as Field, solnC as Field, solnD as Field])[0];
    constrain calculatedHash == solnHash; // This ensures the prover does not change solution array between games

    // return clues
    [numBlacks, numWhites]
}

fn calculate_hits(solution: [u4;4], guess:[u4;4] ) -> (u4, u4) {
    let mut exact_matches = 0; // count of exact matches
    let mut color_matches = 0; // count of color matches

    let mut solution_colors = [false; 4]; // flags for solution array
    let mut guess_colors = [false; 4]; // flags for guess array

    // check for exact matches
    for i in 0..4 {
        if (solution[i] == guess[i]) {
            exact_matches =  exact_matches + 1;
            solution_colors[i] = true; // mark position as matched
            guess_colors[i] = true;
        }
    }

    // check for color matches
    for i in 0..4 {
        for j in 0..4 {
            if (!solution_colors[i] & !guess_colors[j] & (solution[i] == guess[j])) {
                color_matches = color_matches + 1;
                solution_colors[i] = true; // mark position as matched
                guess_colors[j] = true;
            }
        }
    }

    (exact_matches, color_matches)
}