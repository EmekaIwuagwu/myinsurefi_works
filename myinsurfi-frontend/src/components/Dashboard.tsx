import React from 'react';
import { ContractStats } from '../types';

interface DashboardProps {
  stats: ContractStats;
  isLoading: boolean;
  onRefresh: () => void;
}

const Dashboard: React.FC<DashboardProps> = ({ stats, isLoading, onRefresh }) => {
  return (
    <div className="space-y-8">
      <div className="text-center">
        <h2 className="text-3xl font-bold text-white">Dashboard</h2>
        <p className="text-white/80 mt-2">Welcome to MyInsurFi</p>
        <button 
          onClick={onRefresh} 
          className="mt-4 bg-blue-600 text-white px-6 py-2 rounded-lg hover:bg-blue-700"
        >
          🔄 Refresh
        </button>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        <div className="bg-white p-6 rounded-lg shadow-lg">
          <h3 className="text-lg font-bold text-gray-800">Your Balance</h3>
          <p className="text-2xl font-bold text-blue-600">
            {stats.userBalance} MYSU
          </p>
        </div>
        <div className="bg-white p-6 rounded-lg shadow-lg">
          <h3 className="text-lg font-bold text-gray-800">Total Supply</h3>
          <p className="text-2xl font-bold text-green-600">
            {stats.totalSupply} MYSU
          </p>
        </div>
        <div className="bg-white p-6 rounded-lg shadow-lg">
          <h3 className="text-lg font-bold text-gray-800">Total Policies</h3>
          <p className="text-2xl font-bold text-purple-600">
            {stats.totalPolicies}
          </p>
        </div>
        <div className="bg-white p-6 rounded-lg shadow-lg">
          <h3 className="text-lg font-bold text-gray-800">Total Claims</h3>
          <p className="text-2xl font-bold text-orange-600">
            {stats.totalClaims}
          </p>
        </div>
      </div>

      <div className="bg-white/10 p-6 rounded-lg">
        <h3 className="text-xl font-bold text-white mb-4">Contract Information</h3>
        <div className="text-white space-y-2">
          <p>Contract: 0x061765eefef928d59c553fae712b677b7a832e9362259731ce1b57f6849773b2</p>
          <p>Network: StarkNet Sepolia</p>
          <p className="text-blue-300 cursor-pointer">🔍 View on StarkScan</p>
        </div>
      </div>
    </div>
  );
};

export default Dashboard;