const quais = require("quais");
const { deployMetadata } = require("hardhat");
require("dotenv").config();

const QuestControllerJson = require("../artifacts/contracts/QuestController.sol/QuestController.json");
const PlayRPSVerifierJson = require("../artifacts/contracts/PlayRPSVerifier.sol/PlayRPSVerifier.json");
const DailyLoginVerifierJson = require("../artifacts/contracts/DailyLoginVerifier.sol/DailyLoginVerifier.json");

async function deployVerifiersOnly() {
  const provider = new quais.JsonRpcProvider(process.env.RPC_URL);
  const wallet = new quais.Wallet(process.env.CYPRUS1_PK, provider);

  const QuestControllerAddress = "0x004257e211C6cE65D2f818942610924ff01213a2";
  const rpsContractAddress = "0x004f6Da6CA6A85890441e483EAf2f076B1b75021";

  // === 1. Deploy DailyLoginVerifier ===
  const dailyIpfsHash = await deployMetadata.pushMetadataToIPFS("DailyLoginVerifier");
  const DailyFactory = new quais.ContractFactory(
    DailyLoginVerifierJson.abi,
    DailyLoginVerifierJson.bytecode,
    wallet,
    dailyIpfsHash
  );

  const dailyTx = await DailyFactory.deploy();
  console.log(":rocket: Tx broadcasted for DailyLoginVerifier:", dailyTx.deploymentTransaction().hash);
  await dailyTx.waitForDeployment();
  const dailyVerifierAddress = await dailyTx.getAddress();
  console.log(":white_check_mark: DailyLoginVerifier deployed at:", dailyVerifierAddress);

  // === 2. Deploy PlayRPSVerifier with existing RPS game address ===
  const rpsIpfsHash = await deployMetadata.pushMetadataToIPFS("PlayRPSVerifier");
  const RpsFactory = new quais.ContractFactory(
    PlayRPSVerifierJson.abi,
    PlayRPSVerifierJson.bytecode,
    wallet,
    rpsIpfsHash
  );

  const rpsTx = await RpsFactory.deploy(rpsContractAddress);
  console.log(":rocket: Tx broadcasted for PlayRPSVerifier:", rpsTx.deploymentTransaction().hash);
  await rpsTx.waitForDeployment();
  const rpsVerifierAddress = await rpsTx.getAddress();
  console.log(":white_check_mark: PlayRPSVerifier deployed at:", rpsVerifierAddress);
}

deployVerifiersOnly()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error(":x: Deployment failed:", err);
    process.exit(1);
  });