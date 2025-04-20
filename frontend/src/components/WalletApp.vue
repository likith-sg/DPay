<template>
  <div class="app">
    <h1>DPay 💸</h1>
    <p v-if="!account">🔌 Connect your wallet</p>
    <button
      class="connect-button"
      @click="connectWallet"
      :disabled="isConnecting"
    >
      {{ isConnecting ? 'Connecting...' : 'Connect Wallet' }}
    </button>

    <div v-if="account">
      <p><strong>Account:</strong> {{ account }}</p>
      <p><strong>Contract Balance:</strong> {{ balance }} ETH</p>

      <div class="form">
        <input
          v-model.number="depositAmount"
          type="number"
          min="0"
          placeholder="Amount to deposit"
        />
        <button
          class="action-button"
          @click="deposit"
          :disabled="isProcessing || !contract || !depositAmount || depositAmount <= 0"
        >
          {{ isProcessing && depositAmount > 0 ? 'Depositing...' : 'Deposit' }}
        </button>
      </div>

      <div class="form">
        <input
          v-model.number="withdrawAmount"
          type="number"
          min="0"
          placeholder="Amount to withdraw"
        />
        <button
          class="action-button"
          @click="withdraw"
          :disabled="isProcessing || !contract || !withdrawAmount || withdrawAmount <= 0"
        >
          {{ isProcessing && withdrawAmount > 0 ? 'Withdrawing...' : 'Withdraw' }}
        </button>
      </div>

      <div class="form">
        <input v-model="transferAddress" placeholder="Recipient address" />
        <input
          v-model.number="transferAmount"
          type="number"
          min="0"
          placeholder="Amount to send"
        />
        <button
  class="action-button"
  @click="send"
  :disabled="isProcessing || !contract || !transferAddress || !transferAmount || transferAmount <= 0 || !isAddress(transferAddress)"
>
  {{ isProcessing && transferAmount > 0 ? 'Sending...' : 'Send' }}
</button>

        <!-- <button
          class="action-button"
          @click="send"
          :disabled="isProcessing || !contract || !transferAddress || !transferAmount || transferAmount <= 0 || !isAddress(transferAddress)"
        >
          {{ isProcessing && transferAmount > 0 ? 'Sending...' : 'Send' }}
        </button> -->
      </div>

      <div v-if="errorMessage" class="error-message">{{ errorMessage }}</div>
    </div>
  </div>
</template>

<script>
import { ethers } from 'ethers';
import { parseEther, isAddress } from 'ethers';

// Assuming your DPay.json file is in the '../dpay-abi/' directory
import DPayABI from '../dpay-abi/DPay.json';

