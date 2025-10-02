import { CheckCircle, Folder, FileText, Database, Server } from 'lucide-react';

function App() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-50 to-slate-100">
      <div className="container mx-auto px-4 py-12">
        <div className="max-w-6xl mx-auto">
          <div className="bg-white rounded-xl shadow-lg overflow-hidden">
            <div className="bg-gradient-to-r from-blue-600 to-blue-700 px-8 py-12 text-white">
              <div className="flex items-center gap-3 mb-4">
                <Server className="w-12 h-12" />
                <h1 className="text-4xl font-bold">SHA Toolbox</h1>
              </div>
              <p className="text-xl text-blue-100">
                Ansible Playbooks for Application Environment Management
              </p>
              <p className="text-blue-200 mt-2">
                Modern infrastructure automation for Linux RHEL and Windows servers
              </p>
            </div>

            <div className="p-8">
              <div className="flex items-center gap-2 mb-6">
                <CheckCircle className="w-6 h-6 text-green-500" />
                <h2 className="text-2xl font-bold text-gray-800">
                  Project Implementation Complete
                </h2>
              </div>

              <div className="grid md:grid-cols-2 gap-6 mb-8">
                <div className="bg-blue-50 rounded-lg p-6 border border-blue-200">
                  <div className="flex items-center gap-2 mb-3">
                    <Folder className="w-5 h-5 text-blue-600" />
                    <h3 className="font-semibold text-gray-800">Project Location</h3>
                  </div>
                  <code className="text-sm bg-white px-3 py-2 rounded border block overflow-x-auto">
                    /tmp/cc-agent/57928952/project/ansible-sha-toolbox/
                  </code>
                </div>

                <div className="bg-green-50 rounded-lg p-6 border border-green-200">
                  <div className="flex items-center gap-2 mb-3">
                    <Database className="w-5 h-5 text-green-600" />
                    <h3 className="font-semibold text-gray-800">Database</h3>
                  </div>
                  <p className="text-sm text-gray-600">
                    Supabase schema deployed with 4 tables and edge function for logging
                  </p>
                </div>
              </div>

              <div className="mb-8">
                <h3 className="text-xl font-semibold text-gray-800 mb-4">
                  Implemented Modules
                </h3>
                <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-4">
                  {[
                    { name: 'Operating', roles: 8, color: 'blue' },
                    { name: 'Web', roles: 5, color: 'purple' },
                    { name: 'Database', roles: 1, color: 'green' },
                    { name: 'Backup & Restore', roles: 2, color: 'orange' },
                  ].map((module) => (
                    <div
                      key={module.name}
                      className={`bg-${module.color}-50 border border-${module.color}-200 rounded-lg p-4`}
                    >
                      <h4 className="font-semibold text-gray-800 mb-1">
                        {module.name}
                      </h4>
                      <p className="text-sm text-gray-600">
                        {module.roles} Ansible role{module.roles > 1 ? 's' : ''}
                      </p>
                    </div>
                  ))}
                </div>
              </div>

              <div className="mb-8">
                <h3 className="text-xl font-semibold text-gray-800 mb-4">
                  Key Features
                </h3>
                <div className="grid md:grid-cols-2 gap-3">
                  {[
                    'Complete SHA arborescence creation',
                    'Filesystem management (create/extend/delete)',
                    'Application lifecycle management',
                    'WebSphere & IHS operations',
                    'Oracle database management',
                    'TSM backup integration',
                    'SSL certificate management',
                    'Middleware support (CFT, MQ, Nimsoft, etc.)',
                    'RootVG protection',
                    'Centralized logging to Supabase',
                    'Production safeguards',
                    'Comprehensive documentation',
                  ].map((feature, idx) => (
                    <div key={idx} className="flex items-start gap-2">
                      <CheckCircle className="w-5 h-5 text-green-500 flex-shrink-0 mt-0.5" />
                      <span className="text-gray-700">{feature}</span>
                    </div>
                  ))}
                </div>
              </div>

              <div className="bg-gray-50 rounded-lg p-6 border border-gray-200">
                <div className="flex items-center gap-2 mb-4">
                  <FileText className="w-5 h-5 text-gray-600" />
                  <h3 className="font-semibold text-gray-800">Documentation</h3>
                </div>
                <div className="space-y-2">
                  <div className="flex items-center gap-2">
                    <span className="text-gray-600">📖</span>
                    <code className="text-sm">README.md</code>
                    <span className="text-sm text-gray-500">
                      - Complete project documentation
                    </span>
                  </div>
                  <div className="flex items-center gap-2">
                    <span className="text-gray-600">🚀</span>
                    <code className="text-sm">QUICKSTART.md</code>
                    <span className="text-sm text-gray-500">
                      - 5-minute setup guide
                    </span>
                  </div>
                  <div className="flex items-center gap-2">
                    <span className="text-gray-600">🏗️</span>
                    <code className="text-sm">PROJECT_OVERVIEW.md</code>
                    <span className="text-sm text-gray-500">
                      - Architecture and design
                    </span>
                  </div>
                  <div className="flex items-center gap-2">
                    <span className="text-gray-600">✅</span>
                    <code className="text-sm">IMPLEMENTATION_SUMMARY.md</code>
                    <span className="text-sm text-gray-500">
                      - Implementation details
                    </span>
                  </div>
                </div>
              </div>

              <div className="mt-8 pt-6 border-t border-gray-200">
                <h3 className="text-lg font-semibold text-gray-800 mb-3">
                  Quick Start
                </h3>
                <div className="bg-gray-900 text-gray-100 rounded-lg p-4 overflow-x-auto">
                  <pre className="text-sm">
                    <code>{`cd ansible-sha-toolbox/

# Run setup script
./GET_STARTED.sh

# Test system information
ansible-playbook playbook.yml \\
  -e "toolbox_module=operating" \\
  -e "operation_type=info" \\
  --limit your-server

# Create application environment
ansible-playbook playbook.yml \\
  -e "operation_type=arborescence" \\
  -e "codeap=12345" \\
  -e "codescar=APP01" \\
  --limit your-server`}</code>
                  </pre>
                </div>
              </div>

              <div className="mt-6 flex flex-wrap gap-4">
                <div className="flex items-center gap-2 text-sm text-gray-600">
                  <span className="font-semibold">Total Files:</span>
                  <span>54+</span>
                </div>
                <div className="flex items-center gap-2 text-sm text-gray-600">
                  <span className="font-semibold">Ansible Roles:</span>
                  <span>16</span>
                </div>
                <div className="flex items-center gap-2 text-sm text-gray-600">
                  <span className="font-semibold">Database Tables:</span>
                  <span>4</span>
                </div>
                <div className="flex items-center gap-2 text-sm text-gray-600">
                  <span className="font-semibold">Example Playbooks:</span>
                  <span>4</span>
                </div>
              </div>
            </div>

            <div className="bg-gray-50 px-8 py-4 border-t border-gray-200">
              <p className="text-sm text-gray-600 text-center">
                Version 1.0.0 • Implementation Date: 2025-10-02 • Status: Complete & Ready for Deployment
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

export default App;
