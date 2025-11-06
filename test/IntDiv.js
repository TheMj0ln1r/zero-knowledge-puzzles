const chai = require('chai');
const {
    wasm
} = require('circom_tester');
const path = require("path");
const F1Field = require("ffjavascript").F1Field;
const Scalar = require("ffjavascript").Scalar;
exports.p = Scalar.fromString("21888242871839275222246405745257275088548364400416034343698204186575808495617");
const Fr = new F1Field(exports.p);
const chaiAsPromised = require("chai-as-promised");
const wasm_tester = require("circom_tester").wasm;

chai.use(chaiAsPromised);
const expect = chai.expect;

describe("integer division", function() {
    this.timeout(100000);

    let circuit;

    before(async () => {
        circuit = await wasm_tester(path.join(__dirname, "../IntDiv/", "IntDiv.circom"));
        await circuit.loadConstraints();
    });

    it("Should accept [10 / 2  = 5 remainder 0]", async () => {

        await expect(circuit.calculateWitness({
            "numerator": 10,
            "denominator": 2,
            "quotient": 5,
            "remainder": 0
        }, true)).to.not.eventually.be.rejected;
    });

    it("Should accept [11 / 2] = 5 remainder 1", async () => {
        await expect(circuit.calculateWitness({
            "numerator": 11,
            "denominator": 2,
            "quotient": 5,
            "remainder": 1
        }, true)).to.not.eventually.be.rejected;
    });

    it("Should reject [11 / 2] = 4 remainder 3", async () => {
        await expect(circuit.calculateWitness({
            "numerator": 11,
            "denominator": 2,
            "quotient": 4,
            "remainder": 3
        }, true)).to.eventually.be.rejected;
    });

    it("Should division by zero", async () => {
        await expect(circuit.calculateWitness({
            "numerator": 0,
            "denominator": 0,
            "quotient": 0,
            "remainder": 0
        }, true)).to.eventually.be.rejected;
    });

    it("Should accept when denominator and quotient are within 126 bits", async () => {
        // 2^125 = 42535295865117307932921825928971026432
        // denominator = 2^62 = 4611686018427387904
        // quotient = 2^63 = 9223372036854775808 (within 126 bits)
        const numerator = "42535295865117307932921825928971026432"; // 2^125
        const denominator = "4611686018427387904"; // 2^62
        const quotient = "9223372036854775808"; // 2^63
        const remainder = "0";

        await expect(circuit.calculateWitness({
            "numerator": numerator,
            "denominator": denominator,
            "quotient": quotient,
            "remainder": remainder
        }, true)).to.not.eventually.be.rejected;
    });

    it("Should reject when denominator exceeds 126 bits", async () => {
        // 2^126 = 85070591730234615865843651857942052864 (requires 127 bits)
        const numerator = "85070591730234615865843651857942052864"; // 2^126
        const denominator = "85070591730234615865843651857942052864"; // 2^126 (exceeds 126 bits)
        const quotient = "1";
        const remainder = "0";

        await expect(circuit.calculateWitness({
            "numerator": numerator,
            "denominator": denominator,
            "quotient": quotient,
            "remainder": remainder
        }, true)).to.eventually.be.rejected;
    });

    it("Should reject when quotient exceeds 126 bits", async () => {
        // quotient = 2^126 (requires 127 bits, exceeds 126-bit limit)
        const numerator = "170141183460469231731687303715884105728"; // 2^127
        const denominator = "2";
        const quotient = "85070591730234615865843651857942052864"; // 2^126 (exceeds 126 bits)
        const remainder = "0";

        await expect(circuit.calculateWitness({
            "numerator": numerator,
            "denominator": denominator,
            "quotient": quotient,
            "remainder": remainder
        }, true)).to.eventually.be.rejected;
    });
});
