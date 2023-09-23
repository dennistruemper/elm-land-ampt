// This returns the flags passed into your Elm application
export const flags = async ({ env }: ElmLand.FlagsArgs) => {
  return { baseUrl: env.BASE_URL ?? "" };
};

let websocket;
// This function is called after your Elm app starts
export const onReady = ({ app, env }: ElmLand.OnReadyArgs) => {
  console.log("Elm is ready", app, env);
  try {
    // @ts-ignore
    websocket = new WebSocket(env.BASE_URL.replace("https", "wss"));
  } catch (e) {
    console.log("Error connecting to Ampt WS", e);
  }
  console.log("Connecting to Ampt WS", env.BASE_URL.replace("https", "wss"));

  websocket.onmessage = (event) => {
    console.log("Received message", event.data);
    app.ports.toElm.send(event.data);
  };
};

// Type definitions for Elm Land
namespace ElmLand {
  export type FlagsArgs = {
    env: Record<string, string>;
  };
  export type OnReadyArgs = {
    env: Record<string, string>;
    app: { ports?: Record<string, Port> };
  };
  export type Port = {
    send?: (data: unknown) => void;
    subscribe?: (callback: (data: unknown) => unknown) => void;
  };
}
