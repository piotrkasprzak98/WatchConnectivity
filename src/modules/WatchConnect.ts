import { BoolResult, MessageProps, WorkoutProps } from '../definitions';
import { WatchMessage } from '../plugin'
import { PluginListenerHandle } from '@capacitor/core';

export const WatchConnect = {
  sendMessageToWatch: (message: MessageProps): Promise<BoolResult> => {
    return WatchMessage.sendMessageToWatch(message);
  },

  addListener: (eventName: 'runCommand', listenerFunc: (data: { command: string; }) => void): Promise<PluginListenerHandle> & PluginListenerHandle => {
    return WatchMessage.addListener(eventName, listenerFunc);
  },

  startWatchAppWithWorkoutConfiguration: (props: WorkoutProps): Promise<BoolResult> => {
    return WatchMessage.startWatchAppWithWorkoutConfiguration(props);
  },

  transferUserInfoToWatch: (props: MessageProps): Promise<BoolResult> => {
    return WatchMessage.transferUserInfoToWatch(props);
  }, 

  updateApplicationContextWatch: (props: MessageProps): Promise<BoolResult> => {
    return WatchMessage.transferUserInfoToWatch(props);
  },

  isWatchPaired: (): Promise<BoolResult> => {
    return WatchMessage.isWatchPaired();
  },

  isWatchAppInstalled: (): Promise<BoolResult> => {
    return WatchMessage.isWatchAppInstalled();
  },
}