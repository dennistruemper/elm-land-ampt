import { data } from "@ampt/data";

export async function setCounter(id: string, value: number): Promise<number> {
  const result = (await data.set("counter:" + id, value)) as number;
  console.log("updateCounter", id, value, result);
  return result;
}

export async function updateCounter(
  id: string,
  value: number
): Promise<number> {
  const result = (await data.add("counter:" + id, value)) as number;
  console.log("updateCounter", id, value, result);
  return result;
}

export async function getCounter(id: string): Promise<number> {
  const result = await data.get("counter:" + id);
  console.log("getCounter", id, result);
  return result as number;
}
