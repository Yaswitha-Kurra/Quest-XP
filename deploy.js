const quais = require("quais");
require("dotenv").config();

const MyTokenJson = require("../artifacts/contracts/MyToken.sol/MyToken.json");

async function linkVerifierToRPS() {
  const provider = new quais.JsonRpcProvider(process.env.RPC_URL);
  const wallet = new quais.Wallet(process.env.CYPRUS1_PK, provider);

  // Existing deployed addresses
  const rpsAddress = "0x004f6Da6CA6A85890441e483EAf2f076B1b75021";
  const verifierAddress = "0x006BD70680a575Da3eD76A2b09311689ABC3dFbD";

  // Attach to deployed RPS contract
  const rps = new quais.Contract(rpsAddress, MyTokenJson.abi, wallet);

  // Call setVerifier
  const tx = await rps.setVerifier(verifierAddress);
  console.log("🚀 setVerifier transaction sent:", tx.hash);
  await tx.wait();

  console.log("✅ Verifier address set in RPS contract.");
}

linkVerifierToRPS()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error("❌ Failed to link verifier:", err);
    process.exit(1);
  });