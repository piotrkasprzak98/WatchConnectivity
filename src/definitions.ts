import { PluginListenerHandle } from "@capacitor/core";

export type BoolResult = {
  result: boolean;
};

export type MessageProps = {
  key: string;
  value: string;
};

export interface WatchMessagePlugin {
  sendMessageToWatch: (props: MessageProps) => Promise<BoolResult>;
  addListener(eventName: 'runCommand', listenerFunc: (data: { command: string; }) => void): Promise<PluginListenerHandle> & PluginListenerHandle;
}