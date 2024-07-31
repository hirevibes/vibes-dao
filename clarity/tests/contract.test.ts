import { describe, expect, it } from "vitest";
import { Cl, serializeCV, signWithKey, createStacksPrivateKey } from "@stacks/transactions";
import {createHash} from "crypto";

const accounts = simnet.getAccounts();
const vibes_deployer = "SP27BB1Y2DGSXZHS7G9YHKTSH6KQ6BD3QG0AN3CR9";
const deployer = accounts.get("deployer")!;
const address1 = accounts.get("wallet_1")!;
const privateKey = 'd55c47953b34161786b1c0351fbf226658635c7a25bd5fcc304098c3d0f307c5';

const bootstrap = "ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.vdp000-bootstrap";
    

function sha256(data:any){
  return createHash('sha256').update(data).digest();
}

function structuredDataHash(structuredData:any) {
  return sha256(serializeCV(structuredData));
}

function makeStructuredData(proposalName:any) {
  return Cl.tuple({
    proposalPrincipal: Cl.principal(proposalName),
    sender: Cl.principal(deployer),
  });
}

function vrsToRsv(sig:any) {
  return Buffer.from(sig.slice(2) + sig.slice(0, 2), 'hex');
}

function sign(_hash:any, privateKey:any) {
  const hash = typeof _hash === 'string' ? _hash : Buffer.from(_hash).toString('hex');;
  const key = createStacksPrivateKey(privateKey);
  const data = signWithKey(key, hash).data;
  return vrsToRsv(data);
}

/*
  The test below is an example. Learn more in the clarinet-sdk readme:
  https://github.com/hirosystems/clarinet/blob/develop/components/clarinet-sdk/README.md
*/

describe("vibeDao tests", () => {
  it("ensures simnet is well initalise", () => {
    expect(simnet.blockHeight).toBeDefined();
  });

  it("transfer VIBES", () => {
    const {result} = simnet.callPublicFn("SP27BB1Y2DGSXZHS7G9YHKTSH6KQ6BD3QG0AN3CR9.vibes-token", "transfer", [Cl.uint(100000000000000), Cl.principal(vibes_deployer), Cl.principal(deployer), Cl.none()], vibes_deployer);

    expect(result).toBeOk(Cl.bool(true));
  });


  it("init vibeDao", () => {
    const {result} = simnet.callPublicFn("vibeDAO", "construct", [Cl.principal(bootstrap!)], deployer);
    expect(result).toBeOk(Cl.bool(true));
  });

  it("ensures the contract is deployed", () => {
    simnet.callPublicFn("SP27BB1Y2DGSXZHS7G9YHKTSH6KQ6BD3QG0AN3CR9.vibes-token", "transfer", [Cl.uint(100000000000000), Cl.principal(vibes_deployer), Cl.principal(deployer), Cl.none()], vibes_deployer);
    simnet.callPublicFn("vibeDAO", "construct", [Cl.principal(bootstrap!)], deployer);
    
    const blockHeight = simnet.blockHeight;
    const proposalName =  "ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.base-proposal";
    const structuredData = makeStructuredData(proposalName);
    const hash = structuredDataHash(structuredData);
    const sig = sign(hash, privateKey);

    const {result} = simnet.callPublicFn("vde002-proposal-submission", "propose", [Cl.principal(proposalName!), Cl.uint(blockHeight+2), Cl.buffer(sig)], deployer)
    console.log(result);
    console.log(deployer);
    expect(result).toBeOk(Cl.bool(true));
  });

  // it("shows an example", () => {
  //   const { result } = simnet.callReadOnlyFn("counter", "get-counter", [], address1);
  //   expect(result).toBeUint(0);
  // });
});
