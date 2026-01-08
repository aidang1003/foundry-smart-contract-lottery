import { ethers } from "./ethers-6.7.esm.min.js"
import { abi, contractAddress } from "./constants.js"

const connectButton = document.getElementById("connectButton")
const enterRaffleButton = document.getElementById("enterRaffleButton")
const entranceFeeButton = document.getElementById("entranceFee")
const getJackpotButton = document.getElementById("getJackpot")
const getPlayersButton = document.getElementById("getPlayers")
const getRecentWinnerButton = document.getElementById("getRecentWinner")
connectButton.onclick = connect
enterRaffleButton.onclick = enterRaffle
entranceFeeButton.onclick = getEntraceFee
getJackpotButton.onclick = getJackpot
getPlayersButton.onclick = getPlayers
getRecentWinnerButton.onclick = getRecentWinner

async function connect() {
  if (typeof window.ethereum !== "undefined") {
    try {
      await ethereum.request({ method: "eth_requestAccounts" })
    } catch (error) {
      console.log(error)
    }
    connectButton.innerHTML = "Connected"
    const accounts = await ethereum.request({ method: "eth_accounts" })
    console.log(accounts)
  } else {
    connectButton.innerHTML = "Please install MetaMask"
  }
}

async function getEntraceFee() {
  console.log(`Getting Entrance Fee...`)
  if (typeof window.ethereum !== "undefined") {
    const provider = new ethers.BrowserProvider(window.ethereum)
    await provider.send('eth_requestAccounts', [])
    const signer = await provider.getSigner()
    const contract = new ethers.Contract(contractAddress, abi, signer)
    try {
      console.log("Processing transaction...")
      const transactionResponse = await contract.getEntranceFee()
      document.getElementById("entranceFeeAmount").textContent = ethers.formatEther(transactionResponse)
      console.log("Entrance fee is", entranceFeeAmount)
    } catch (error) {
      console.log(error)
    }
  } else {
    withdrawButton.innerHTML = "Please install MetaMask"
  }
}

async function enterRaffle() {
  // Example of how to call a contract function
  const ethAmount = document.getElementById("ethAmount").value
  console.log(`Funding with ${ethAmount}...`)
  if (typeof window.ethereum !== "undefined") {
    const provider = new ethers.BrowserProvider(window.ethereum)
    await provider.send('eth_requestAccounts', [])
    const signer = await provider.getSigner()
    const contract = new ethers.Contract(contractAddress, abi, signer)
    try {
      const transactionResponse = await contract.enterRaffle({
        value: ethers.parseEther(ethAmount),
      })
      await transactionResponse.wait(1)
    } catch (error) {
      console.log(error)
    }
  } else {
    fundButton.innerHTML = "Please install MetaMask"
  }
}


async function getJackpot() {
  // Generic example of how to get the balance of a contract by using the address
  // Less complicated than calling a function within the contract
  if (typeof window.ethereum !== "undefined") {
    const provider = new ethers.BrowserProvider(window.ethereum)
    try {
      const jackpotAmount = await provider.getBalance(contractAddress)
      // Call the jackpotAmount element and set it using the ethers format function
      document.getElementById("jackpotAmount").textContent = ethers.formatEther(jackpotAmount)
    } catch (error) {
      console.log(error)
    }
  } else {
    balanceButton.innerHTML = "Please install MetaMask"
  }
}

async function getPlayers() {
  console.log(`Getting Number of players in the raffle...`)
  if (typeof window.ethereum !== "undefined") {
    const provider = new ethers.BrowserProvider(window.ethereum)
    await provider.send('eth_requestAccounts', [])
    const signer = await provider.getSigner()
    const contract = new ethers.Contract(contractAddress, abi, signer)
    let myAddress // initialize address variable
    let playerCount = 0 // initialize player count
    while (true) {
      try {
        myAddress = await contract.getPlayer(playerCount) // Alway the first address in the array
        console.log("Added Address to count", myAddress)
        playerCount = playerCount + 1 // iterate before entering the try loop
      } catch (error) {
        // To stop calling the array it has to enter here
        // Will emit an error to the browser, but as far as I can tell there is nothing to do about it
        console.log(error)
        break
      }
    }
    document.getElementById("playerAmount").textContent = playerCount
  } else {
    withdrawButton.innerHTML = "Please install MetaMask"
  }
}


async function getRecentWinner() {
  console.log(`Getting Recent Winner...`)
  if (typeof window.ethereum !== "undefined") {
    const provider = new ethers.BrowserProvider(window.ethereum)
    await provider.send('eth_requestAccounts', [])
    const signer = await provider.getSigner()
    const contract = new ethers.Contract(contractAddress, abi, signer)
    try {
      console.log("Processing transaction...")
      const transactionResponse = await contract.getRecentWinner()
      document.getElementById("recentWinner").textContent = transactionResponse
      console.log("Recently winning address:", transactionResponse)
    } catch (error) {
      console.log(error)
    }
  } else {
    withdrawButton.innerHTML = "Please install MetaMask"
  }
}