# Life Cycle of ZK circuit in realtime
```
1. Write Circuit (Circom)
   ↓
2. Compile Circuit → R1CS + WASM
   ↓
3. Trusted Setup Ceremony → Proving & Verification Keys
   ↓
4. Generate Witness
   ↓
5. Create Proof
   ↓
6. Verify Proof (Off-chain)
   ↓
7. Generate Solidity Verifier
   ↓
8. Verify Proof (On-chain)
```

# Public inputs in Circuit

```
component main {public [a]} = Mul();
//              ^^^^^^^^^^^
//              'a' is public, 'b' is private and output is always public
```

# Phase-1 Compiling the circuit

```
circom Mul.circom --r1cs --wasm --sym -o .
```

**What this does:**
```
Input:  Mul.circom (circuit source code)
Output: 
  ├─ Mul.r1cs              (Rank-1 Constraint System - the constraints)
  ├─ Mul_js/Mul.wasm       (WebAssembly - witness calculator)
  └─ Mul.sym               (Symbol table - debugging info)
```


Flags explained:

1. `--r1cs`: Generate R1CS file (constraint system)
2. `--wasm`: Generate WebAssembly witness calculator
3. `--sym`: Generate symbol table for debugging
4. `-o` .: Output to current directory

# PHASE 2: Download Powers of Tau

**What is Powers of Tau?**

This is a pre-computed file from a large-scale trusted setup ceremony. It contains cryptographic parameters needed for generating proving/verification keys.

**Why download instead of generate?**

Generating Powers of Tau is extremely expensive (hours/days). The Hermez/Polygon team ran a large ceremony and made the results public for everyone to use.

```
PTAU=12 means:

Can handle circuits up to 2^12 = 4096 constraints
Larger circuits need higher PTAU values
```

**Trust model:**

This file is safe to use if at least one participant in the original ceremony was honest.

## What is a Trusted Setup?
ZK-SNARKs (like Groth16) need special cryptographic parameters to work:

```
Parameters needed:
  - Proving Key (to generate proofs)
  - Verification Key (to verify proofs)
```

These parameters are derived from **secret random values** that must be destroyed after use.

### The Problem:
```
Setup process:
1. Generate random secret: τ (tau), α (alpha), β (beta), γ (gamma), δ (delta)
2. Compute cryptographic parameters from these secrets
3. Delete the secrets (CRITICAL!)

If secrets are kept (not deleted):
1. Anyone with the secrets can create FAKE proofs
2. System is completely broken
3. Can "prove" false statements
```

### Why "Trusted"?

You must **trust** that whoever generated the parameters **destroyed the secrets**.

---

## Powers of Tau Ceremony

### What is "Tau" (τ)?

**Tau (τ)** is a **secret random number** used in the setup.

The ceremony computes **powers of tau**:
```
τ⁰, τ¹, τ², τ³, τ⁴, ..., τⁿ

Encoded as elliptic curve points:
[τ⁰]G, [τ¹]G, [τ²]G, ..., [τⁿ]G

where G is a generator point on the curve
```

These **powers of tau** are the foundation for all cryptographic operations in the proof system.

---

### Why "Powers" Specifically?

The mathematics of ZK-SNARKs requires evaluating **polynomials** at the secret point τ:
```
Circuit as polynomial: P(x) = a₀ + a₁x + a₂x² + ... + aₙxⁿ

To evaluate at secret τ:
P(τ) = a₀ + a₁τ + a₂τ² + ... + aₙτⁿ

We need: τ⁰, τ¹, τ², ..., τⁿ (powers of tau!)
```

The prover uses these powers to compute the proof without knowing τ itself.

---

### Why Elliptic Curve Points?
```
We can't give you τ directly (that would break security)

Instead, we give you: [τ]G, [τ²]G, [τ³]G, ...

Properties:
1. You can compute P(τ) using these points
2. You CANNOT reverse-engineer τ from the points
3. Discrete log problem
```

This is the **trapdoor**: You can use the powers, but can't extract the secret!

---

## Multi-Party Ceremony: Why "At Least One Honest"?

### Single-Party Setup (Dangerous):
```
One person generates:
  - Secret: τ₁
  - Powers: [τ₁]G, [τ₁²]G, ...
  - Says: "I deleted τ₁" 

Problem: You must TRUST them! 
If they kept τ₁ → system is broken
```

---

### Multi-Party Ceremony (Safer):

