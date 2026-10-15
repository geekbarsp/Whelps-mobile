const vscode = require('vscode');
const fs = require('node:fs');
const path = require('node:path');
exports.run = async () => {
  const extension = vscode.extensions.getExtension('lirobi.phone-preview');
  if (!extension) throw new Error('Installed Mobile Preview extension not found');
  await extension.activate();
  await vscode.commands.executeCommand('workbench.action.closeSidebar');
  await vscode.commands.executeCommand('mobile-preview.show');
  fs.writeFileSync(path.resolve(__dirname, '../../docs/validation/extension-result.json'), JSON.stringify({extension: extension.id, version: extension.packageJSON.version, command: 'mobile-preview.show', url: vscode.workspace.getConfiguration('mobile-preview').get('url'), activated: extension.isActive}, null, 2));
  // Keep the isolated preview window available for visual inspection.
  await new Promise(resolve => setTimeout(resolve, 180000));
};
