import React, { useState } from 'react';
import { PolicyFormData } from '../types';

interface PolicyCreationProps {
  onCreatePolicy: (data: PolicyFormData) => void;
  isLoading: boolean;
  result: { success: boolean; message: string; hash?: string } | null;
}

const PolicyCreation: React.FC<PolicyCreationProps> = ({
  onCreatePolicy,
  isLoading,
  result
}) => {
  const [formData, setFormData] = useState<PolicyFormData>({
    coverageAmount: '',
    premiumAmount: '',
    duration: ''
  });

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onCreatePolicy(formData);
  };

  const handleChange = (field: keyof PolicyFormData, value: string) => {
    setFormData(prev => ({ ...prev, [field]: value }));
  };

  return (
    <div className="glass-card p-8 animate-slide-up">
      <h2 className="text-2xl font-bold text-white mb-6">
        🏥 Create Health Insurance Policy
      </h2>
      
      <form onSubmit={handleSubmit} className="space-y-6">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          <div>
            <label className="block text-white/90 font-medium mb-2">
              Coverage Amount (MYSU)
            </label>
            <input
              type="number"
              step="0.01"
              value={formData.coverageAmount}
              onChange={(e) => handleChange('coverageAmount', e.target.value)}
              placeholder="10.00"
              required
              className="w-full px-4 py-3 bg-white/10 border border-white/30 rounded-lg text-white placeholder-white/50 focus:border-white/60 focus:outline-none transition-colors"
            />
          </div>
          <div>
            <label className="block text-white/90 font-medium mb-2">
              Premium Amount (MYSU)
            </label>
            <input
              type="number"
              step="0.01"
              value={formData.premiumAmount}
              onChange={(e) => handleChange('premiumAmount', e.target.value)}
              placeholder="0.50"
              required
              className="w-full px-4 py-3 bg-white/10 border border-white/30 rounded-lg text-white placeholder-white/50 focus:border-white/60 focus:outline-none transition-colors"
            />
          </div>
          <div>
            <label className="block text-white/90 font-medium mb-2">
              Duration (days)
            </label>
            <input
              type="number"
              value={formData.duration}
              onChange={(e) => handleChange('duration', e.target.value)}
              placeholder="365"
              required
              className="w-full px-4 py-3 bg-white/10 border border-white/30 rounded-lg text-white placeholder-white/50 focus:border-white/60 focus:outline-none transition-colors"
            />
          </div>
        </div>
        
        <button
          type="submit"
          disabled={isLoading}
          className="gradient-button w-full md:w-auto disabled:opacity-50 disabled:cursor-not-allowed"
        >
          {isLoading ? (
            <>
              <svg className="animate-spin w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
              </svg>
              Creating Policy...
            </>
          ) : (
            <>
              ✨ Create Policy
            </>
          )}
        </button>
      </form>

      {result && (
        <div className={`mt-6 p-4 rounded-lg border ${
          result.success 
            ? 'bg-green-500/20 border-green-500/50 text-green-100' 
            : 'bg-red-500/20 border-red-500/50 text-red-100'
        }`}>
          <p className="font-semibold">{result.message}</p>
          {result.hash && (
            <p className="text-sm mt-2 break-all opacity-90">
              Transaction: {result.hash}
            </p>
          )}
        </div>
      )}

      {/* Policy Information */}
      <div className="mt-6 p-4 bg-blue-500/20 border border-blue-500/50 rounded-lg">
        <h4 className="font-semibold text-blue-100 mb-2">💡 Policy Information</h4>
        <ul className="text-blue-100/90 text-sm space-y-1">
          <li>• Coverage amount is the maximum claim you can make</li>
          <li>• Premium amount is what you pay for the policy</li>
          <li>• Duration is how long the policy will be active</li>
          <li>• You can pay premiums using your MYSU tokens</li>
        </ul>
      </div>
    </div>
  );
};

export default PolicyCreation;
