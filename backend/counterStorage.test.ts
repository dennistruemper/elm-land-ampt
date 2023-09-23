import { beforeAll, describe, expect, it } from "vitest";
import { getCounter, setCounter, updateCounter } from "./counterStorage";

describe("counterStorage", () => {
  beforeAll(async () => {
    await setCounter("test", 42);
  });

  it("should increment test counter", async () => {
    const firstResult = await updateCounter(
      "test-2767954e-6075-43a4-bb75-90a9ae6462de",
      1
    );
    const secondResult = await updateCounter(
      "test-2767954e-6075-43a4-bb75-90a9ae6462de",
      1
    );
    expect(secondResult).toBe(firstResult + 1);
  });

  it("should return testcounter", async () => {
    const result = await getCounter("test");
    expect(result).toBe(42);
  });
});
