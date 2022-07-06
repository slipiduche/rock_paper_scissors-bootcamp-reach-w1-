'reach 0.1';

const Player = {
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
    const handAlice = declassify(interact.getHand())
  })
  Alice.publish(wager, handAlice).pay(wager);
  commit()

  Bob.only(() => {
    interact.acceptWager(wager)
    const handBob = declassify(interact.getHand())
  })
  Bob.publish(handBob).pay(wager)


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