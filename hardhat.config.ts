import * as dotenv from "dotenv";
import { HardhatUserConfig, task } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

// Plugins
import "@nomiclabs/hardhat-solhint";
import 'hardhat-test-utils'



dotenv.config();

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
    const accounts = await hre.ethers.getSigners();
    
    for (const account of accounts) {
        console.log(account.address);
    }
});

const config: HardhatUserConfig = {
    solidity: {
        version: "0.8.14",
        settings: {
            optimizer: {
                enabled: true,
                runs: 200
            }
        }
    },
    networks: {
        localhost: {
            chainId: 31337,
            accounts: [process.env.HARDHAT_PRIVATE_KEY!]
        },
        rinkeby: {
            url: process.env.RINKEBY_URL || "",
            accounts: [process.env.DEPLOY_PRIVATE_KEY!],
        },
        mumbai: {
            url: process.env.MUMBAI_URL || "",
            accounts: [process.env.DEPLOY_PRIVATE_KEY!]
        }
        
    },
    gasReporter: {
        enabled: process.env.REPORT_GAS !== undefined,
        currency: "USD",
    },
    etherscan: {
        apiKey: process.env.ETHERSCAN_API_KEY,
        // apiKey: process.env.POLYGONSCAN_API_KEY,
    },
};

export default config;