Multiple participants **sequentially** add randomness:
```
Participant 1:
  - Starts with: [1]G, [x]G, [x²]G, ... (from previous or initial)
  - Generates secret: τ₁
  - Computes: [τ₁]G, [τ₁x]G, [τ₁²x²]G, ...
  - Passes to next participant
  - Destroys τ₁

Participant 2:
  - Receives: [τ₁]G, [τ₁x]G, ...
  - Generates secret: τ₂
  - Computes: [τ₁τ₂]G, [τ₁τ₂x]G, ...
  - Passes to next participant  
  - Destroys τ₂

Participant 3:
  - Generates: τ₃
  - Computes: [τ₁τ₂τ₃]G, ...
  - Destroys τ₃

...and so on

Final result:
  τ = τ₁ × τ₂ × τ₃ × ... × τₙ

Powers of tau:
  [τ]G, [τ²]G, [τ³]G, ...
```

---

### The Security Guarantee:
```
To break the system, an attacker needs:
  τ = τ₁ × τ₂ × τ₃ × ... × τₙ

This requires knowing ALL the secrets:
  - τ₁ (from Participant 1)
  - τ₂ (from Participant 2)
  - τ₃ (from Participant 3)
  - ...
  - τₙ (from Participant n)

Security: If even ONE participant honestly destroyed their secret,
         the final τ is unknown to everyone!

1 out of N honest = System is secure
```

---

### Real-World Example: Zcash Ceremony

Zcash's "Powers of Tau" ceremony (2018):
```
- 176 participants from around the world
- Each contributed randomness
- Only need 1/176 to be honest
- Used diverse hardware and destroyed computers
- Some participants went to extreme lengths:
  - Generated randomness from radioactive decay
  - Used airgapped computers then destroyed them
  - Generated in Faraday cages
```

**Probability all 176 colluded?** Effectively **zero**!

---

## Universal vs Circuit-Specific Setup

### Phase 1: Powers of Tau (Universal)
```
Input: Nothing (starts from scratch)
Process: Generate τ and compute powers
Output: Powers of Tau file (.ptau)

Properties:
1. Universal - works for ANY circuit
2. Only depends on circuit SIZE (max constraints)
3. Can be reused across different circuits
4. One-time ceremony for each size
```

**This is what Hermez/Polygon provided:**
```
powersOfTau28_hez_final_12.ptau
                           ^^
                           Size: 2^12 = 4096 constraints

Can be used for ANY circuit with ≤ 4096 constraints!
```

---

### Phase 2: Circuit-Specific Setup
```
Input: 
  - Powers of Tau (.ptau)
  - Your specific circuit (.r1cs)

Process: Generate circuit-specific parameters

Output: 
  - Proving Key
  - Verification Key
  (.zkey file)

Properties:
1. NOT universal - specific to YOUR circuit
2. Must redo if circuit changes
3. Can have its own multi-party ceremony
```

---

## Do All Circuits Need Same Powers of Tau?

### Answer: **No, but they CAN share one!**
```
Same Size → Can Share
powersOfTau_12.ptau (supports up to 2^12 = 4096 constraints)
  ├─→ Used by Circuit A (1000 constraints) ✓
  ├─→ Used by Circuit B (3000 constraints) ✓
  └─→ Used by Circuit C (4000 constraints) ✓

Different Size → Need Different One
powersOfTau_12.ptau (2^12 = 4096 constraints)
Cannot be used by Circuit D (5000 constraints)
  
Need: powersOfTau_13.ptau (2^13 = 8192 constraints) ✓
```

---

### Practical Usage:
```
Common sizes available from Hermez/Polygon:

powersOfTau28_hez_final_08.ptau  →  2^8  = 256 constraints
powersOfTau28_hez_final_09.ptau  →  2^9  = 512 constraints
powersOfTau28_hez_final_10.ptau  →  2^10 = 1,024 constraints
powersOfTau28_hez_final_12.ptau  →  2^12 = 4,096 constraints
powersOfTau28_hez_final_14.ptau  →  2^14 = 16,384 constraints
powersOfTau28_hez_final_15.ptau  →  2^15 = 32,768 constraints
...
powersOfTau28_hez_final_28.ptau  →  2^28 = 268M constraints

Download once, use for all circuits of that size or smaller!
```

---

## When Do You Need a New Setup?

### Phase 1 (Powers of Tau): RARELY
```
Need new Powers of Tau when:
1. Circuit grows beyond current size
2. Want different security parameters
3. Don't trust existing ceremony

Otherwise: Reuse existing .ptau file 
```

---

### Phase 2 (Circuit-Specific): ALWAYS
```
Need new circuit-specific setup when:
1. Circuit logic changes (even slightly!)
2. Number of signals changes
3. Constraints change

Same circuit, just different inputs: No new setup needed 
```

---

## Transparent Setup (PLONK, STARKs)

Some newer systems **don't need trusted setup**:
```
PLONK:
  - Universal setup (not circuit-specific)
  - Based on updatable setup
  - More flexible

STARKs:
  - No trusted setup at all!
  - Based on hash functions
  - Larger proof sizes

Groth16 (what we're using):
  - Needs trusted setup
  - Smallest proofs
  - Fastest verification on Ethereum
```