export default {

  
  data() {
    return {
      account: null,
      provider: null,
      signer: null,
      contract: null,
      balance: '0',
      depositAmount: null,
      withdrawAmount: null,
      transferAddress: '',
      transferAmount: null,
      isConnecting: false,
      isProcessing: false,
      errorMessage: null,
    };
  },
  methods: {
    isAddress,

async connectWallet() {
  this.isConnecting = true;
  this.errorMessage = null;

  try {
    if (!window.ethereum) {
      throw new Error("MetaMask not installed");
    }

    const provider = new ethers.BrowserProvider(window.ethereum);
    await window.ethereum.request({ method: "eth_requestAccounts" });

    const signer = await provider.getSigner();
    const account = await signer.getAddress();

    this.provider = provider;
    this.signer = signer;
    this.account = account;

    // ⚠️ Initialize contract here
    const contractAddress = '0x854cF79Ac723210f46401ceA819D52b15F031b44';
    this.contract = new ethers.Contract(contractAddress, DPayABI.abi, signer);

    await this.getBalance();
  } catch (err) {
    this.errorMessage = "Error connecting wallet: " + err.message;
    console.error("Error connecting wallet:", err);
    this.resetState();
  } finally {
    this.isConnecting = false;
  }
},
async getContractBalance() {
  try {
    const balance = await this.provider.getBalance(this.contract.address);
    this.contractBalance = ethers.formatEther(balance);
  } catch (err) {
    console.error("Error fetching contract balance:", err);
    this.contractBalance = '0';
  }
}
,
async getBalance() {
  try {
    if (!this.account || !this.provider) {
      throw new Error("Account or provider not set");
    }

    console.log("Provider type:", this.provider.constructor.name);
    
    const balanceHex = await window.ethereum.request({
      method: 'eth_getBalance',
      params: [this.account, 'latest']
    });
    
    this.balance = ethers.formatEther(balanceHex);
    console.log("Balance in ETH:", this.balance);
    
  } catch (err) {
    console.error("Error fetching balance:", err);
    this.balance = "0";
  }
},

    async deposit() {
      if (this.isProcessing || !this.contract || !this.depositAmount || this.depositAmount <= 0) return;
      this.isProcessing = true;
      this.errorMessage = null;

      try {
        const tx = await this.contract.deposit({
          
          value: ethers.parseEther(this.depositAmount.toFixed(18).toString()),
          

          // value: ethers.utils.parseEther(this.depositAmount.toString()),
        });
        await tx.wait();

        alert(`Deposited ${this.depositAmount} ETH`);
        this.depositAmount = null;
        await this.getBalance();
      } catch (err) {
        this.errorMessage = "Error depositing: " + err.message;
        console.error("Error depositing:", err);
      } finally {
        this.isProcessing = false;
      }
    },
    async withdraw() {
      if (this.isProcessing || !this.contract || !this.withdrawAmount || this.withdrawAmount <= 0) return;
      this.isProcessing = true;
      this.errorMessage = null;

      try {
        const tx = await this.contract.withdraw(ethers.parseEther(this.withdrawAmount.toFixed(18).toString()));
        await tx.wait();

        alert(`Withdrew ${this.withdrawAmount} ETH`);
        this.withdrawAmount = null;
        await this.getBalance();
      } catch (err) {
        this.errorMessage = "Error withdrawing: " + err.message;
        console.error("Error withdrawing:", err);
      } finally {
        this.isProcessing = false;
      }
    },

async send() {
  if (
    this.isProcessing ||
    !this.contract ||
    !this.transferAddress ||
    !isAddress(this.transferAddress) ||
    !this.transferAmount ||
    this.transferAmount <= 0
  )
    return;

  this.isProcessing = true;
  this.errorMessage = null;

  try {
    const tx = await this.contract.transfer(
      this.transferAddress,
      parseEther(this.transferAmount.toFixed(18).toString())
    );
    await tx.wait();

    alert(`Sent ${this.transferAmount} ETH to ${this.transferAddress}`);
    this.transferAddress = '';
    this.transferAmount = null;
    await this.getBalance();
  } catch (err) {
    this.errorMessage = "Error sending: " + err.message;
    console.error("Error sending:", err);
  } finally {
    this.isProcessing = false;
  }
}
,
    // async send() {
    //   if (
    //     this.isProcessing ||
    //     !this.contract ||
    //     !this.transferAddress ||
    //     !ethers.utils.isAddress(this.transferAddress) ||
    //     !this.transferAmount ||
    //     this.transferAmount <= 0
    //   )
    //     return;
    //   this.isProcessing = true;
    //   this.errorMessage = null;

    //   try {
    //     const tx = await this.contract.transfer(
    //       this.transferAddress,
    //       ethers.parseEther(this.transferAmount.toString())
    //     );
    //     await tx.wait();

    //     alert(`Sent ${this.transferAmount} ETH to ${this.transferAddress}`);
    //     this.transferAddress = '';
    //     this.transferAmount = null;
    //     await this.getBalance();
    //   } catch (err) {
    //     this.errorMessage = "Error sending: " + err.message;
    //     console.error("Error sending:", err);
    //   } finally {
    //     this.isProcessing = false;
    //   }
    // },
    resetState() {
      this.account = null;
      this.provider = null;
      this.signer = null;
      this.contract = null;
      this.contractBalance = '0';
      this.depositAmount = null;
      this.withdrawAmount = null;
      this.transferAddress = '';
      this.transferAmount = null;
    },
  },
};
</script>

<style scoped>
/* General styling */
.app {
  max-width: 600px;
  margin: auto;
  padding: 2rem;
  font-family: 'Roboto', sans-serif;
  background-color: #1e1e1e;
  border-radius: 10px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
  color: white;
}

/* Title */
h1 {
  color: #4CAF50;
  font-size: 2rem;
  text-align: center;
  margin-bottom: 1.5rem;
}

/* Connect Button */
.connect-button {
  width: 100%;
  padding: 1rem;
  background-color: #0061f2;
  color: white;
  border-radius: 10px;
  font-size: 1.2rem;
  border: none;
  cursor: pointer;
  transition: background-color 0.3s;
  margin-bottom: 1rem;
}

.connect-button:disabled {
  background-color: #ccc;
  cursor: not-allowed;
}

.connect-button:hover:not(:disabled) {
  background-color: #0052cc;
}

/* Form Section */
.form {
  display: flex;
  flex-direction: column;
  margin-bottom: 1rem;
}

input {
  margin: 0.5rem 0;
  padding: 1rem;
  font-size: 1rem;
  border: 1px solid #ccc;
  border-radius: 8px;
  width: 100%;
  background-color: #2c2c2c;
  color: white;
}

input:focus {
  outline: none;
  border-color: #4CAF50;
}

button {
  padding: 1rem;
  background-color: #4CAF50;
  color: white;
  border-radius: 8px;
  font-size: 1rem;
  cursor: pointer;
  transition: background-color 0.3s;
  border: none;
}

button:disabled {
  background-color: #ccc;
  cursor: not-allowed;
}

button:hover:not(:disabled) {
  background-color: #45a049;
}

/* Error Message */
.error-message {
  color: red;
  font-size: 1rem;
  margin-top: 1rem;
  text-align: center;
}
</style>
