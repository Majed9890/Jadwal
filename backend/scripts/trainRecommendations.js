const path = require('path');
const { printPythonHelp, runPython } = require('./pythonRunner');

const backendDir = path.resolve(__dirname, '..');
const trainScript = path.join(backendDir, 'recommender', 'train_model.py');

const { result, attempts } = runPython(trainScript, [], { cwd: backendDir });

if (!result) {
  printPythonHelp(attempts);
  process.exit(1);
}

if (result.stdout) {
  process.stdout.write(result.stdout);
}
if (result.stderr) {
  process.stderr.write(result.stderr);
}

process.exit(result.status || 0);
