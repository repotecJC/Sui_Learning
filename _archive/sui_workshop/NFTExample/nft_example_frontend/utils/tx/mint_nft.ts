import { Transaction } from "@mysten/sui/transactions";
import { packageID } from "../package";
export function mintNftTx(
    name: string,
    description: string,
    url: string
): Transaction {
    const tx = new Transaction();
    let encoder = new TextEncoder()
    tx.moveCall({
        target: `${packageID}::nft_example::mint_nft_to_sender`,
        arguments: [tx.pure.string(name), tx.pure.string(description), tx.pure.vector('u8', encoder.encode(url))],
    })
    return tx;
}
