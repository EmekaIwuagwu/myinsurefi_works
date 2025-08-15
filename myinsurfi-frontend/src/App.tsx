import React, { useState } from 'react';
import WalletConnection from './components/WalletConnection';
import Dashboard from './components/Dashboard';
import PolicyCreation from './components/PolicyCreation';
import { ContractStats, PolicyFormData, WalletState } from './types';

function App() {
  const [activeTab, setActiveTab] = useState('dashboard');
  const [wallet, setWallet] = useState<WalletState>({
    isConnected: false,
    address: ''
  });
  
  const [stats] = useState<ContractStats>({
    userBalance: '40,000,000',
    totalSupply: '40,000,000',
    totalPolicies: '5',
    totalClaims: '2'
  });

  const [isLoading] = useState(false);

  const connectWallet = () => {
    setWallet({
      isConnected: true,
      address: '0x01c63f0d7ea35151700589c39f94552e8f4ee12df5266f7ab27b3ba670699b18'
    });
  };

  const disconnectWallet = () => {
    setWallet({
      isConnected: false,
      address: ''
    });
  };

  const refreshStats = () => {
    console.log('Refreshing stats...');
  };

  const handleCreatePolicy = (formData: PolicyFormData) => {
    console.log('Creating policy:', formData);
  };

  if (!wallet.isConnected) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-center">
          <div className="bg-white/10 p-8 rounded-xl backdrop-blur-sm">
            <h1 className="text-4xl font-bold text-white mb-4">🏥 MyInsurFi</h1>
            <p className="text-white/80 text-lg mb-8">
              Your decentralized insurance platform
            </p>
            <button
              onClick={connectWallet}
              className="bg-blue-600 text-white px-8 py-3 rounded-lg font-semibold hover:bg-blue-700 transition-colors"
            >
              Connect Wallet
            </button>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen">
      <header className="bg-white/10 backdrop-blur-md border-b border-white/20">
        <div className="max-w-7xl mx-auto px-4 py-6">
          <div className="flex justify-between items-center">
            <h1 className="text-3xl font-bold text-white">🏥 MyInsurFi</h1>
            <button
              onClick={disconnectWallet}
              className="bg-white/10 text-white px-4 py-2 rounded-lg"
            >
              Disconnect
            </button>
          </div>
        </div>
      </header>

      <nav className="bg-white/5 border-b border-white/10">
        <div className="max-w-7xl mx-auto px-4">
          <div className="flex space-x-8">
            <button
              onClick={() => setActiveTab('dashboard')}
              className={`py-4 px-1 border-b-2 font-medium ${
                activeTab === 'dashboard'
                  ? 'border-white text-white'
                  : 'border-transparent text-white/70 hover:text-white'
              }`}
            >
              📊 Dashboard
            </button>
            <button
              onClick={() => setActiveTab('policies')}
              className={`py-4 px-1 border-b-2 font-medium ${
                activeTab === 'policies'
                  ? 'border-white text-white'
                  : 'border-transparent text-white/70 hover:text-white'
              }`}
            >
              🏥 Create Policy
            </button>
          </div>
        </div>
      </nav>

      <main className="max-w-7xl mx-auto py-8 px-4">
        {activeTab === 'dashboard' && (
          <Dashboard 
            stats={stats}
            isLoading={isLoading}
            onRefresh={refreshStats}
          />
        )}
        {activeTab === 'policies' && (
          <PolicyCreation
            onCreatePolicy={handleCreatePolicy}
            isLoading={isLoading}
            result={null}
          />
        )}
      </main>
    </div>
  );
}

export default App;