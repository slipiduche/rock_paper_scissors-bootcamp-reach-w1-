'reach 0.1';
const [ishand, ROCK, PAPER, SCISSORS] = makeEnum(3)
const [isOutcome, B_WINS, DRAW, A_WINS] = makeEnum(3)
const winner = (handAlice, handBob) => (handAlice + (4 - handBob)) % 3 //!= 2 && (handAlice + (4 - handBob)) % 3 != 0 ? 2 : (handAlice + (4 - handBob)) % 3
assert(winner(ROCK, PAPER) == B_WINS)
assert(winner(SCISSORS, PAPER) == A_WINS)
assert(winner(PAPER, PAPER) == DRAW)
forall(
  UInt, handAlice =>
  forall(
    UInt, handBob => assert(isOutcome(winner(handAlice, handBob)))
  )
)
forall(
  UInt, hand =>
  assert(winner(hand, hand) == DRAW))

const Player = {
  ...hasRandom,
  getHand: Fun([], UInt),
  seeOutcome: Fun([UInt], Null),
  seeOutValue1: Fun([UInt], Null),
  seeOutValue2: Fun([UInt], Null),
};

export const main = Reach.App(() => {
  const Alice = Participant('Alice', {
    ...Player,
    wager: UInt,
  });
  const Bob = Participant('Bob', {
    ...Player,
    acceptWager: Fun([UInt], Null),
  });
  init();

  Alice.only(() => {
    const wager = declassify(interact.wager)
    const _handAlice = interact.getHand()
    const [_commitAlice, _saltAlice] = makeCommitment(interact, _handAlice)
    const commitAlice = declassify(_commitAlice)
  })
  Alice.publish(wager, commitAlice).pay(wager);
  commit()
  unknowable(Bob, Alice(_handAlice, _saltAlice))
  Bob.only(() => {
    interact.acceptWager(wager)
    const handBob = declassify(interact.getHand())
  })
  Bob.publish(handBob).pay(wager)
  commit()
  Alice.only(() => {
    const handAlice = declassify(_handAlice)
    const saltAlice = declassify(_saltAlice)
  })
  Alice.publish(handAlice, saltAlice)
  checkCommitment(commitAlice, saltAlice, handAlice)
  const outCome = (handAlice + (4 - handBob)) % 3
  const [forAlice, forBob] =
    outCome === 2 ? [2, 0] :
      outCome === 0 ? [0, 2] : [1, 1];
  transfer(forAlice * wager).to(Alice);
  transfer(forBob * wager).to(Bob);
  commit();
  each([Alice, Bob], () => {
    interact.seeOutcome(outCome)
    interact.seeOutValue1(forAlice * wager)
    interact.seeOutValue2(forBob * wager)
  })

})