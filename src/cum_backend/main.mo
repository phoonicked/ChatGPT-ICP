import Text "mo:base/Text";
import Random "mo:base/Random";
import Debug "mo:base/Debug";

actor{
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
};