# PHASE 3: Generate Witness

```
cd Mul_js
node generate_witness.js Mul.wasm input.json witness.wtns
```

**What this does:**
```
Input:  
  - Mul.wasm (witness calculator)
  - input.json: {"a": 4, "b": 3}

Process:
  - Runs circuit with these inputs
  - Computes all signal values

Output:
  - witness.wtns (all signal values: a=4, b=3, c=12)
```

**The witness contains:**
```
witness[0] = 1        (constant)
witness[1] = 4       (a - public)
witness[2] = 12       (c - output, public)
witness[3] = 3        (b - private)
```

# PHASE 4: Trusted Setup (New Ceremony)

```
# Start ceremony
snarkjs powersoftau new bn128 14 pot12_0000.ptau -v

# Contribute : powersoftau contribute: Add randomness (makes it secure)
snarkjs powersoftau contribute pot12_0000.ptau pot12_0001.ptau --name="First contribution" -v

# Prepare phase 2 : Finalize for circuit-specific setup
snarkjs powersoftau prepare phase2 pot12_0001.ptau pot12_final.ptau -v
```

This creates a new, independent Powers of Tau ceremony specifically for your project.
Why do this if we downloaded one?
Actually, we are doing both:

1. Downloads existing ceremony (Phase 2)
2. Creates new ceremony (this Phase)

In practice, we use one or the other, not both! The download is more common.

# PHASE 5: Circuit-Specific Setup (Phase 2)

```
# Generate zkey
snarkjs groth16 setup Mul.r1cs pot12_final.ptau Mul_0000.zkey

# Contribute to phase 2
snarkjs zkey contribute Mul_0000.zkey Mul_0001.zkey --name="1st Contributor Name" -v
```

**What this does:**
```
Input:
  - Mul.r1cs (your circuit constraints)
  - pot12_final.ptau (universal parameters)

Output:
  - Mul_0001.zkey (contains proving key + verification key)
```

Phase 2 is circuit-specific:
1. Different for every circuit
2. Must be redone if circuit changes
3. Can have multiple contributors for security

The `.zkey` file contains:
1. Proving key (used to generate proofs)
2. Verification key (used to verify proofs)
3. Contributions from participants

# PHASE 6: Export Verification Key

```
snarkjs zkey export verificationkey Mul_0001.zkey verification_key.json
```

Extracts the verification key for standalone use.

```
// verification_key.json structure (simplified)
{
  "protocol": "groth16",
  "curve": "bn128",
  "vk_alpha_1": [...],
  "vk_beta_2": [...],
  "vk_gamma_2": [...],
  "vk_delta_2": [...],
  "IC": [...]
}
```

# PHASE 7: Generate Proof
```
snarkjs groth16 prove Mul_0001.zkey witness.wtns proof.json public.json
```

**This is the main proving step!**
```
Input:
  - Mul_0001.zkey (proving key)
  - witness.wtns (all signal values)

Output:
  - proof.json (the ZK proof)
  - public.json (public signals: a and c)

```
`proof.json` structure:
```json
{
  "pi_a": ["...", "...", "1"],
  "pi_b": [["...", "..."], ["...", "..."], ["1", "0"]],
  "pi_c": ["...", "...", "1"],
  "protocol": "groth16",
  "curve": "bn128"
}
```
`public.json`
```json
["12", "4"]
```
(a=4, c=12 - the public values)

# PHASE 8: Verify Proof (Off-chain)
```
snarkjs groth16 verify verification_key.json public.json proof.json
```

**Verifies the proof using JavaScript.**
```
Input:
  - verification_key.json
  - public.json (public signals)
  - proof.json (the proof)

Output:
  OK or INVALID
```

**What is checks** : "Does this proof validly show that someone knows inputs that produce these public outputs?"

# PHASE 9: Generate Solidity Verifier
```
snarkjs zkey export solidityverifier Mul_0001.zkey ./contracts/verifier.sol
```
Generates a Solidity smart contract that can verify proofs on Ethereum!

`verifier.sol` structure:

```solidity
contract Verifier {
    function verifyProof(
        uint[2] memory a,
        uint[2][2] memory b,
        uint[2] memory c,
        uint[1] memory input
    ) public view returns (bool) {
        // Pairing checks using precompiled contracts
        // Verifies the proof on-chain
    }
}
```

# PHASE 10: Generate Call Data
```
bashsnarkjs generatecall | tee parameters.txt
```
Generates properly formatted inputs for calling the Solidity verifier.

Output example:
```javascript
["0x...", "0x..."],           // a
[["0x...", "0x..."], [...]], // b
["0x...", "0x..."],           // c
["0x20"]                      // input (public signals)
```
This can be directly used in a smart contract call.

