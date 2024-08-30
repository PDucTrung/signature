require("dotenv").config();
const express = require("express");
const bodyParser = require("body-parser");
const cors = require("cors");
const { ethers } = require("ethers");

const privateKey = process.env.PRIVATE_KEY;
const provider = new ethers.JsonRpcProvider(
  "https://ethereum-holesky-rpc.publicnode.com"
);
const wallet = new ethers.Wallet(privateKey, provider);

const app = express();

app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

app.post("/signature", async (req, res) => {
  try {
    const { wallet_address, point } = req.body;
    if (!wallet_address) {
      return res.status(400).json({
        status: "Failure",
        message: "Missing required fields",
      });
    }
    const timestamp = Math.floor(Date.now() / 1000);

    // Create the message hash using ethers.js
    const messageHash = ethers.solidityPackedKeccak256(
      ["address", "uint256", "uint256"],
      [wallet_address, point, timestamp]
    );

    // Sign the message
    const signature = await wallet.signMessage(ethers.getBytes(messageHash));

    return res.status(200).json({
      message: messageHash,
      signature,
      point,
      timestamp,
    });
  } catch (e) {
    return res.status(500).json({
      status: "Failure",
      message: "Internal Server Error",
      error: e.message,
    });
  }
});

const PORT = 3004;

app.listen(PORT, () => {
  console.log(`BachiSwap app listening on port ${PORT}`);
});
