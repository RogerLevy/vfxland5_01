const vscode = require('vscode');
const path = require('path');
const fs = require('fs');

function activate(context) {
    let processedFiles = new Set();
    
    let disposable = vscode.workspace.onDidOpenTextDocument(async (document) => {
        if (document.fileName.endsWith('.vfx') && !processedFiles.has(document.fileName)) {
            processedFiles.add(document.fileName);
            
            const baseName = path.basename(document.fileName, '.vfx');
            const dirName = path.dirname(document.fileName);
            const txtFilePath = path.join(dirName, baseName + '.txt');
            
            if (fs.existsSync(txtFilePath)) {
                // Small delay to ensure the VFX file is fully opened first
                setTimeout(async () => {
                    try {
                        const txtUri = vscode.Uri.file(txtFilePath);
                        await vscode.commands.executeCommand('vscode.open', txtUri, {
                            viewColumn: vscode.ViewColumn.Two,
                            preserveFocus: false
                        });
                    } catch (error) {
                        console.error('Shadow Files: Error opening corresponding .txt file:', error);
                    }
                }, 200);
            }
        }
    });

    // Clean up processed files when documents are closed
    let closeDisposable = vscode.workspace.onDidCloseTextDocument((document) => {
        if (document.fileName.endsWith('.vfx')) {
            processedFiles.delete(document.fileName);
        }
    });

    context.subscriptions.push(disposable, closeDisposable);
}

function deactivate() {}

module.exports = {
    activate,
    deactivate
};