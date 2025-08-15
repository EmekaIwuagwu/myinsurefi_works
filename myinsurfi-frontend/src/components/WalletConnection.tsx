import React, { useState } from 'react';
import { WalletIcon, CheckCircleIcon, XMarkIcon } from '@heroicons/react/24/outline';
import { formatAddress } from '../contracts/contractConfig';

interface WalletConnectionProps {
  isConnected: boolean;
  address: string;
  onConnect: () => void;
  onDisconnect: () => void;
}

const WalletConnection: React.FC<WalletConnectionProps> = ({
  isConnected,
  address,
  onConnect,
  onDisconnect
}) => {
  const [isModalOpen, setIsModalOpen] = useState(false);

  const handleConnect = () => {
    onConnect();
    setIsModalOpen(false);
  };

  if (isConnected) {
    return (
      <div className="flex items-center space-x-3">
        <div className="flex items-center space-x-2 bg-green-500/20 text-green-100 px-4 py-2 rounded-full border border-green-500/30">
          <CheckCircleIcon className="w-4 h-4" />
          <span className="text-sm font-medium">
            {formatAddress(address)}
          </span>
        </div>
        <button
          onClick={onDisconnect}
          className="bg-white/10 hover:bg-white/20 text-white px-4 py-2 rounded-lg border border-white/30 transition-all duration-300"
        >
          Disconnect
        </button>
      </div>
    );
  }

  return (
    <>
      <button
        onClick={() => setIsModalOpen(true)}
        className="gradient-button flex items-center space-x-2"
      >
        <WalletIcon className="w-5 h-5" />
        <span>Connect Wallet</span>
      </button>

      {/* Wallet Selection Modal */}
      {isModalOpen && (
        <div className="fixed inset-0 z-50 overflow-y-auto">
          <div className="flex items-end justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
            <div
              className="fixed inset-0 transition-opacity bg-black/50"
              onClick={() => setIsModalOpen(false)}
            />

            <div className="inline-block align-bottom bg-white rounded-lg text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-lg sm:w-full">
              <div className="bg-white px-4 pt-5 pb-4 sm:p-6 sm:pb-4">
                <div className="flex justify-between items-center mb-4">
                  <h3 className="text-lg font-medium text-gray-900">
                    Connect Your Wallet
                  </h3>
                  <button
                    onClick={() => setIsModalOpen(false)}
                    className="text-gray-400 hover:text-gray-600"
                  >
                    <XMarkIcon className="w-6 h-6" />
                  </button>
                </div>

                <div className="space-y-3">
                  {/* Mock Wallet Options */}
                  <button
                    onClick={handleConnect}
                    className="w-full flex items-center justify-between p-4 border border-gray-200 rounded-lg hover:border-insurance-blue hover:bg-blue-50 transition-colors"
                  >
                    <div className="flex items-center space-x-3">
                      <div className="w-8 h-8 bg-blue-100 rounded-full flex items-center justify-center">
                        🛡️
                      </div>
                      <div className="text-left">
                        <p className="font-medium text-gray-900">Braavos</p>
                        <p className="text-sm text-gray-500">Connect with Braavos wallet</p>
                      </div>
                    </div>
                  </button>

                  <button
                    onClick={handleConnect}
                    className="w-full flex items-center justify-between p-4 border border-gray-200 rounded-lg hover:border-insurance-blue hover:bg-blue-50 transition-colors"
                  >
                    <div className="flex items-center space-x-3">
                      <div className="w-8 h-8 bg-orange-100 rounded-full flex items-center justify-center">
                        🔐
                      </div>
                      <div className="text-left">
                        <p className="font-medium text-gray-900">ArgentX</p>
                        <p className="text-sm text-gray-500">Connect with ArgentX wallet</p>
                      </div>
                    </div>
                  </button>
                </div>

                <div className="mt-4 p-3 bg-blue-50 rounded-lg">
                  <p className="text-sm text-blue-800">
                    <strong>Demo Mode:</strong> This connects to a simulated wallet for testing purposes.
                  </p>
                </div>
              </div>
            </div>
          </div>
        </div>
      )}
    </>
  );
};

export default WalletConnection;
