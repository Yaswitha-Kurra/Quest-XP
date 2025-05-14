const { JsonRpcProvider, Wallet, Contract } = require("quais");
const QuestControllerJson = require("../artifacts/contracts/QuestController.sol/QuestController.json");
require("dotenv").config();

const provider = new JsonRpcProvider(process.env.RPC_URL);
const wallet = new Wallet(process.env.CYPRUS1_PK, provider);

const contract = new Contract(
  "0x006E344eDAC65573e1104833164bb70101c94560", // QuestController address
  QuestControllerJson.abi,
  wallet
);

async function main() {
  const tx = await contract.addQuest(
    "Play RPS four",
    "0x007BBeb0A3D667Eebf5a9D72be7db90c10268E5d", // Verifier
    50
  );
  await tx.wait();
  console.log("✅ Quest added");
}

main();