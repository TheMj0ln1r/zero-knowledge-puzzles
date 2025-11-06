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

describe("integer square root validation", function() {
    this.timeout(100000);

    let circuit;

    before(async () => {
        circuit = await wasm_tester(path.join(__dirname, "../IntSqrt/", "IntSqrt.circom"));
        await circuit.loadConstraints();
    });

    it("Should accept [2, 4]", async () => {

        await expect(circuit.calculateWitness({
            "in": [2, 4]
        }, true)).to.not.eventually.be.rejected;
    });

    it("Should accept [2, 5]", async () => {

        await expect(circuit.calculateWitness({
            "in": [2, 5]
        }, true)).to.not.eventually.be.rejected;
    });

    it("Should reject [2, 9]", async () => {

        await expect(circuit.calculateWitness({
            "in": [2, 9]
        }, true)).to.eventually.be.rejected;
    });

    it("Should accept [(2**126)-1, ((2**126)-1) * ((2**126)-1)]", async () => {

        await expect(circuit.calculateWitness({
            "in": [85070591730234615865843651857942052863, 7237005577332262213973186563042994240659232858142066020734411696778686496769]
        }, true)).to.eventually.be.rejected;
    });

    it("Should reject [(2**127)-1, ((2**127)-1) * ((2**127)-1)]", async () => {

        await expect(circuit.calculateWitness({
            "in": [170141183460469231731687303715884105727, 28948022309329048855892746252171976962977213799489202546401021394546514198529]
        }, true)).to.eventually.be.rejected;
    });

    it("Should reject [(2**128)-1, ((2**128)-1) * ((2**128)-1)]", async () => {

        await expect(circuit.calculateWitness({
            "in": [340282366920938463463374607431768211455, 115792089237316195423570985008687907852589419931798687112530834793049593217025]
        }, true)).to.eventually.be.rejected;
    });

});
