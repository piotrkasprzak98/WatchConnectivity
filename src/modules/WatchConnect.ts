import { BoolResult, MessageProps } from '../definitions';
import { WatchMessage } from '../plugin'
import { PluginListenerHandle } from '@capacitor/core';

export const WatchConnect = {
  sendMessageToWatch: (message: MessageProps): Promise<BoolResult> => {
    return WatchMessage.sendMessageToWatch(message);
  },

  addListener: (eventName: 'runCommand', listenerFunc: (data: { command: string; }) => void): Promise<PluginListenerHandle> & PluginListenerHandle => {
    return WatchMessage.addListener(eventName, listenerFunc);
  },
}