import { data } from "@ampt/data";
import { ws } from "@ampt/sdk";

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

data.on("*:counter:global", async (event) => {
  // send new value to all clients
  // todo pagination if there are too many connections
  const connections = (await data.get("connection:*")) as unknown as {
    items: { value: { connectionId: string } }[]; // types are not good in ampt data right now, so I have to cheat a little
  };
  console.log("connections", JSON.stringify(connections));
  connections.items.map(async (connection) => {
    ws.send(connection.value.connectionId, { newCount: event.item.value });
  });
  console.log("counter:global", event);
});
