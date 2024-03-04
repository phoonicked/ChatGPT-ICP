import Text "mo:base/Text";
import Random "mo:base/Random";
import Debug "mo:base/Debug";

actor Casino{
  type Wager = { user: Text; choice: Text};
  var wallet = 100;

  public func placeWager(user: Text, choice: Text) : async Text {
    if(wallet <= 0){
      return "Insufficient funds in wallet";
    };
    if(choice != "Heads" and choice != "Tails") {
      return "Invalid choice. Please choose either 'Heads' or 'Tails'.";
    };
    wallet := wallet - 10; // Deduct wager amount (10 ICP)
    let result = await compareDecision(choice);
    if (result == "Congratulations. You won!") {
      wallet := wallet + 20; // Reward 20 ICP on win (double the wager)
      return "Congratulations! You won 20 ICP.";
    } else {
      return "Sorry, you lost. Try again!";
    }
  };

  public func compareDecision(userInput: Text) : async Text {
    let computerInput = await randomComputerInput();
    let winningMessage = "Congratulations. You won!";
    let losingMessage = "Womp Womp. You lost!";
    if(userInput == computerInput){
      return winningMessage;
    } else {
      return losingMessage;
    }
  };

  private func randomComputerInput() : async Text {
    let random = Random.Finite(await Random.blob());
    if (random.coin() == ?true) {
      return "Heads";
    } else {
      return "Tails";
    }
  };

  public func getWalletBalance() : async Nat {
    return wallet;
  };
};