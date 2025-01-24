import { PluginListenerHandle } from "@capacitor/core";

export type BoolResult = {
  result: boolean;
};

export type MessageProps = {
  key: string;
  value: string;
};

export type WorkoutProps = {
  activityType: string;
  locationType: string;
};

export interface WatchMessagePlugin {
  sendMessageToWatch: (props: MessageProps) => Promise<BoolResult>;
  addListener(eventName: 'runCommand', listenerFunc: (data: { command: string; }) => void): Promise<PluginListenerHandle> & PluginListenerHandle;
  startWatchAppWithWorkoutConfiguration: (props: WorkoutProps) => Promise<BoolResult>;
  transferUserInfoToWatch: (props: MessageProps) => Promise<BoolResult>;
  updateApplicationContextWatch: (props: MessageProps) => Promise<BoolResult>;
  isWatchPaired: () => Promise<BoolResult>;
  isWatchAppInstalled: () => Promise<BoolResult>;
}